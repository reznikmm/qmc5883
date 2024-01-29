--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Interfaces;

package QMC5883 is
   pragma Preelaborate;
   pragma Discard_Names;

   type Over_Sample_Rate is range 64 .. 512
     with Static_Predicate => Over_Sample_Rate in 64 | 128 | 256 | 512;
   --  Over Sample Rate (OSR) is used to control bandwidth of an internal
   --  digital filter. Larger OSR value leads to smaller filter bandwidth,
   --  less in-band noise and higher power consumption. It could be used
   --  to reach a good balance between noise and power.

   type Output_Data_Rate is range 10 .. 200
     with Static_Predicate => Output_Data_Rate in 10 | 50 | 100 | 200;
   --  Output data rate is controlled by the configuration. Four data update
   --  frequencies can be selected: 10Hz, 50Hz, 100Hz and 200Hz. For most of
   --  compassing applications, we recommend 10 Hz for low power consumption.
   --  For gaming, the high update rate such as 100Hz or 200Hz can be used.

   type Full_Scale_Range is range 2 .. 8
     with Static_Predicate => Full_Scale_Range in 2 | 8;
   --  Field ranges of the magnetic sensor can be selected through the
   --  configuration. The full scale field range is determined by the
   --  application environments. For magnetic clear environment, low field
   --  range such as +/-2 Gauss can be used. The field range goes hand in hand
   --  with the sensitivity of the magnetic sensor. The lowest field range has
   --  the highest sensitivity, therefore, higher resolution

   type Operating_Mode is (Standby, Continuous);
   --  The Operating Mode

   type Sensor_Configuration is record
      Over_Sample : Over_Sample_Rate := 512;
      Data_Rate   : Output_Data_Rate := 10;
      Full_Range  : Full_Scale_Range := 2;
      Mode        : Operating_Mode := Standby;
   end record;

   type Magnetic_Field is delta 1.0 / 2.0 ** 14 range -8.0 .. 8.0;
   --  Magnetic flux density in Gauss

   type Magnetic_Field_Vector is record
      X, Y, Z : Magnetic_Field;
   end record;

   type Raw_Vector is record
      X, Y, Z : Interfaces.Integer_16;
   end record;
   --  A value read from the sensor in raw format. The output data of each
   --  channel saturates at -32768 and 32767.

private

   I2C_Address : constant := 16#0D#;

end QMC5883;
