------------------------------------------------------------------------------
--                                                                          --
--                            GNAT2WHY COMPONENTS                           --
--                                                                          --
--              G N A T 2 W H Y _ C O U N T E R _ E X A M P L E S           --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                    Copyright (C) 2016-2018, AdaCore                      --
--                                                                          --
-- gnat2why is  free  software;  you can redistribute  it and/or  modify it --
-- under terms of the  GNU General Public License as published  by the Free --
-- Software  Foundation;  either version 3,  or (at your option)  any later --
-- version.  gnat2why is distributed  in the hope that  it will be  useful, --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of  MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.  You should have  received  a copy of the GNU --
-- General  Public License  distributed with  gnat2why;  see file COPYING3. --
-- If not,  go to  http://www.gnu.org/licenses  for a complete  copy of the --
-- license.                                                                 --
--                                                                          --
-- gnat2why is maintained by AdaCore (http://www.adacore.com)               --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Ordered_Sets;
with Ada.Strings;               use Ada.Strings;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Atree;                     use Atree;
with Einfo;                     use Einfo;
with Flow_Refinement;           use Flow_Refinement;
with Flow_Types;                use Flow_Types;
with GNAT;                      use GNAT;
with GNAT.String_Split;         use GNAT.String_Split;
with Gnat2Why.CE_Utils;         use Gnat2Why.CE_Utils;
with Gnat2Why.Util;             use Gnat2Why.Util;
with Namet;                     use Namet;
with Sem_Aux;                   use Sem_Aux;
with Sem_Eval;                  use Sem_Eval;
with Sem_Util;                  use Sem_Util;
with Sinfo;                     use Sinfo;
with Sinput;                    use Sinput;
with SPARK_Util;                use SPARK_Util;
with SPARK_Util.Types;          use SPARK_Util.Types;
with String_Utils;              use String_Utils;
with Uintp;                     use Uintp;

package body Gnat2Why.Counter_Examples is

   Dont_Display : constant Unbounded_String :=
     To_Unbounded_String ("@not_display");

   function Remap_VC_Info
     (Cntexmp : Cntexample_File_Maps.Map;
      VC_File : String;
      VC_Line : Natural)
      return Cntexample_File_Maps.Map;
   --  Map counterexample information related to the current VC to the
   --  location of the check in the Ada file.
   --  In Cntexmp, this information is mapped to the field "vc_line" of the
   --  JSON object representing the file where the construct is located.

   function Is_Ada_File_Name (File : String) return Boolean;
   --  check if the filename is an Ada
   --  ??? This check is wrong, need to get rid of it

   function Is_Uninitialized
     (Element_Decl : Entity_Id;
      Element_File : String;
      Element_Line : Natural)
      return Boolean;
   --  Return True if the counterexample element with given declaration at
   --  given position is uninitialized.

   type CNT_Element (<>);
   type CNT_Element_Ptr is access all CNT_Element;

   package CNT_Elements is
     new Ada.Containers.Indefinite_Ordered_Maps
       (Key_Type     => String,
        Element_Type => CNT_Element_Ptr);

   type CNT_Element_Map_Ptr is access all CNT_Elements.Map;

   package Vars_List is
     new Ada.Containers.Ordered_Sets
       (Element_Type => Unbounded_String);

   type Variables_Info is record
      Variables_Order : Vars_List.Set;
      --  Vector of variable names in the order in that variables should be
      --  displayed.

      Variables_Map : aliased CNT_Elements.Map;
      --  Map from variable names to information about these variables. This
      --  includes values of variables, informations about possible record
      --  fields and informations about possible attributes.
   end record;
   --  Represents variables at given source code location

   type CNT_Element is record
      Entity     : Entity_Id;
      --  The corresponding element of SPARK AST

      Attributes : CNT_Element_Map_Ptr;
      Fields     : CNT_Element_Map_Ptr;
      Value      : Cntexmp_Value_Ptr;
      Val_Str    : Unbounded_String;
   end record;
   --  Represents information about the element of a counter
   --  example. An element can be either:
   --  * a variable/field/attribute of a record type, in which case
   --    - Value = "@not_display",
   --    - Fields contains the CNT_Element of some/all of its fields
   --    - Attributes may contain info on its attributes.
   --  * a "flat" variable/field/attribute, in which case
   --    - Value is set to the counter example value
   --    - Fields is empty
   --    - and Attributes may contain info on its attributes.

   procedure Build_Pretty_Line
     (Variables               : Variables_Info;
      Pretty_Line_Cntexmp_Arr : out Cntexample_Elt_Lists.List);
   --  Build pretty printed JSON array of counterexample elements.
   --  @Variables stores information about values and fields of
   --    variables at a single source code location (line).

   procedure Build_Variables_Info
     (File             : String;
      Line             : Natural;
      Line_Cntexmp_Arr : Cntexample_Elt_Lists.List;
      Variables        : in out Variables_Info);
   --  Build a structure holding the informations associated to the
   --  counterexample at a single source code location.
   --  This structure associates to each variable mentioned in the
   --  counterexample a CNT_Element gathering the infos given in the
   --  counter example (fields if any, attributes and associated value(s)).
   --  @param Line_Cntexmp_Arr counterexample model elements at a
   --    single source code location (line)
   --  @param Variables stores information about values, fields
   --    and or attributes of variables at a single source code
   --    location.

   function Print_CNT_Element_Debug (El : CNT_Element) return String;
   --  Debug function, print a CNT_Element without any processing

   function Refine
     (Cnt_Value : Cntexmp_Value_Ptr;
      AST_Node  : Entity_Id)
      return Unbounded_String;
   --  This function takes a value from Why3 Cnt_Value and converts it into a
   --  suitable string for the corresponding entity in GNAT AST node AST_Node.
   --  Example: (97, Character_entity) -> "'a'"

   function Refine_Attribute (Cnt_Value : Cntexmp_Value_Ptr)
                              return Unbounded_String;
   --  Refine CNT_Value assuming it is an integer

   ------------
   -- Refine --
   ------------

   function Refine
     (Cnt_Value : Cntexmp_Value_Ptr;
      AST_Node  : Entity_Id)
      return Unbounded_String
   is
      function Compile_Time_Known_And_Constant (E : Entity_Id) return Boolean;
      --  This is used to know if something is compile time known and has
      --  the keyword constant on its definition. Internally, it calls
      --  Compile_Time_Known_Value_Or_Aggr.

      function Refine_Aux
        (Cnt_Value : Cntexmp_Value_Ptr;
         AST_Type  : Entity_Id;
         Is_Index  : Boolean := False)
         return Unbounded_String;
      --  Mutually recursive function with the local Refine_Value, which trims
      --  space on both ends of the result.

      function Refine_Array
        (Arr_Indices  : Cntexmp_Value_Array.Map;
         Arr_Others   : Cntexmp_Value_Ptr;
         Indice_Type  : Entity_Id;
         Element_Type : Entity_Id)
         return Unbounded_String
      with Pre => Is_Discrete_Type (Indice_Type)
                    and then
                  Is_Type (Element_Type);

      function Refine_Value
        (Cnt_Value : Cntexmp_Value_Ptr;
         AST_Type  : Entity_Id;
         Is_Index  : Boolean := False)
         return Unbounded_String;
      --  Mutually recursive function with the local Refine, which does the
      --  actual conversion.

      function Replace_Question_Mark (S : Unbounded_String)
                                      return Unbounded_String;
      --  This replaces empty string by question mark in some cases where it is
      --  needed.

      -------------------------------------
      -- Compile_Time_Known_And_Constant --
      -------------------------------------

      function Compile_Time_Known_And_Constant (E : Entity_Id) return Boolean
      is
      begin
         if Ekind (E) = E_Constant then
            declare
               Decl : constant Node_Id := Parent (E);
               Expr : constant Node_Id := Expression (Decl);
            begin
               return Present (Expr)
                 and then Compile_Time_Known_Value_Or_Aggr (Expr);
            end;
         end if;

         return False;
      end Compile_Time_Known_And_Constant;

      function Print_Float (Cnt_Value : Cntexmp_Value)
                            return Unbounded_String;
      --  ??? Used to print float counterex. This version is temporary.

      ----------------
      -- Refine_Aux --
      ----------------

      function Refine_Aux
        (Cnt_Value : Cntexmp_Value_Ptr;
         AST_Type  : Entity_Id;
         Is_Index  : Boolean := False)
         return Unbounded_String
      is

         function Get_Entity_Id (S : String) return Entity_Id;
         --  Convert a string of the form ".4554" to the Entity_Id 4554.
         --  Return the empty entity if not of the given form.

         -------------------
         -- Get_Entity_Id --
         -------------------

         function Get_Entity_Id (S : String) return Entity_Id is
         begin
            if S'First + 1 > S'Last then
               return Empty;
            else
               return Entity_Id'Value (S (S'First + 1 .. S'Last));
            end if;
         exception
            when Constraint_Error =>
               return Empty;
         end Get_Entity_Id;

         Why3_Type : constant Cntexmp_Type := Cnt_Value.all.T;
      begin
         case Why3_Type is
            when Cnt_Integer =>

               --  Necessary for some types that makes boolean be translated to
               --  integers like: "subype only_true := True .. True".

               if Is_Boolean_Type (AST_Type) then
                  return To_Unbounded_String (Cnt_Value.I /= "0");

               elsif Is_Enumeration_Type (AST_Type) then
                  declare
                     Value : constant Uint := UI_From_Int
                       (Int'Value (To_String (Cnt_Value.I)));

                     --  Call Get_Enum_Lit_From_Pos to get a corresponding
                     --  enumeration entity.
                     Enum  : Entity_Id;
                  begin
                     Enum := Sem_Util.Get_Enum_Lit_From_Pos
                       (AST_Type, Value, No_Location);

                     --  Special case for characters, which are defined in the
                     --  standard unit Standard.ASCII, and as such do not have
                     --  a source code representation.

                     if Is_Character_Type (AST_Type) then
                        --  Call Get_Unqualified_Decoded_Name_String to get a
                        --  correctly printed character in Name_Buffer.

                        Get_Unqualified_Decoded_Name_String (Chars (Enum));

                        --  The call to Get_Unqualified_Decoded_Name_String
                        --  set Name_Buffer to '<char>' where <char> is the
                        --  character we are interested in. Just retrieve it
                        --  directly at Name_Buffer(2).

                        return "'" & To_Unbounded_String
                          (Char_To_String_Representation
                             (Name_Buffer (2))) & "'";

                        --  For all enumeration types that are not character,
                        --  call Get_Enum_Lit_From_Pos to get a corresponding
                        --  enumeratio n entity, then Source_Name to get a
                        --  correctly capitalized enumeration value.

                     else
                        return To_Unbounded_String (Source_Name (Enum));
                     end if;

                     --  An exception is raised by Get_Enum_Lit_From_Pos
                     --  if the position Value is outside the bounds of the
                     --  enumeration. In such a case, return the raw integer
                     --  returned by the prover.

                  exception
                     when Constraint_Error =>
                        if Is_Index then
                           return Null_Unbounded_String;
                        else
                           return Cnt_Value.I;
                        end if;
                  end;

                  --  Cvc4 returns Floating_point value with integer type. We
                  --  don't want to print those.

               elsif Is_Floating_Point_Type (AST_Type) then
                  return Null_Unbounded_String;

               --  ??? only integer types are expected in that last case

               else
                  return Cnt_Value.I;
               end if;

            when Cnt_Boolean =>
               return To_Unbounded_String (Cnt_Value.Bo);

            when Cnt_Bitvector =>

               --  Boolean are translated into bitvector of size 1 for CVC4
               --  because it fails to produce a model when booleans are used
               --  inside translated arrays_of_records.

               if Is_Boolean_Type (AST_Type) then
                  return To_Unbounded_String (Cnt_Value.B /= "0");
               end if;

               return Cnt_Value.B;

            when Cnt_Decimal =>
               return Cnt_Value.D;

            when Cnt_Float =>

               if Is_Floating_Point_Type (AST_Type) then
                  return Print_Float (Cnt_Value.all);
               else
                  --  ??? only float types are expected here
                  return Print_Float (Cnt_Value.all);
               end if;

            when Cnt_Unparsed =>
               return Cnt_Value.U;

            when Cnt_Record =>

               --  AST_Type is of record type
               declare
                  Mfields       : constant Cntexmp_Value_Array.Map :=
                                    Cnt_Value.Fi;
                  S             : Unbounded_String :=
                                    To_Unbounded_String ("(");

                  AST_Basetype  : constant Entity_Id :=
                    Retysp (AST_Type);
                  Check_Count   : Integer := 0;
                  Fields : constant Integer :=
                    Count_Why_Visible_Regular_Fields (AST_Basetype) +
                    Count_Discriminants (AST_Basetype);

               begin

                  Fields_Loop :
                  for Cursor in Mfields.Iterate loop
                     declare
                        Mfield       : constant Cntexmp_Value_Ptr :=
                                         Cntexmp_Value_Array.Element (Cursor);
                        Key_Field    : constant String :=
                                         Cntexmp_Value_Array.Key (Cursor);
                        Field_Entity : constant Entity_Id :=
                                         Get_Entity_Id (Key_Field);
                     begin
                        --  There are two cases:
                        --  - discriminant -> we always include the field
                        --    corresponding to discriminants because they are
                        --    inherited by subtyping.
                        --    The current design enforce that the discriminant
                        --    is part of the AST_Basetype.
                        --  - components -> some components can be hidden by
                        --    subtyping. But, in Why3, any ancestor type
                        --    with the same field can be used. So,
                        --    counterexamples can have more components than
                        --    are actually defined in the AST_basetype.

                        if Present (Field_Entity) and then
                          (Ekind (Field_Entity) = E_Discriminant
                           or else
                           Is_Visible_In_Type (AST_Basetype,
                                               Field_Entity))
                        then
                           declare
                              Field_Type : constant Entity_Id :=
                                             Retysp (Etype (Field_Entity));
                              Field_Name : constant String :=
                                             Source_Name (Field_Entity);
                           begin
                              if Check_Count > 0 then
                                 Append (S, ", ");
                              end if;

                              Check_Count := Check_Count + 1;

                              Append (S, Field_Name & " => " &
                                        Replace_Question_Mark
                                        (Refine_Aux (Mfield, Field_Type)));
                           end;
                        end if;
                     end;

                  end loop Fields_Loop;

                  Append (S,
                          (if Check_Count /= Fields then
                             (if Check_Count > 0 then
                                 ", others => ?)"
                              else
                                 "others => ?)")
                           else ")"));

                  return S;
               end;

            --  This case only happens when the why3 counterexamples are
            --  incorrect. Ideally, this case should be removed but it
            --  still happens in practice.

            when Cnt_Invalid =>
               return Cnt_Value.S;

            when Cnt_Array =>
               if Is_Array_Type (AST_Type) then
                  declare
                     Indice_Type  : constant Entity_Id :=
                                      Retysp (Etype (First_Index (AST_Type)));
                     Element_Type : constant Entity_Id :=
                                      Retysp (Component_Type (AST_Type));
                  begin
                     return Refine_Array (Cnt_Value.Array_Indices,
                                          Cnt_Value.Array_Others,
                                          Indice_Type,
                                          Element_Type);
                  end;

               --  This case should not happen

               else
                  return Null_Unbounded_String;
               end if;
         end case;
      end Refine_Aux;

      ------------------
      -- Refine_Array --
      ------------------

      function Refine_Array
        (Arr_Indices  : Cntexmp_Value_Array.Map;
         Arr_Others   : Cntexmp_Value_Ptr;
         Indice_Type  : Entity_Id;
         Element_Type : Entity_Id)
         return Unbounded_String
      is
         S : Unbounded_String;
      begin
         Append (S, "(");
         for C in Arr_Indices.Iterate loop
            declare
               Indice       : String renames Cntexmp_Value_Array.Key (C);
               Elem         : Cntexmp_Value_Ptr renames Arr_Indices (C);

               Ind_Val      : constant Cntexmp_Value_Ptr :=
                                new Cntexmp_Value'(T => Cnt_Integer,
                                                   I => To_Unbounded_String
                                                     (Indice));
               Ind_Printed  : constant Unbounded_String :=
                                Refine_Value (Ind_Val, Indice_Type, True);
               Elem_Printed : constant Unbounded_String :=
                                Refine_Value (Elem, Element_Type);
            begin

               --  The other case happen when the index has an enumeration type
               --  and the value for this index given by cvc4 is outside of the
               --  range of the enumeration type.
               if Ind_Printed /= Null_Unbounded_String then
                  Append (S, Ind_Printed & " => " & Elem_Printed & ", ");
               end if;
            end;
         end loop;

         Append (S,
                 "others => " & Refine_Value (Arr_Others, Element_Type) & ")");

         return S;
      end Refine_Array;

      ------------------
      -- Refine_Value --
      ------------------

      function Refine_Value
        (Cnt_Value : Cntexmp_Value_Ptr;
         AST_Type  : Entity_Id;
         Is_Index  : Boolean := False)
         return Unbounded_String
      is
         Res : constant Unbounded_String :=
                 Refine_Aux (Cnt_Value, AST_Type, Is_Index);
      begin
         return Trim (Res, Both);
      end Refine_Value;

      -----------------
      -- Print_Float --
      -----------------

      function Print_Float (Cnt_Value : Cntexmp_Value)
                            return Unbounded_String
      is
         F : Float_Value renames Cnt_Value.F.all;
      begin
         case F.F_Type is
         when Float_Plus_Infinity  =>
            return To_Unbounded_String ("+oo");

         when Float_Minus_Infinity =>
            return To_Unbounded_String ("-oo");

         when Float_Plus_Zero      =>
            return To_Unbounded_String ("+zero");

         when Float_Minus_Zero     =>
            return To_Unbounded_String ("-zero");

         when Float_NaN            =>
            return To_Unbounded_String ("NaN");

         when Float_Val =>
            declare
            begin
               return "(fp " & F.F_Sign & ", " & F.F_Exponent & ", "
                 & F.F_Significand & ")";
            end;
         when Float_Hexa =>
            return F.F_Hexa;

         end case;
      end Print_Float;

      ---------------------------
      -- Replace_Question_Mark --
      ---------------------------

      function Replace_Question_Mark (S : Unbounded_String)
                                      return Unbounded_String
      is
      begin
         if S = "" then
            return To_Unbounded_String ("?");
         else
            return (S);
         end if;
      end Replace_Question_Mark;

   --  Start of processing for Refine

   begin
      if Compile_Time_Known_And_Constant (AST_Node) then
         return Null_Unbounded_String;
      else
         return Refine_Value (Cnt_Value, Retysp (Etype (AST_Node)));
      end if;
   end Refine;

   ----------------------
   -- Refine_Attribute --
   ----------------------

   function Refine_Attribute (Cnt_Value : Cntexmp_Value_Ptr)
                              return Unbounded_String
   is
      Why3_Type : constant Cntexmp_Type := Cnt_Value.all.T;
   begin
      case Why3_Type is
         when Cnt_Integer =>
            return Cnt_Value.I;

         when Cnt_Bitvector =>
            return Cnt_Value.B;

         when Cnt_Unparsed =>
            return Cnt_Value.U;

         when others =>
            return Null_Unbounded_String;
      end case;

   end Refine_Attribute;

   -----------------------
   -- Build_Pretty_Line --
   -----------------------

   procedure Build_Pretty_Line
     (Variables               : Variables_Info;
      Pretty_Line_Cntexmp_Arr : out Cntexample_Elt_Lists.List)
   is
      use CNT_Elements;

      --  This record contain the name of the entity and the value of the
      --  corresponding counterexample generated by Why3 (used for attributes).
      type Name_And_Value is record
         Name  : Unbounded_String;
         Value : Unbounded_String;
      end record;

      package Names_And_Values is
        new Ada.Containers.Doubly_Linked_Lists
          (Element_Type => Name_And_Value);

      function Get_CNT_Element_Value
        (CNT_Element : CNT_Element_Ptr;
         Prefix      : Unbounded_String)
         return Unbounded_String;

      procedure Get_CNT_Element_Attributes
        (CNT_Element : CNT_Element_Ptr;
         Prefix      : Unbounded_String;
         Attributes  : in out Names_And_Values.List);
      --  Gets the attribute of an element and the attributes of its subfields

      function Get_CNT_Element_Value_And_Attributes
        (CNT_Element : CNT_Element_Ptr;
         Prefix      : Unbounded_String;
         Attributes  : in out Names_And_Values.List)
         return Unbounded_String;
      --  Gets the string value of given variable, record field or Attribute.
      --  If the value is of record type, the returned value is a record
      --  aggregate.
      --  If the value should not be displayed in countereexample, value
      --  "@not_display" is returned.
      --  In addition, recursively populate the list of attributes "Attributes"
      --  of CNT_Element and its fields if any attribute is found.

      --------------------------------
      -- Get_CNT_Element_Attributes --
      --------------------------------

      procedure Get_CNT_Element_Attributes
        (CNT_Element : CNT_Element_Ptr;
         Prefix      : Unbounded_String;
         Attributes  : in out Names_And_Values.List)
      is
         Element_Type : constant Entity_Id :=
           (if Present (CNT_Element.Entity) then
              Etype (CNT_Element.Entity)
            else
              Empty);

      begin

         for Att in CNT_Element.Attributes.Iterate loop
            declare
               New_Prefix : constant Unbounded_String :=
                 Prefix & "'" & CNT_Elements.Key (Att);

               Attribute_Element : constant CNT_Element_Ptr :=
                 CNT_Elements.Element (Att);
               Refined_Value     : Unbounded_String;

            begin
               --  Currently attributes are always printed as integers

               if CNT_Elements.Key (Att) = "First" then
                  Refined_Value :=
                    Refine_Attribute (Attribute_Element.Value);
               elsif CNT_Elements.Key (Att) = "Last" then
                  Refined_Value :=
                    Refine_Attribute (Attribute_Element.Value);
               elsif CNT_Elements.Key (Att) = "Result" then
                  Refined_Value :=
                    Get_CNT_Element_Value_And_Attributes
                      (Attribute_Element,
                       Prefix,
                       Attributes);
               elsif CNT_Elements.Key (Att) = "Old" then
                  Refined_Value :=
                    Get_CNT_Element_Value_And_Attributes
                      (Attribute_Element,
                       Prefix,
                       Attributes);
               else
                  Refined_Value :=
                    Refine_Attribute (Attribute_Element.Value);
               end if;

               --  Detecting the absence of value
               if Refined_Value /= ""
                 and then Refined_Value /= "!"
                 and then Refined_Value /= "( )"
                 and then Refined_Value /= "()"
               then
                  Attributes.Append
                    (New_Item =>
                       (Name  => New_Prefix,
                        Value => Refined_Value));
               end if;
            end;
         end loop;

         --  Following types should be ignored when exploring fields of
         --  CNT_Element.

         if not Is_Concurrent_Type (Element_Type)
           and then not Is_Incomplete_Or_Private_Type (Element_Type)
           and then not Is_Record_Type (Element_Type)
           and then not Has_Discriminants (Element_Type)
         then
            return;
         end if;

         --  Check the attributes of the fields
         declare
            Decl_Field_Discr : Entity_Id :=
              First_Component_Or_Discriminant (Element_Type);

         begin
            while Present (Decl_Field_Discr) loop
               declare
                  Field_Descr_Name : constant String :=
                                       Source_Name (Decl_Field_Discr);
                  Field_Descr      : constant Cursor :=
                                       Find (CNT_Element.Fields.all,
                                             Field_Descr_Name);
               begin
                  if Has_Element (Field_Descr) then
                     Get_CNT_Element_Attributes
                       (Element (Field_Descr),
                        Prefix & "." & Field_Descr_Name,
                        Attributes);
                  end if;
                  Next_Component_Or_Discriminant (Decl_Field_Discr);
               end;
            end loop;
         end;
      end Get_CNT_Element_Attributes;

      ---------------------------
      -- Get_CNT_Element_Value --
      ---------------------------

      function Get_CNT_Element_Value
        (CNT_Element : CNT_Element_Ptr;
         Prefix      : Unbounded_String)
         return Unbounded_String
      is
         Element_Type : constant Entity_Id :=
           (if Present (CNT_Element.Entity) then
              Etype (CNT_Element.Entity)
            else
              Empty);

      begin
         --  If Element_Type is not a "record" (anything with components or
         --  discriminants), return the value of the node.

         if not Is_Record_Type (Element_Type)
           and then not Is_Private_Type (Element_Type)
         then
            declare
               Refined_Value : constant Unbounded_String :=
                                 Refine (CNT_Element.Value,
                                         CNT_Element.Entity);
            begin
               if Refined_Value = "" then
                  return Dont_Display;
               else
                  CNT_Element.Val_Str := Refined_Value;
                  return CNT_Element.Val_Str;
               end if;
            end;
         end if;

         --  If no field of the record is set and this is a record then we
         --  should have a record value associated to this element.

         if CNT_Element.Fields.Is_Empty then
            declare
               Refined_Value : constant Unbounded_String :=
                            Refine (CNT_Element.Value,
                                    CNT_Element.Entity);
            begin
               if Refined_Value = "" then
                  return Dont_Display;
               else
                  CNT_Element.Val_Str := Refined_Value;
                  return (CNT_Element.Val_Str);
               end if;
            end;
         end if;

         --  Check whether the type can have fields or discriminants

         if not Is_Concurrent_Type (Element_Type)
           and then not Is_Incomplete_Or_Private_Type (Element_Type)
           and then not Is_Record_Type (Element_Type)
           and then not Has_Discriminants (Element_Type)
         then
            return Dont_Display;
         end if;

         declare
            Refined_Value : constant Unbounded_String :=
                    Refine (CNT_Element.Value,
                            CNT_Element.Entity);
         begin
            --  Detecting the absence of value

            if Refined_Value /= ""
              and then Refined_Value /= "!"
              and then Refined_Value /= "( )"
              and then Refined_Value /= "()"
            then
               CNT_Element.Val_Str := Refined_Value;
               return CNT_Element.Val_Str;
            else
               --  No value were found for the variable so we need to recover
               --  the record field by field. We will go through all fields of
               --  CNT_Element and iterate on CNT_Element_Type components to
               --  get them in the right order.

               declare
                  Fields_Discrs_Collected  : constant Natural :=
                             Natural ((CNT_Element.Fields.Length));
                  Fields_Discrs_Declared   : constant Natural :=
                                  Natural (Number_Components (Element_Type));
                  Fields_Discrs_With_Value : Natural := 0;
                  Decl_Field_Discr         : Entity_Id :=
                    First_Component_Or_Discriminant (Element_Type);
                  --  Not using the base_type here seems ok since
                  --  counterexamples should be projected in this part of
                  --  the code

                  Is_Before : Boolean := False;
                  Value     : Unbounded_String := To_Unbounded_String ("(");

               begin
                  --  If the record type of the value has no fields and
                  --  discriminants or if there were no counterexample values
                  --  for fields and discriminants of the processed value
                  --  collected, do not display the value

                  if Fields_Discrs_Collected = 0
                    or else Fields_Discrs_Declared = 0
                  then
                     return Dont_Display;
                  end if;

                  while Present (Decl_Field_Discr) loop
                     declare
                        Field_Descr_Name : constant String :=
                                             Source_Name (Decl_Field_Discr);
                        Field_Descr      : constant Cursor :=
                                             Find (CNT_Element.Fields.all,
                                                   Field_Descr_Name);
                     begin
                        if Has_Element (Field_Descr)
                            or else
                          Fields_Discrs_Declared - Fields_Discrs_Collected <= 1
                        then
                           declare
                              Field_Descr_Val : constant Unbounded_String :=
                                  (if Has_Element (Field_Descr)
                                   then
                                      Get_CNT_Element_Value
                                        (Element (Field_Descr),
                                         Prefix & "." & Field_Descr_Name)
                                   else To_Unbounded_String ("?"));
                           begin
                              if Field_Descr_Val /= Dont_Display then
                                 Append (Value,
                                         (if Is_Before then ", " else "") &
                                         Field_Descr_Name &
                                         " => " &
                                         Field_Descr_Val);
                                 Is_Before := True;
                                 if Has_Element (Field_Descr) then
                                    Fields_Discrs_With_Value :=
                                      Fields_Discrs_With_Value + 1;
                                 end if;
                              end if;
                           end;
                        end if;
                        Next_Component_Or_Discriminant (Decl_Field_Discr);
                     end;
                  end loop;

                  --  If there are no fields and discriminants of the processed
                  --  value with values that can be displayed, do not display
                  --  the value (this can happen if there were collected
                  --  fields or discrinants, but their values should not
                  --  be displayed).

                  if Fields_Discrs_With_Value = 0 then
                     return Dont_Display;
                  end if;

                  --  If there are more than one field that is not mentioned
                  --  in the counterexample, summarize them using the field
                  --  others.

                  if Fields_Discrs_Declared - Fields_Discrs_Collected > 1 then
                     Append (Value,
                             (if Is_Before then ", " else "") &
                               "others => ?");
                  end if;
                  Append (Value, ")");

                  return Value;
               end;
            end if;
         end;
      end Get_CNT_Element_Value;

      ------------------------------------------
      -- Get_CNT_Element_Value_And_Attributes --
      ------------------------------------------

      function Get_CNT_Element_Value_And_Attributes
        (CNT_Element : CNT_Element_Ptr;
         Prefix      : Unbounded_String;
         Attributes  : in out Names_And_Values.List)
         return Unbounded_String
      is
      begin
         --  Fill in first the values of attributes so that we can ignore
         --  attributes in what follows.
         Get_CNT_Element_Attributes (CNT_Element,
                                     Prefix,
                                     Attributes);

         --  Return the value
         return Get_CNT_Element_Value (CNT_Element, Prefix);
      end Get_CNT_Element_Value_And_Attributes;

   --  Start of processing for Build_Pretty_Line

   begin
      Pretty_Line_Cntexmp_Arr := Cntexample_Elt_Lists.Empty_List;

      for Var_Name of Variables.Variables_Order loop
         declare
            Variable : Cursor :=
              Variables.Variables_Map.Find (To_String (Var_Name));

            Attributes : Names_And_Values.List;

            Var_Value : constant Unbounded_String :=
              Get_CNT_Element_Value_And_Attributes
                (Element (Variable),
                 Var_Name,
                 Attributes);

            procedure Add_CNT (Name, Value : Unbounded_String);
            --  Append a cnt variable and its value to the list

            -------------
            -- Add_CNT --
            -------------

            procedure Add_CNT (Name, Value : Unbounded_String) is
            begin
               --  If the value of the variable should not be displayed in the
               --  counterexample, do not display the variable.

               if Value /= Dont_Display then
                  Pretty_Line_Cntexmp_Arr.Append
                    (Cntexample_Elt'(Kind    => CEE_Variable,
                                     Name    => Name,
                                     Value   => Element (Variable).Value,
                                     Val_Str => Value));
               end if;
            end Add_CNT;

         begin
            Add_CNT (Var_Name, Var_Value);

            for Att of Attributes loop
               Add_CNT (Att.Name, Att.Value);
            end loop;

            Next (Variable);
         end;
      end loop;
   end Build_Pretty_Line;

   --------------------------
   -- Build_Variables_Info --
   --------------------------

   procedure Build_Variables_Info
     (File             : String;
      Line             : Natural;
      Line_Cntexmp_Arr : Cntexample_Elt_Lists.List;
      Variables        : in out Variables_Info)
   is
      function Insert_CNT_Element
        (Name   : String;
         Entity : Entity_Id;
         Map    : CNT_Element_Map_Ptr)
         return CNT_Element_Ptr;
      --  Insert a CNT_Element with given name and entity to the given map. If
      --  it has already been inserted, return the existing; if not, create new
      --  entry, store it in the map, and return it.

      ------------------------
      -- Insert_CNT_Element --
      ------------------------

      function Insert_CNT_Element
        (Name   : String;
         Entity : Entity_Id;
         Map    : CNT_Element_Map_Ptr)
         return CNT_Element_Ptr
      is
         use CNT_Elements;
         Var : CNT_Element_Ptr;

      begin
         if Map.Contains (Name) then
            Var := Element (Map.all, Name);
         else
            Var := new CNT_Element'
              (Entity     => Entity,
               Attributes => new CNT_Elements.Map,
               Fields     => new CNT_Elements.Map,
               Value      => new Cntexmp_Value'
                 (T => Cnt_Invalid,
                  S => Null_Unbounded_String),
               Val_Str    => Null_Unbounded_String);

            Include (Container => Map.all,
                     Key       => Name,
                     New_Item  => Var);
         end if;

         return Var;
      end Insert_CNT_Element;

   --  Start of processing for Build_Variables_Info

   begin
      for Elt of Line_Cntexmp_Arr loop

         declare
            Name_Parts : String_Split.Slice_Set;
            Current_Subfields_Map : CNT_Element_Map_Ptr :=
              Variables.Variables_Map'Unchecked_Access;
            Current_Attributes_Map : CNT_Element_Map_Ptr :=
              new CNT_Elements.Map;
         begin

            --  There is either one model element with its name corresponding
            --  to an error message. No variable map is built in this case.

            if Elt.Kind = CEE_Error_Msg then
               return;
            end if;

            --  model elements are of the form:
            --  Name ::= | Variable
            --           | Variable "." Record_Fields
            --           | Variable "'" Attributes
            --  Record_Fields ::= | Record_Field "." Record_Fields
            --                    | Record_Field "'" Attributes
            --                    | Record_Field
            --  Attributes ::= | Attribute "." Record_Fields
            --                 | Attribute "'" Attributes
            --                 | Attribute
            --  Variable ::= ENTITY_ID
            --  Record_Field ::= ENTITY_ID
            --  Attribute ::= | Attr_type
            --                | Attr_type " (" num ")"
            --  Attr_type ::= | "First"
            --                | "Last"
            --                | "attr__constrained"
            --                | "attr__tag"
            --
            --  num := [0-9]+
            --
            --  See Bound_Dimension_To_Str for more information on the "(5)"
            --  notation.
            --  See Attr_To_Why_Name for Attr_type cases and To_string on
            --  Why_Name_Enum type
            --
            --  The ENTITY_ID in first Part corresponds to a
            --  variable, others to record fields.

            --  Split Name into sequence of Part
            String_Split.Create (S          => Name_Parts,
                                 From       => To_String (Elt.Name),
                                 Separators => ".'",
                                 Mode       => String_Split.Single);

            --  For every Part, we create a CNT_Element
            for Var_Slice_Num in 1 .. String_Split.Slice_Count (Name_Parts)
            loop
               declare

                  function Try_Get_Part_Entity (Part : String)
                                                return Entity_Id;
                  --  Try to cast Part into an Entity_Id, return empty id if it
                  --  doesn't work.

                  -------------------------
                  -- Try_Get_Part_Entity --
                  -------------------------

                  function Try_Get_Part_Entity (Part : String)
                                                return Entity_Id
                  is
                  begin
                     return Entity_Id'Value (Part);
                  exception
                     when Constraint_Error =>
                        return Empty;
                  end Try_Get_Part_Entity;

                  Part : constant String := Slice (Name_Parts, Var_Slice_Num);

                  Part_Entity : constant Entity_Id :=
                    Try_Get_Part_Entity (Part);
                  --  Note that if Var_Slice_Num = 1, Part_Entity is Entity_Id
                  --  of either declaration of argument of a function
                  --  or declaration of a variable (corresponding to the
                  --  counterexample element being processed) If Var_Slice_Num
                  --  > 1, Part_Entity is Entity_Id of declaration of record
                  --  field or discriminant.

                  Is_Attribute : Boolean := No (Part_Entity);

                  --  If Part does not cast into an entity_id it is treated as
                  --  an attribute.

                  Part_Name : Unbounded_String :=
                    To_Unbounded_String
                      (if Is_Attribute
                       then Part
                       else Source_Name (Part_Entity));
                  Current_CNT_Element : CNT_Element_Ptr;

               begin
                  if Var_Slice_Num = 1 then

                     --  Process the first Entity_Id, which corresponds to a
                     --  variable.

                     --  Do not display uninitialized counterexample elements
                     --  (elements corresponding to uninitialized variables or
                     --  function arguments).
                     if Is_Uninitialized (Part_Entity, File, Line) then
                        goto Next_Model_Element;
                     end if;

                     --  Store variable name to Variable_List
                     if not Variables.Variables_Order.Contains (Part_Name) then
                        Vars_List.Include
                          (Variables.Variables_Order,
                           Part_Name);
                     end if;

                     --  Possibly Append attributes 'Old or
                     --  'Result after its name
                     if (Elt.Kind = CEE_Old
                           and then
                         Nkind (Parent (Part_Entity)) in
                           N_Formal_Object_Declaration |
                           N_Parameter_Specification
                           and then
                         Out_Present (Parent (Part_Entity)))
                       or else Elt.Kind = CEE_Result
                     then
                        Current_CNT_Element := Insert_CNT_Element
                          (Name   => To_String (Part_Name),
                           Entity => Part_Entity,
                           Map    => Current_Subfields_Map);

                        Current_Subfields_Map :=
                          Current_CNT_Element.Fields;
                        Current_Attributes_Map :=
                          Current_CNT_Element.Attributes;

                        Part_Name := To_Unbounded_String
                          (if Elt.Kind = CEE_Old
                           then "Old"
                           else "Result");
                        Is_Attribute := True;

                     end if;
                  end if;

                     Current_CNT_Element := Insert_CNT_Element
                       (Name   => To_String (Part_Name),
                        Entity => Part_Entity,
                        Map    => (if Is_Attribute
                                   then Current_Attributes_Map
                                   else Current_Subfields_Map));

                     --  Note that Value is set even if it has already been
                     --  set. Overriding of value happens if a loop is unrolled
                     --  (see Gnat2Why.Expr.Loops.Wrap_Loop) and the VC for
                     --  that the counterexample was generated is for a loop
                     --  iteration. In this case, there are both counterexample
                     --  elements for variables in an unrolling of the loop
                     --  and a loop iteration and these counterexample elements
                     --  have the same names and locations (but can have
                     --  different values). Note that in this case only the
                     --  counterexample elements for the loop iteration are
                     --  relevant for the proof. Counterexample elements
                     --  are reported in the order in that the corresponding
                     --  variables are in generated why code and thus using the
                     --  last counterexample element with given Name ensures
                     --  the correct behavior.

                     if Var_Slice_Num = Slice_Count (Name_Parts) then
                        Current_CNT_Element.Value := new
                          Cntexmp_Value'(Elt.Value.all);
                     end if;

                     Current_Subfields_Map :=
                       Current_CNT_Element.Fields;

                     Current_Attributes_Map :=
                       Current_CNT_Element.Attributes;
               end;
            end loop;
         end;
         <<Next_Model_Element>>
      end loop;
   end Build_Variables_Info;

   ---------------------------
   -- Create_Pretty_Cntexmp --
   ---------------------------

   function Create_Pretty_Cntexmp
     (Cntexmp : Cntexample_File_Maps.Map;
      VC_Loc  : Source_Ptr)
      return Cntexample_File_Maps.Map
   is
      procedure Create_Pretty_Line
        (Pretty_File_Cntexmp : in out Cntexample_Lines;
         File                : String;
         Line                : Natural;
         Line_Cntexmp        : Cntexample_Elt_Lists.List);
      --  Pretty prints counterexample model elements at a single source
      --  code location (line).

      ------------------------
      -- Create_Pretty_Line --
      ------------------------

      procedure Create_Pretty_Line
        (Pretty_File_Cntexmp : in out Cntexample_Lines;
         File                : String;
         Line                : Natural;
         Line_Cntexmp        : Cntexample_Elt_Lists.List)
      is
         use CNT_Elements;

         Variables : Variables_Info;
         Pretty_Line_Cntexmp_Arr : Cntexample_Elt_Lists.List;

      --  Start of processing for Create_Pretty_Line

      begin
         Build_Variables_Info (File, Line, Line_Cntexmp, Variables);

         if not Is_Empty (Variables.Variables_Map) then
            Build_Pretty_Line (Variables, Pretty_Line_Cntexmp_Arr);

            --  Add the counterexample line only if there are some
            --  pretty printed counterexample elements
            if not Pretty_Line_Cntexmp_Arr.Is_Empty then
               Pretty_File_Cntexmp.Other_Lines.Insert
                 (Line, Pretty_Line_Cntexmp_Arr);
            end if;
         end if;
      end Create_Pretty_Line;

      File : constant String := File_Name (VC_Loc);
      Line : constant Logical_Line_Number :=
        Get_Logical_Line_Number (VC_Loc);
      Remapped_Cntexmp : constant Cntexample_File_Maps.Map :=
        Remap_VC_Info (Cntexmp, File, Natural (Line));
      Pretty_Cntexmp : Cntexample_File_Maps.Map :=
        Cntexample_File_Maps.Empty_Map;

      use Cntexample_File_Maps;

   --  Start of processing for Create_Pretty_Cntexmp

   begin
      for File_C in Remapped_Cntexmp.Iterate loop
         declare
            Pretty_File_Cntexmp : Cntexample_Lines :=
             Cntexample_Lines'(VC_Line     =>
                                 Cntexample_Elt_Lists.Empty_List,
                               Other_Lines =>
                                 Cntexample_Line_Maps.Empty_Map);

            Filename  : String renames Key (File_C);
            Lines_Map : Cntexample_Line_Maps.Map renames
              Element (File_C).Other_Lines;

         begin
            for Line_C in Lines_Map.Iterate loop
               Create_Pretty_Line
                 (Pretty_File_Cntexmp,
                  Filename,
                  Cntexample_Line_Maps.Key (Line_C),
                  Lines_Map (Line_C));
            end loop;

            --  At this point, the information of VC_line is now in the
            --  Other_Lines field because Remap_VC_Info was applied.
            if Is_Ada_File_Name (Filename) and then
              not Cntexample_Line_Maps.Is_Empty
                (Pretty_File_Cntexmp.Other_Lines)
            then
               Pretty_Cntexmp.Insert (Filename, Pretty_File_Cntexmp);
            end if;
         end;
      end loop;

      return Pretty_Cntexmp;
   end Create_Pretty_Cntexmp;

   ---------------------------
   -- Get_Cntexmp_One_Liner --
   ---------------------------

   function Get_Cntexmp_One_Liner
     (Cntexmp : Cntexample_File_Maps.Map;
      VC_Loc  : Source_Ptr)
      return String
   is
      function Get_Cntexmp_Line_Str
        (Cntexmp_Line : Cntexample_Elt_Lists.List) return String;

      --------------------------
      -- Get_Cntexmp_Line_Str --
      --------------------------

      function Get_Cntexmp_Line_Str
        (Cntexmp_Line : Cntexample_Elt_Lists.List) return String
      is
         Cntexmp_Line_Str : Unbounded_String;

      begin
         for Elt of Cntexmp_Line loop
            if Cntexmp_Line_Str /= "" then
               Append (Cntexmp_Line_Str, " and ");
            end if;
            Append (Cntexmp_Line_Str, Elt.Name);
            if Elt.Kind /= CEE_Error_Msg then
               Append (Cntexmp_Line_Str, " = ");
               Append (Cntexmp_Line_Str, Elt.Val_Str);
            end if;
         end loop;
         return To_String (Cntexmp_Line_Str);
      end Get_Cntexmp_Line_Str;

      File : constant String := File_Name (VC_Loc);
      Line : constant Logical_Line_Number := Get_Logical_Line_Number (VC_Loc);
      File_Cur : constant Cntexample_File_Maps.Cursor := Cntexmp.Find (File);
      Cntexmp_Line : Cntexample_Elt_Lists.List :=
        Cntexample_Elt_Lists.Empty_List;

   --  Start of processing for Get_Cntexmp_One_Liner

   begin
      if Cntexample_File_Maps.Has_Element (File_Cur) then
         declare
            Line_Map : Cntexample_Line_Maps.Map renames
              Cntexmp (File_Cur).Other_Lines;
            Line_Cur : constant Cntexample_Line_Maps.Cursor :=
              Line_Map.Find (Natural (Line));
         begin
            if Cntexample_Line_Maps.Has_Element (Line_Cur) then
               Cntexmp_Line := Line_Map (Line_Cur);
            end if;
         end;
      end if;
      return Get_Cntexmp_Line_Str (Cntexmp_Line);
   end Get_Cntexmp_One_Liner;

   ----------------------
   -- Is_Ada_File_Name --
   ----------------------

   function Is_Ada_File_Name (File : String) return Boolean is
   begin
      return
        File'Length >= 4 and then
        (File ((File'Last - 2) .. File'Last) in "adb" | "ads");
   end Is_Ada_File_Name;

   ----------------------
   -- Is_Uninitialized --
   ----------------------

   function Is_Uninitialized
     (Element_Decl : Entity_Id;
      Element_File : String;
      Element_Line : Natural)
      return Boolean
   is
   begin
      --  Counterexample element can be uninitialized only if its location
      --  is the same as location of its declaration (otherwise it has been
      --  assigned or it is a part of construct that triggers VC - and flow
      --  analysis would issue an error in this case).

      if File_Name (Sloc (Element_Decl)) = Element_File
        and then
          Natural
            (Get_Logical_Line_Number (Sloc (Element_Decl))) = Element_Line
      then
         case Nkind (Parent (Element_Decl)) is
            --  Uninitialized variable
            when N_Object_Declaration =>
               declare
                  Init_Expr : constant Node_Id :=
                    Expression (Parent (Element_Decl));
                  No_Default_Init : constant Boolean :=
                    Default_Initialization
                      (Etype (Element_Decl), Get_Flow_Scope (Element_Decl)) =
                        No_Default_Initialization;
               begin
                  return No (Init_Expr)
                    and then No_Default_Init;
               end;

            --  Uninitialized function argument
            when N_Formal_Object_Declaration
               | N_Parameter_Specification
            =>
               return
                 Out_Present (Parent (Element_Decl))
                 and then not In_Present (Parent (Element_Decl));
               --  ??? Ekind (Element_Decl) = E_Out_Parameter ?

            when others =>
               return False;
         end case;

      end if;

      return False;
   end Is_Uninitialized;

   -----------------------------
   -- Print_CNT_Element_Debug --
   -----------------------------

   function Print_CNT_Element_Debug (El : CNT_Element) return String is
      R : Unbounded_String := "[ " & El.Val_Str & " | ";
   begin
      for F in El.Fields.Iterate loop
         Append (R, "<F- " & CNT_Elements.Key (F) &
                    " = " &
                    Print_CNT_Element_Debug (CNT_Elements.Element (F).all) &
                    " -F>");
      end loop;

      for F in El.Attributes.Iterate loop
         Append (R, "<A- " & CNT_Elements.Key (F) &
                    " = " &
                    Print_CNT_Element_Debug (CNT_Elements.Element (F).all) &
                    " -A>");
      end loop;

      return To_String (R & " ]");
   end Print_CNT_Element_Debug;

   -------------------
   -- Remap_VC_Info --
   -------------------

   function Remap_VC_Info
     (Cntexmp : Cntexample_File_Maps.Map;
      VC_File : String;
      VC_Line : Natural)
      return Cntexample_File_Maps.Map
   is
      Remapped_Cntexmp : Cntexample_File_Maps.Map := Cntexmp;

      C        : Cntexample_File_Maps.Cursor;
      Inserted : Boolean;
      VC       : Cntexample_Elt_Lists.List;

   begin
      --  Search for VC_Line (there is only one). It can be in any file,
      --  depending on the location used by Why3 (when checking that a
      --  predicate holds, it sometimes uses the location of the predicate
      --  instead of the location where it is called).

      for Elt of Remapped_Cntexmp loop
         if not Elt.VC_Line.Is_Empty then
            pragma Assert (VC.Is_Empty);
            VC := Elt.VC_Line;
            Elt.VC_Line.Clear;
         end if;
      end loop;

      --  Insert it at the appropriate location in Remapped_Cntexmp, possibly
      --  deleting other information in the process.

      Remapped_Cntexmp.Insert
        (Key      => VC_File,
         New_Item => (Other_Lines => Cntexample_Line_Maps.Empty_Map,
                      VC_Line     => Cntexample_Elt_Lists.Empty_List),
         Position => C,
         Inserted => Inserted);

      Remapped_Cntexmp (C).Other_Lines.Include (VC_Line, VC);

      return Remapped_Cntexmp;
   end Remap_VC_Info;

end Gnat2Why.Counter_Examples;
