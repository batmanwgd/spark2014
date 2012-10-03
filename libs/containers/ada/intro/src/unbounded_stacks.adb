with Ada.Assertions;  use Ada.Assertions;
with Ada.Exceptions;  use Ada.Exceptions;
with Ada.Text_IO;  use Ada.Text_IO;
package body Unbounded_Stacks is

   function Create return Stack  is
      output : Stack;
   begin
      output.Cont_Ptr := new Content_Type (1 .. Chunk_Size);
      output.Index := 1;
      return output;
   end Create;

   procedure Enlarge (S : in out Stack) is
      New_Ptr : Content_Ref;
      Old_Used_Elements : Natural := S.Index - 1;
   begin
      Chunk_Size  := S.Cont_Ptr'Length + Chunk_Size;
      New_Ptr := new Content_Type (1 .. Chunk_Size);
      New_Ptr (1 .. Old_Used_Elements) := S.Cont_Ptr (1 .. Old_Used_Elements);
      Free_Content (S.Cont_Ptr);
      S.Cont_Ptr := New_Ptr;
   end Enlarge;

   function Is_Empty (S : Stack) return Boolean is
   begin
      if 1 = S.Index then
         return True;
      else
         return False;
      end if;
   end Is_Empty;

   function Is_Full (S : Stack) return Boolean is
   begin
      if S.Cont_Ptr'Length = S.Index - 1 then
         --  cause index points to the first free empty cell
         return True;
      else
         return False;
      end if;
   end Is_Full;

   function Peek (S : Stack) return Item_Type is
   begin
      return S.Cont_Ptr (S.Index - 1);
   end Peek;

   --  push a new element on the stack
   function Pop (S : in out Stack) return Item_Type is
      output : Item_Type;
   begin
      Pop (S, output);
      return output;
   end Pop;

   procedure Pop (S : in out Stack; X : out Item_Type)  is
      New_Index : Natural := S.Index - 1;
   begin
      X := S.Cont_Ptr (New_Index);
      S.Index := New_Index;
   end Pop;

   function Push (S : Stack; X : Item_Type) return Stack is
      output : Stack := S;
   begin
      if Is_Full (output) then
         Enlarge (output);
      end if;
      output.Cont_Ptr (S.Index) := X;
      output.Index := S.Index + 1;

      return output;
   end Push;

   procedure Push (S : in out Stack; X : Item_Type) is
   begin
      if Is_Full (S) then
         Enlarge (S);
      end if;
      S.Cont_Ptr (S.Index) := X;
      S.Index := S.Index + 1;
   end Push;

   procedure Adjust (Object : in out Stack) is
   begin
      Put_Line (Item => "Adjust.Object.Cont_Ptr'Length: "
                & Integer'Image (Object.Cont_Ptr'Length));
      Put_Line (Item => "Adjust.Object.Index: "
                & Integer'Image (Object.Index));
      Put_Line (Item => "Adjust.Object.Cuenta: "
                & Integer'Image (Object.Cuenta));
      Tmp_Ptr := new Content_Type (1 .. Object.Cont_Ptr'Length);
      Tmp_Ptr.all := Object.Cont_Ptr.all;
      --  Object.Cont_Ptr := Tmp_Ptr;
   end Adjust;
   procedure Initialize (Object : in out Stack) is
   begin
      Counter := Counter + 1;
      Object.Cuenta := Counter;
      Put_Line (Item => "Initialize.Object.Cuenta: "
                & Integer'Image (Object.Cuenta));
   end Initialize;
   procedure Finalize (Object : in out Stack) is
   begin
      Put_Line (Item => "Finalize.Object.Cont_Ptr'Length: "
                & Integer'Image (Object.Cont_Ptr'Length));
      Put_Line (Item => "Finalize.Object.Index: "
                & Integer'Image (Object.Index));
      Put_Line (Item => "Finalize.Object.Cuenta: "
                & Integer'Image (Object.Cuenta));
      if Object.Cont_Ptr'Length /= 0 then
         Free_Content (Object.Cont_Ptr);
      end if;
      Free_Content (Tmp_Ptr);
   end Finalize;

end Unbounded_Stacks;
