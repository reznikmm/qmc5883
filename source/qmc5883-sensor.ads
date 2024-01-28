--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

--  This package offers a straightforward method for setting up the QMC5883L
--  when connected via I2C, especially useful when the use of only one sensor
--  is required. If you need multiple sensors, it is preferable to use the
--  QMC5883.I2C_Sensors package, which provides the appropriate tagged type.

with HAL.I2C;

generic
   I2C_Port : not null HAL.I2C.Any_I2C_Port;
package QMC5883.Sensor is

   function Check_Chip_Id return Boolean;
   --  Read the chip ID and check that it matches the expected value.

   procedure Reset (Success : out Boolean);
   --  Soft reset, restore default value of all registers.

   procedure Configure
     (Value   : Sensor_Configuration;
      Success : out Boolean);
   --  Setup sensor configuration, including
   --  * Over sample rate
   --  * Output data rate
   --  * Full scale field range
   --  * Operating mode

   function Is_Data_Ready return Boolean;
   --  Data Ready flag it is set when all three axis data is ready, and loaded
   --  to the output data registers in the continuous measurement mode. It is
   --  reset by reading the measurement.

   procedure Read_Measurement
     (Value   : out Magnetic_Field_Vector;
      Success : out Boolean);
   --  Read scaled measurement values from the sensor

   procedure Read_Raw_Measurement
     (Value   : out Raw_Vector;
      Success : out Boolean);
   --  Read the raw measurement values from the sensor

end QMC5883.Sensor;
