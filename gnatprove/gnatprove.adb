------------------------------------------------------------------------------
--                                                                          --
--                            GNATPROVE COMPONENTS                          --
--                                                                          --
--                            G N A T P R O V E                             --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                       Copyright (C) 2010-2014, AdaCore                   --
--                                                                          --
-- gnatprove is  free  software;  you can redistribute it and/or  modify it --
-- under terms of the  GNU General Public License as published  by the Free --
-- Software  Foundation;  either version 3,  or (at your option)  any later --
-- version.  gnatprove is distributed  in the hope that  it will be useful, --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of  MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.  You should have  received  a copy of the GNU --
-- General Public License  distributed with  gnatprove;  see file COPYING3. --
-- If not,  go to  http://www.gnu.org/licenses  for a complete  copy of the --
-- license.                                                                 --
--                                                                          --
-- gnatprove is maintained by AdaCore (http://www.adacore.com)              --
--                                                                          --
------------------------------------------------------------------------------

--  This program (gnatprove) is the command line interface of the SPARK 2014
--  tools. It works in four steps:
--
--  1) Compute ALI information
--     This step generates, for all relevant units, the ALI files, which
--     contain the computed effects for all subprograms and packages.
--  2) Translate_To_Why
--     ??? change name of that subprogram
--     This step does all the SPARK analyses except proof. The tool "gnat2why"
--     is called on all units. The analyses done by gnat2why are
--     SPARK_Mode and Flow analysis. gnat2why also translates the SPARK code to
--     Why3.
--  3) Compute_VCs
--     ??? change the name of that subprogram
--     This step calls "gnatwhy3" on the Why3 files generated in step 2. This
--     will do the proofs and report proof messages.
--  4) Call SPARK_Report. The previous steps have generated extra information,
--     which is read in by the spark_report tool, and aggregated to a report.
--     See the documentation of spark_report.adb for the details.

--  ------------------------
--  - Incremental Analysis -
--  ------------------------

--  Gnatprove wants to achieve minimal work when rerun after a few changes to
--  the project, while keeping the analysis correct. Two different mechanisms
--  are used to achieve this:
--    - gprbuild facilities for incremental compilation
--    - Why3 session mechanism

