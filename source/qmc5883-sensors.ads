--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

--  This package offers a straightforward method for setting up the QMC5883L
--  when connected via I2C, especially useful when you need multiple sensors
--  of this kind. If you use only one sensor, it could be preferable to use the
--  QMC5883L.Sensor generic package.

with HAL.I2C;

package QMC5883.Sensors is

   type QMC5883_Sensor
     (I2C_Port : not null HAL.I2C.Any_I2C_Port) is tagged limited private;

   function Check_Chip_Id (Self : QMC5883_Sensor) return Boolean;
   --  Read the chip ID and check that it matches the expected value.

   procedure Reset
     (Self    : in out QMC5883_Sensor;
      Success : out Boolean);
   --  Soft reset, restore default value of all registers.

   procedure Configure
     (Self    : in out QMC5883_Sensor;
      Value   : Sensor_Configuration;
      Success : out Boolean);
   --  Setup sensor configuration, including
   --  * Over sample rate
   --  * Output data rate
   --  * Full scale field range
   --  * Operating mode

   function Is_Data_Ready (Self : QMC5883_Sensor) return Boolean;
   --  Check if the operating mode is idle

   procedure Read_Measurement
     (Self    : QMC5883_Sensor;
      Value   : out Magnetic_Field_Vector;
      Success : out Boolean);
   --  Read scaled measurement values from the sensor

   procedure Read_Raw_Measurement
     (Self    : QMC5883_Sensor;
      Value   : out Raw_Vector;
      Success : out Boolean);
   --  Read the raw measurement values from the sensor

private

   type QMC5883_Sensor
     (I2C_Port : not null HAL.I2C.Any_I2C_Port) is tagged limited
   record
      Full_Range : Full_Scale_Range := 2;
   end record;

end QMC5883.Sensors;
