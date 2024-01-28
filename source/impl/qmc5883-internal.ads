--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with HAL;

generic
   type Device_Context (<>) is limited private;

   with procedure Read
     (Device  : Device_Context;
      Data    : out HAL.UInt8_Array;
      Success : out Boolean);
   --  Read the values from the QMC5883L chip registers into Data.
   --  Each element in the Data corresponds to a specific register address
   --  in the chip, so Data'Range determines the range of registers to read.
   --  The value read from register X will be stored in Data(X), so
   --  Data'Range should be of the Register_Address subtype.

   with procedure Write
     (Device  : Device_Context;
      Data    : HAL.UInt8_Array;
      Success : out Boolean);
   --  Write the Data values to the QMC5883L chip registers.
   --  Each element in the Data corresponds to a specific register address
   --  in the chip, so Data'Range determines the range of registers to write.
   --  The value read from Data(X) will be stored in register X, so
   --  Data'Range should be of the Register_Address subtype.

package QMC5883.Internal is

   function Check_Chip_Id (Device : Device_Context) return Boolean;
   --  Read the chip ID and check that it matches

   procedure Configure
     (Device  : Device_Context;
      Value   : Sensor_Configuration;
      Success : out Boolean);
   --  Write Configuration Registers (00, 01)

   procedure Reset
     (Device  : Device_Context;
      Success : out Boolean);
   --  Write Mode Register (02)

   function Is_Data_Ready (Device  : Device_Context) return Boolean;
   --  Check if the operating mode is idle

   procedure Read_Measurement
     (Device     : Device_Context;
      Full_Range : Full_Scale_Range;
      Value      : out Magnetic_Field_Vector;
      Success    : out Boolean);
   --  Read scaled measurement values from the sensor

   procedure Read_Raw_Measurement
     (Device  : Device_Context;
      Value   : out Raw_Vector;
      Success : out Boolean);
   --  Read the raw measurement values from the sensor

end QMC5883.Internal;
