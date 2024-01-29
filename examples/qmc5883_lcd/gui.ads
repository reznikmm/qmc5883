--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

pragma Ada_2022;

with GUI_Buttons;
with HAL.Bitmap;
with HAL.Touch_Panel;

package GUI is

   type Button_Kind is
     (Fx, Fy, Fz,       --  Field components
      O1, O2, O3, O4,   --  Over_Sample_Rate
      G2, G8,           --  Full_Scale_Range
      R1, R2, R3, R4);  --  Output_Data_Rate

   function "+" (X : Button_Kind) return Natural is (Button_Kind'Pos (X))
     with Static;

   Buttons : constant GUI_Buttons.Button_Info_Array :=
     [(Label  => "Fx",
       Center => (23 * 1, 20),
       Color  => HAL.Bitmap.Red),
      (Label  => "Fy",
       Center => (23 * 2, 20),
       Color  => HAL.Bitmap.Green),
      (Label  => "Fz",
       Center => (23 * 3, 20),
       Color  => HAL.Bitmap.Blue),
      (Label  => "O1",
       Center => (23 * 1 + 160, 20),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "O2",
       Center => (23 * 2 + 160, 20),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "O3",
       Center => (23 * 3 + 160, 20),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "O4",
       Center => (23 * 4 + 160, 20),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "2G",
       Center => (23 * 1 + 160, 220),
       Color  => HAL.Bitmap.Dim_Grey),
      (Label  => "8G",
       Center => (23 * 2 + 160, 220),
       Color  => HAL.Bitmap.Dim_Grey),
      (Label  => "R1",
       Center => (23, 60 + 1 * 15),
       Color  => HAL.Bitmap.Dark_Grey),
      (Label  => "R2",
       Center => (23, 60 + 2 * 15),
       Color  => HAL.Bitmap.Dark_Grey),
      (Label  => "R3",
       Center => (23, 60 + 3 * 15),
       Color  => HAL.Bitmap.Dark_Grey),
      (Label  => "R4",
       Center => (23, 60 + 4 * 15),
       Color  => HAL.Bitmap.Dark_Grey)];

   State : GUI_Buttons.Boolean_Array (Buttons'Range) :=
     [+Fx | +Fy | +Fz | +O1 | +G2 | +R1 => True, others => False];

   procedure Check_Touch
     (TP     : in out HAL.Touch_Panel.Touch_Panel_Device'Class;
      Update : out Boolean);
   --  Check buttons touched, update State, set Update = True if State changed

   procedure Draw
     (LCD   : in out HAL.Bitmap.Bitmap_Buffer'Class;
      Clear : Boolean := False);

   procedure Dump_Screen (LCD : in out HAL.Bitmap.Bitmap_Buffer'Class);

end GUI;