--  Gprbuild is capable of only recompiling files that actually need
--  recompiling. As we use gprbuild, and as gnat2why acts as a compiler, there
--  is nothing special to do to benefit from this, except that its dependency
--  model is slightly different. This is taken into account by specifying the
--  mode "ALI_Closure" as Dependency_Kind in the first phase of gnatprove.
--  We also use gprbuild with the "-s" switch to take into account changes of
--  compilation options. Note that this switch is only relevant in phase 2,
--  because in phase 1 these options are mostly irrelevant (and also option -s
--  wouldn't work because we also pass --no-object-check), and in phase 3 we
--  run gnatwhy3 unconditionally and use the session mechanism.

--  Why3 stores information about which VCs have already be given to a prover,
--  and will not try to rerun the prover when nothing has changed. We benefit
--  from that directly, and run gnatwhy3 unconditionally.

with Ada.Directories;    use Ada.Directories;
with Ada.Environment_Variables;
with Ada.Strings.Unbounded;
with Ada.Text_IO;        use Ada.Text_IO;
with Call;               use Call;
with Configuration;      use Configuration;
with Opt;

with GNAT.OS_Lib;
with GNAT.Strings;       use GNAT.Strings;

with GNATCOLL.Projects;  use GNATCOLL.Projects;
with GNATCOLL.VFS;       use GNATCOLL.VFS;
with GNATCOLL.Utils;     use GNATCOLL.Utils;

with String_Utils;       use String_Utils;

with Gnat2Why_Args;

procedure Gnatprove is

   type Gnatprove_Step is (GS_ALI, GS_Gnat2Why, GS_Why);

   function Step_Image (S : Gnatprove_Step) return String is
      (Int_Image (Gnatprove_Step'Pos (S) + 1));

   function Final_Step return Gnatprove_Step is
     (case MMode is
       when GPM_Check | GPM_Flow => GS_Gnat2Why,
       when GPM_Prove | GPM_All => GS_Why);

   procedure Call_Gprbuild
      (Project_File : String;
       Config_File  : String;
       Parallel     : Integer;
       RTS_Dir      : String;
       Args         : in out String_Lists.List;
       Status       : out Integer);
   --  Call gprbuild with the given arguments. Pass in explicitly a number of
   --  parallel processes, so that we can force sequential execution when
   --  needed.

   procedure Compute_ALI_Information
      (Project_File : String;
       Proj         : Project_Tree;
       Status : out Integer);
   --  Compute ALI information for all source units, using gnatmake.

   procedure Compute_VCs (Proj     : Project_Tree;
                          Status   : out Integer);
   --  Compute Verification conditions using Why, driven by gprbuild.

   procedure Execute_Step
      (Step         : Gnatprove_Step;
       Project_File : String;
       Proj         : Project_Tree);

   procedure Generate_SPARK_Report
     (Obj_Dir : String;
      Obj_Path  : File_Array);
   --  Generate the SPARK report.

   function Report_File_Is_Empty (Filename : String) return Boolean;
   --  Check if the given file is empty

   procedure Generate_Project_File
      (Filename     : String;
       Project_Name : String;
       Source_Files : File_Array_Access);
   --  Generate project file at given place, with given name and source files.

   function Generate_Why_Project_File (Proj : Project_Type)
                                       return String;
   --  Generate project file for Why3 phase. Write the file to disk
   --  and return the file name.

   procedure Generate_Why3_Conf_File
     (Gnatprove_Subdir : String);

   procedure Translate_To_Why
      (Project_File     : String;
       Proj             : Project_Tree;
       Status           : out Integer);
   --  Translate all source units to Why, using gnat2why, driven by gprbuild.

   function Text_Of_Step (Step : Gnatprove_Step) return String;

   procedure Set_Environment;
   --  Set the environment before calling other tools.
   --  In particular, add any needed directories in the PATH and
   --  GPR_PROJECT_PATH env vars.

   function Pass_Extra_Options_To_Gnat2why
      (Translation_Phase : Boolean;
       Obj_Dir           : String) return String;
   --  Set the environment variable which passes some options to gnat2why.
   --  Translation_Phase is False for globals generation, and True for
   --  translation to Why.

   function To_String (Warning : Opt.Warning_Mode_Type) return String;

   -------------------
   -- Call_Gprbuild --
   -------------------

   procedure Call_Gprbuild
      (Project_File : String;
       Config_File  : String;
       Parallel     : Integer;
       RTS_Dir      : String;
       Args         : in out String_Lists.List;
       Status       : out Integer) is
   begin
      if Verbose then
         Args.Prepend ("-v");
      else
         Args.Prepend ("-q");
         Args.Prepend ("-ws");
      end if;

      if Parallel > 1 then
         Args.Prepend ("-j" & Int_Image (Parallel));
      end if;

      if Continue_On_Error then
         Args.Prepend ("-k");
      end if;

      if Force then
         Args.Prepend ("-f");
      end if;

      if All_Projects then
         Args.Prepend ("-U");
      end if;

      Args.Prepend ("-c");

      for Var of Configuration.Scenario_Variables loop
         Args.Prepend (Var);
      end loop;

      if RTS_Dir /= "" then
         Args.Prepend ("--RTS=" & RTS_Dir);
      end if;

      if Project_File /= "" then
         Args.Prepend (Project_File);
         Args.Prepend ("-P");
      end if;

      if Config_File /= "" then
         Args.Prepend ("--config=" & Config_File);
      end if;

      if Debug then
         Args.Prepend ("-dn");
      end if;

      Call_With_Status
        (Command   => "gprbuild",
         Arguments => Args,
         Status    => Status,
         Verbose   => Verbose);
   end Call_Gprbuild;

   -----------------------------
   -- Compute_ALI_Information --
   -----------------------------

   procedure Compute_ALI_Information
     (Project_File : String;
      Proj         : Project_Tree;
      Status       : out Integer)
   is
      use String_Lists;
      Args     : List := Empty_List;
      Obj_Dir  : constant String :=
         Proj.Root_Project.Object_Dir.Display_Full_Name;
      Opt_File : constant String :=
         Pass_Extra_Options_To_Gnat2why
            (Translation_Phase => False,
             Obj_Dir           => Obj_Dir);
      Del_Succ : Boolean;
   begin
      Args.Append ("--subdirs=" & String (Subdir_Name));
      Args.Append ("--restricted-to-languages=ada");
      Args.Append ("--no-object-check");

      for Arg of Cargs_List loop
         Args.Append (Arg);
      end loop;

      --  Keep going after a compilation error in 'check' mode

      if MMode = GPM_Check then
         Args.Append ("-k");
      end if;

      for File of File_List loop
         Args.Append (File);
      end loop;

      Args.Append ("-cargs:Ada");
      Args.Append ("-gnatc");       --  only generate ALI

      Args.Append ("-gnates=" & Opt_File);
      Call_Gprbuild (Project_File,
                     Gpr_Frames_Cnf_File,
                     Parallel,
                     RTS_Dir.all,
                     Args,
                     Status);
      if Status = 0 and then not Debug then
         GNAT.OS_Lib.Delete_File (Opt_File, Del_Succ);
      end if;
   end Compute_ALI_Information;

   -----------------
   -- Compute_VCs --
   -----------------

   procedure Compute_VCs
     (Proj      : Project_Tree;
      Status    : out Integer)
   is
      use Ada.Environment_Variables;
      Proj_Type     : constant Project_Type := Proj.Root_Project;
      Obj_Dir       : constant String :=
         Proj_Type.Object_Dir.Display_Full_Name;
      Why_Proj_File : constant String :=
         Generate_Why_Project_File (Proj_Type);
      Args          : String_Lists.List := String_Lists.Empty_List;
   begin
      Generate_Why3_Conf_File (Obj_Dir);
      if Timeout /= 0 then
         Args.Append ("--timeout");
         Args.Append (Int_Image (Timeout));
      end if;

      --  The steps option is passed to alt-ergo via the why3.conf file. We
      --  still need to pass it to gnatwhy3 as well so that it is aware of the
      --  value of that switch.

      if Steps /= 0 then
         Args.Append ("--steps");
         Args.Append (Int_Image (Steps));
      end if;
      if Verbose then
         Args.Append ("--verbose");
      elsif Quiet then
         Args.Append ("--quiet");
      end if;
      Args.Append ("--report");
      case Report is
         when GPR_Fail =>
            Args.Append ("fail");

         when GPR_Verbose =>
            Args.Append ("all");

         when GPR_Statistics =>
            Args.Append ("statistics");

      end case;
      Args.Append ("--warnings");
      Args.Append (To_String (Warning_Mode));
      if Debug then
         Args.Append ("--debug");
      end if;
      if Force then
         Args.Append ("--force");
      end if;
      if Proof /= Then_Split then
         Args.Append ("--proof");
         Args.Append (To_String (Proof));
      end if;
      if IDE_Progress_Bar then
         Args.Append ("--ide-progress-bar");
      end if;

      Args.Append ("-j");
      Args.Append (Int_Image (Parallel));

      if Limit_Line /= null and then Limit_Line.all /= "" then
         Args.Append ("--limit-line");
         Args.Append (Limit_Line.all);
      end if;
      if Limit_Subp /= null and then Limit_Subp.all /= "" then
         Args.Append ("--limit-subp");
         Args.Append (Limit_Subp.all);
      end if;
      if Alter_Prover /= null and then Alter_Prover.all /= "" then
         Args.Append ("--prover");
         Args.Append (Alter_Prover.all);
      end if;
      if Integer (Args.Length) > 0 then
         Args.Prepend ("-cargs:Why");
      end if;

      --  Always run gnatwhy3 on all files; it will detect itself if it is
      --  necessary to (re)do proofs

      Args.Prepend ("-f");

      if Only_Given then
         for File of File_List loop
            Args.Prepend
              (File (File'First .. File'Last - 4) & ".mlw");
         end loop;
         Args.Prepend ("-u");
      end if;

      --  Force sequential execution of gprbuild, so that gnatwhy3 can run
      --  prover in parallel.

      Set ("TEMP", Obj_Dir);
      Set ("TMPDIR", Obj_Dir);
      Call_Gprbuild (Why_Proj_File,
                     Gpr_Why_Cnf_File,
                     Parallel => 1,
                     RTS_Dir  => RTS_Dir.all,
                     Args     => Args,
                     Status   => Status);
   end Compute_VCs;

   procedure Execute_Step
     (Step         : Gnatprove_Step;
      Project_File : String;
      Proj         : Project_Tree)
   is
      Status : Integer;
   begin
      if not Quiet then
         Put_Line ("Phase " & Step_Image (Step)
                   & " of " & Step_Image (Final_Step)
                   & ": " & Text_Of_Step (Step) & " ...");
      end if;

      case Step is
         when GS_ALI =>
            Compute_ALI_Information (Project_File, Proj, Status);
            if Status /= 0
              and then MMode = GPM_Check
            then
               Status := 0;
            end if;

         when GS_Gnat2Why =>
            Translate_To_Why (Project_File, Proj, Status);
            if Status /= 0
              and then MMode = GPM_Check
            then
               Status := 0;
            end if;

         when GS_Why =>
            Compute_VCs (Proj, Status);

      end case;

      if Status /= 0 then
         Abort_With_Message
           ("gnatprove: error during " & Text_Of_Step (Step) & ", aborting.");
      end if;
   end Execute_Step;

   --------------------------
   -- Report_File_Is_Empty --
   --------------------------

   function Report_File_Is_Empty (Filename : String) return Boolean is
   begin
      --  ??? This is a bit of a hack; we assume that the report file is
      --  basically empty when the character count is very low (but not zero).

      return Ada.Directories.Size (Filename) <= 3;
   end Report_File_Is_Empty;

   ---------------------------
   -- Generate_SPARK_Report --
   ---------------------------

   procedure Generate_SPARK_Report
     (Obj_Dir  : String;
      Obj_Path : File_Array)
   is
      Obj_Dir_File : File_Type;
      Obj_Dir_Fn   : constant String :=
         Ada.Directories.Compose
            (Obj_Dir,
             "gnatprove.alfad");

      Success : Boolean;

   begin
      Create (Obj_Dir_File, Out_File, Obj_Dir_Fn);
      for Index in Obj_Path'Range loop
         Put_Line
            (Obj_Dir_File,
             Obj_Path (Index).Display_Full_Name);
      end loop;
      Close (Obj_Dir_File);

      Call_Exit_On_Failure
        (Command   => "spark_report",
         Arguments => (1 => new String'(Obj_Dir_Fn)),
         Verbose   => Verbose);

      if not Debug then
         GNAT.OS_Lib.Delete_File (Obj_Dir_Fn, Success);
      end if;

      if not Quiet then
         declare
            File : constant String := SPARK_Report_File (Obj_Dir);
         begin
            --  If nothing is in SPARK, the user has probably forgotten to put
            --  a SPARK_Mode pragma somewhere.

            if Report_File_Is_Empty (File) then
               Put_Line
                 (Standard_Error,
                  "warning: no bodies have been analyzed by GNATprove");
               Put_Line
                 (Standard_Error,
                  "enable analysis of a body using SPARK_Mode");
            else
               Put_Line ("Summary logged in " & SPARK_Report_File (Obj_Dir));
            end if;
         end;
      end if;
   end Generate_SPARK_Report;

   ---------------------------
   -- Generate_Project_File --
   ---------------------------

   procedure Generate_Project_File
     (Filename     : String;
      Project_Name : String;
      Source_Files : File_Array_Access)
   is
      File      : File_Type;
      Follow_Up : Boolean := False;
   begin
      Create (File, Out_File, Filename);
      Put (File, "project ");
      Put (File, Project_Name);
      Put_Line (File, " is");
      Put_Line (File, "for Source_Files use (");

      for F of Source_Files.all loop
         if Follow_Up then
            Put_Line (File, ",");
         end if;
         Follow_Up := True;
         Put (File, "   """ & F.Display_Base_Name & """");
      end loop;
      Put_Line (File, ");");
      Put (File, "end ");
      Put (File, Project_Name);
      Put_Line (File, ";");
      Close (File);
   end Generate_Project_File;

   -------------------------------
   -- Generate_Why_Project_File --
   -------------------------------

   function Generate_Why_Project_File
     (Proj : Project_Type) return String
   is
      Why_File_Name : constant String := "why.gpr";
   begin
      Generate_Project_File
        (Why_File_Name,
         "Why",
         Proj.Library_Files (ALI_Ext => ".mlw"));
      return Why_File_Name;
   end Generate_Why_Project_File;

   -----------------------------
   -- Generate_Why3_Conf_File --
   -----------------------------

   procedure Generate_Why3_Conf_File
     (Gnatprove_Subdir : String)
   is
      File : File_Type;
      Filename : constant String :=
         Ada.Directories.Compose (Gnatprove_Subdir, "why3.conf");

      procedure Put_Keyval (Key : String; Value : String);
      procedure Put_Keyval (Key : String; Value : Integer);
      procedure Start_Section (Section : String);

      ----------------
      -- Put_Keyval --
      ----------------

      procedure Put_Keyval (Key : String; Value : String) is
         use Ada.Strings.Unbounded;
         Value_Unb : Unbounded_String := To_Unbounded_String (Value);
      begin
         Replace (Value_Unb, "\", "\\");
         Put (File, Key);
         Put (File, " = """);
         Put (File, To_String (Value_Unb));
         Put_Line (File, """");
      end Put_Keyval;

      procedure Put_Keyval (Key : String; Value : Integer) is
      begin
         Put (File, Key);
         Put (File, " = ");
         Put_Line (File, Int_Image (Value));
      end Put_Keyval;

      -------------------
      -- Start_Section --
      -------------------

      procedure Start_Section (Section : String) is
      begin
         Put (File, "[");
         Put (File, Section);
         Put_Line (File, "]");
      end Start_Section;

      --  begin processing for Generate_Why3_Conf_File
   begin
      Create (File, Out_File, Filename);
      Start_Section ("main");
      Put_Keyval ("loadpath", Ada.Directories.Compose (Why3_Dir, "theories"));
      Put_Keyval ("loadpath", Ada.Directories.Compose (Why3_Dir, "modules"));
      Put_Keyval ("loadpath", Theories_Dir);
      Put_Keyval ("magic", 14);
      Put_Keyval ("memlimit", 0);
      Put_Keyval ("running_provers_max", 2);
      Start_Section ("prover");
      declare
         Altergo_Command : constant String :=
           "why3-cpulimit %t %m -s alt-ergo-gp %f";
      begin
         if Steps /= 0 then
            Put_Keyval ("command",
                        Altergo_Command & " -steps " & Int_Image (Steps));
         else
            Put_Keyval ("command", Altergo_Command);
         end if;
      end;
      Put_Keyval ("driver",
                  Ada.Directories.Compose (Why3_Drivers_Dir,
                                           "alt_ergo.drv"));
      Put_Keyval ("name", "Alt-Ergo for GNATprove");
      Put_Keyval ("shortcut", "altergo-gp");
      Put_Keyval ("version", "0.95");
      Close (File);
   end Generate_Why3_Conf_File;

   ---------------------
   -- Set_Environment --
   ---------------------

   procedure Set_Environment is
      use Ada.Environment_Variables, GNAT.OS_Lib;

      Path_Val : constant String := Value ("PATH", "");
      Gpr_Val  : constant String := Value ("GPR_PROJECT_PATH", "");
      Libgnat  : constant String := Compose (Lib_Dir, "gnat");
      Sharegpr : constant String := Compose (Share_Dir, "gpr");

   begin
      --  Add <prefix>/libexec/spark2014/bin in front of the PATH
      Set ("PATH", Libexec_Bin_Dir & Path_Separator & Path_Val);

      --  Add <prefix>/lib/gnat & <prefix>/share/gpr in GPR_PROJECT_PATH
      --  so that project files installed with GNAT (not with SPARK)
      --  are found automatically, if any.

      Set ("GPR_PROJECT_PATH",
           Libgnat & Path_Separator & Sharegpr & Path_Separator & Gpr_Val);
   end Set_Environment;

   ------------------------------------
   -- Pass_Extra_Options_To_Gnat2why --
   ------------------------------------

   function Pass_Extra_Options_To_Gnat2why
      (Translation_Phase : Boolean;
       Obj_Dir           : String) return String is
   begin

      --  In the translation phase, set a number of values

      if Translation_Phase then
         Gnat2Why_Args.Warning_Mode := Warning_Mode;
         Gnat2Why_Args.Global_Gen_Mode := False;
         Gnat2Why_Args.Flow_Debug_Mode := Debug;
         Gnat2Why_Args.Flow_Advanced_Debug := Flow_Extra_Debug;
         Gnat2Why_Args.Check_Mode := MMode = GPM_Check;
         Gnat2Why_Args.Flow_Analysis_Mode := MMode in GPM_Flow | GPM_All;
         Gnat2Why_Args.Prove_Mode := MMode in GPM_Prove | GPM_All;
         Gnat2Why_Args.Analyze_File := File_List;
         Gnat2Why_Args.Pedantic := Pedantic;
         Gnat2Why_Args.Ide_Mode := IDE_Progress_Bar;
         Gnat2Why_Args.Single_File := Only_Given;
         Gnat2Why_Args.Limit_Subp :=
           Ada.Strings.Unbounded.To_Unbounded_String (Limit_Subp.all);

      --  In the globals generation phase, only set Global_Gen_Mode

      else
         Gnat2Why_Args.Global_Gen_Mode := True;
      end if;

      return Gnat2Why_Args.Set (Obj_Dir);
   end Pass_Extra_Options_To_Gnat2why;

   ------------------
   -- Text_Of_Step --
   ------------------

   function Text_Of_Step (Step : Gnatprove_Step) return String is
   begin
      --  These strings have to make sense when preceded by
      --  "error during ". See the body of procedure Execute_Step.
      case Step is
         when GS_ALI =>
            return "frame condition computation";

         when GS_Gnat2Why =>
            case MMode is
               when GPM_Check =>
                  return "checking of SPARK legality rules";
               when GPM_Flow =>
                  return "analysis of data and information flow";
               when GPM_Prove =>
                  return "translation to intermediate language";
               when GPM_All =>
                  return "analysis and translation to intermediate language";
            end case;

         when GS_Why =>
            return "generation and proof of VCs";

      end case;
   end Text_Of_Step;

   function To_String (Warning : Opt.Warning_Mode_Type) return String is
   begin
      case Warning is
         when Opt.Suppress       => return "off";
         when Opt.Treat_As_Error => return "error";
         when Opt.Normal         => return "on";
      end case;
   end To_String;

   ----------------------
   -- Translate_To_Why --
   ----------------------

   procedure Translate_To_Why
      (Project_File     : String;
       Proj             : Project_Tree;
       Status           : out Integer)
   is
      use String_Lists;
      Cur     : Cursor := First (Cargs_List);
      Args    : String_Lists.List := Empty_List;
      Obj_Dir : constant String :=
         Proj.Root_Project.Object_Dir.Display_Full_Name;
      Opt_File : aliased constant String :=
         Pass_Extra_Options_To_Gnat2why
            (Translation_Phase => True,
             Obj_Dir           => Obj_Dir);
      Del_Succ : Boolean;
   begin
      Args.Append ("--subdirs=" & String (Subdir_Name));
      Args.Append ("--restricted-to-languages=ada");
      Args.Append ("-s");

      for File of File_List loop
         Args.Append (File);
      end loop;

      Args.Append ("-cargs:Ada");
      Args.Append ("-gnatc");       --  No object file generation

      Args.Append ("-gnates=" & Opt_File);

      while Has_Element (Cur) loop
         Args.Append (Element (Cur));
         Next (Cur);
      end loop;

      Call_Gprbuild (Project_File,
                     Gpr_Translation_Cnf_File,
                     Parallel,
                     RTS_Dir.all,
                     Args,
                     Status);
      if Status = 0 and then not Debug then
         GNAT.OS_Lib.Delete_File (Opt_File, Del_Succ);
      end if;
   end Translate_To_Why;

   Tree      : Project_Tree;
   --  GNAT project tree

   Proj_Type : Project_Type;
   --  GNAT project

--  Start processing for Gnatprove

begin
   Set_Environment;
   Read_Command_Line (Tree);
   Proj_Type := Root_Project (Tree);

   Execute_Step (GS_ALI, Project_File.all, Tree);
   Execute_Step (GS_Gnat2Why, Project_File.all, Tree);

   Ada.Directories.Set_Directory (Proj_Type.Object_Dir.Display_Full_Name);

   if MMode in GPM_Prove | GPM_All then
      Execute_Step (GS_Why, Project_File.all, Tree);
   end if;

   declare
      Obj_Path : constant File_Array :=
        Object_Path (Proj_Type, Recursive => True);
   begin
      Generate_SPARK_Report (Proj_Type.Object_Dir.Display_Full_Name, Obj_Path);
   end;
exception
   when Invalid_Project =>
      Abort_With_Message
         ("Error while loading project file: " & Project_File.all);
end Gnatprove;
