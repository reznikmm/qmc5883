--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Ada.Unchecked_Conversion;

package body QMC5883.Internal is

   -------------------
   -- Check_Chip_Id --
   -------------------

   function Check_Chip_Id (Device : Device_Context) return Boolean is
      use type HAL.UInt8;

      Ok   : Boolean;
      Data : HAL.UInt8_Array (16#0D# .. 16#0D#);
   begin
      Read (Device, Data, Ok);

      return Ok and Data (Data'First) = 16#FF#;
   end Check_Chip_Id;

   ---------------
   -- Configure --
   ---------------

   procedure Configure
     (Device  : Device_Context;
      Value   : Sensor_Configuration;
      Success : out Boolean)
   is
      use type HAL.UInt8;

      type Control_Register is record
         Mode     : Natural range 0 .. 3;
         ODR      : Natural range 0 .. 3;
         RNG      : Natural range 0 .. 3;
         OSR      : Natural range 0 .. 3;
      end record;

      for Control_Register use record
         Mode     at 0 range 0 .. 1;
         ODR      at 0 range 2 .. 3;
         RNG      at 0 range 4 .. 5;
         OSR      at 0 range 6 .. 7;
      end record;

      function Cast_Control is new Ada.Unchecked_Conversion
        (Control_Register, HAL.UInt8);

      Mode : constant Natural := Operating_Mode'Pos (Value.Mode);

      ODR  : constant Natural :=
        (case Value.Data_Rate is
            when 10 => 0,
            when 50 => 1,
            when 100 => 2,
            when 200 => 3);

      RNG : constant Natural := Boolean'Pos (Value.Full_Range = 8);

      OSR : constant Natural :=
        (case Value.Over_Sample is
            when 512 => 0,
            when 256 => 1,
            when 128 => 2,
            when 64 => 3);

      Data : constant HAL.UInt8_Array (16#09# .. 16#09#) :=
        (09 => Cast_Control
           ((Mode => Mode, ODR => ODR, RNG => RNG, OSR => OSR)));
   begin
      Write (Device, Data, Success);
   end Configure;

   -------------------
   -- Is_Data_Ready --
   -------------------

   function Is_Data_Ready (Device  : Device_Context) return Boolean is
      use type HAL.UInt8;

      Ok   : Boolean;
      Data : HAL.UInt8_Array (06 .. 06);
   begin
      Read (Device, Data, Ok);

      return Ok and (Data (Data'First) and 1) /= 0;
   end Is_Data_Ready;

   ----------------------
   -- Read_Measurement --
   ----------------------

   procedure Read_Measurement
     (Device     : Device_Context;
      Full_Range : Full_Scale_Range;
      Value      : out Magnetic_Field_Vector;
      Success    : out Boolean)
   is
      Raw   : Raw_Vector;
   begin
      Read_Raw_Measurement (Device, Raw, Success);

      Value :=
        (X => Magnetic_Field'Small * Integer (Raw.X),
         Y => Magnetic_Field'Small * Integer (Raw.Y),
         Z => Magnetic_Field'Small * Integer (Raw.Z));

      if Full_Range = 8 then
         Value :=
           (X => Value.X * 4,
            Y => Value.Y * 4,
            Z => Value.Z * 4);
      end if;
   end Read_Measurement;

   ----------------------
   -- Read_Measurement --
   ----------------------

   procedure Read_Raw_Measurement
     (Device  : Device_Context;
      Value   : out Raw_Vector;
      Success : out Boolean)
   is
      use Interfaces;

      function Cast is new Ada.Unchecked_Conversion
        (Unsigned_16, Integer_16);

      function Decode (Data : HAL.UInt8_Array) return Integer_16 is
         (Cast (Shift_Left (Unsigned_16 (Data (Data'Last)), 8)
            + Unsigned_16 (Data (Data'First))));

      Data : HAL.UInt8_Array (0 .. 5);
   begin
      Read (Device, Data, Success);

      if Success then
         Value :=
           (X => Decode (Data (0 .. 1)),
            Y => Decode (Data (2 .. 3)),
            Z => Decode (Data (4 .. 5)));
      else
         Value := (X | Y | Z => 0);
      end if;
   end Read_Raw_Measurement;

   -----------
   -- Reset --
   -----------

   procedure Reset
     (Device  : Device_Context;
      Success : out Boolean) is
   begin
      Write (Device, (16#0A# => 16#80#, 16#0B# => 16#01#), Success);
   end Reset;

end QMC5883.Internal;
