--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with QMC5883.Internal;

package body QMC5883.Sensor is

   type Chip_Settings is record
      Full_Range : Full_Scale_Range := 2;
   end record;

   Chip : Chip_Settings;

   procedure Read
     (Ignore  : Chip_Settings;
      Data    : out HAL.UInt8_Array;
      Success : out Boolean);
   --  Read registers starting from Data'First

   procedure Write
     (Ignore  : Chip_Settings;
      Data    : HAL.UInt8_Array;
      Success : out Boolean);
   --  Write registers starting from Data'First

   package Sensor is new Internal (Chip_Settings, Read, Write);

   -------------------
   -- Check_Chip_Id --
   -------------------

   function Check_Chip_Id return Boolean is (Sensor.Check_Chip_Id (Chip));

   ---------------
   -- Configure --
   ---------------

   procedure Configure
     (Value   : Sensor_Configuration;
      Success : out Boolean)
   is
   begin
      Sensor.Configure (Chip, Value, Success);
      Chip.Full_Range := Value.Full_Range;
   end Configure;

   -------------------
   -- Is_Data_Ready --
   -------------------

   function Is_Data_Ready return Boolean is (Sensor.Is_Data_Ready (Chip));

   ----------
   -- Read --
   ----------

   procedure Read
     (Ignore  : Chip_Settings;
      Data    : out HAL.UInt8_Array;
      Success : out Boolean)
   is
      use type HAL.I2C.I2C_Status;
      use type HAL.UInt10;

      Status : HAL.I2C.I2C_Status;
   begin
      I2C_Port.Mem_Read
        (Addr          => 2 * HAL.UInt10 (I2C_Address),
         Mem_Addr      => HAL.UInt16 (Data'First),
         Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
         Data          => Data,
         Status        => Status);

      Success := Status = HAL.I2C.Ok;
   end Read;

   ----------------------
   -- Read_Measurement --
   ----------------------

   procedure Read_Measurement
     (Value   : out Magnetic_Field_Vector;
      Success : out Boolean) is
   begin
      Sensor.Read_Measurement (Chip, Chip.Full_Range, Value, Success);
   end Read_Measurement;

   --------------------------
   -- Read_Raw_Measurement --
   --------------------------

   procedure Read_Raw_Measurement
     (Value   : out Raw_Vector;
      Success : out Boolean) is
   begin
      Sensor.Read_Raw_Measurement (Chip, Value, Success);
   end Read_Raw_Measurement;

   -----------
   -- Reset --
   -----------

   procedure Reset (Success : out Boolean) is
   begin
      Sensor.Reset (Chip, Success);
   end Reset;

   -----------
   -- Write --
   -----------

   procedure Write
     (Ignore  : Chip_Settings;
      Data    : HAL.UInt8_Array;
      Success : out Boolean)
   is
      use type HAL.I2C.I2C_Status;
      use type HAL.UInt10;

      Status : HAL.I2C.I2C_Status;
   begin
      I2C_Port.Mem_Write
        (Addr          => 2 * HAL.UInt10 (I2C_Address),
         Mem_Addr      => HAL.UInt16 (Data'First),
         Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
         Data          => Data,
         Status        => Status);

      Success := Status = HAL.I2C.Ok;
   end Write;

end QMC5883.Sensor;
