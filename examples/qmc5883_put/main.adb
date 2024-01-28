--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Ada.Real_Time;
with Ada.Text_IO;

with Ravenscar_Time;

with STM32.Board;
with STM32.Device;
with STM32.Setup;

with HAL.I2C;

with QMC5883.Sensor;

procedure Main is
   use type Ada.Real_Time.Time;

   package QMC5883_I2C is new QMC5883.Sensor
     (I2C_Port => STM32.Device.I2C_1'Access);

   Ok     : Boolean := False;
   Vector : array (1 .. 16) of QMC5883.Magnetic_Field_Vector;
   Prev   : Ada.Real_Time.Time;
   Spin   : Natural;
begin
   STM32.Board.Initialize_LEDs;
   STM32.Setup.Setup_I2C_Master
     (Port        => STM32.Device.I2C_1,
      SDA         => STM32.Device.PB9,
      SCL         => STM32.Device.PB8,
      SDA_AF      => STM32.Device.GPIO_AF_I2C1_4,
      SCL_AF      => STM32.Device.GPIO_AF_I2C1_4,
      Clock_Speed => 400_000);

   declare
      Status : HAL.I2C.I2C_Status;
   begin
      --  Workaround for STM32 I2C driver bug
      STM32.Device.I2C_1.Master_Transmit
        (Addr    => 16#1A#,  --  0D * 2
         Data    => (1 => 16#0D#),  --  Chip ID for QMC5883L
         Status  => Status);
   end;

   --  Look for QMC5883L chip
   if not QMC5883_I2C.Check_Chip_Id then
      Ada.Text_IO.Put_Line ("QMC5883L not found.");
      raise Program_Error;
   end if;

   --  Reset QMC5883L
   QMC5883_I2C.Reset (Ok);
   pragma Assert (Ok);

   --  Set QMC5883L up
   QMC5883_I2C.Configure
     ((Over_Sample => 512,
       Data_Rate   => 10,
       Full_Range  => 2,
       Mode        => QMC5883.Continuous),
      Ok);
   pragma Assert (Ok);

   loop
      Prev := Ada.Real_Time.Clock;
      Spin   := 0;
      STM32.Board.Toggle (STM32.Board.D1_LED);

      for J in Vector'Range loop

         while not QMC5883_I2C.Is_Data_Ready loop
            Spin   := Spin + 1;
         end loop;

         --  Read scaled values from the sensor
         QMC5883_I2C.Read_Measurement (Vector (J), Ok);
         pragma Assert (Ok);
      end loop;

      --  Printing...
      declare
         Now  : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
         Diff : constant Duration := Ada.Real_Time.To_Duration (Now - Prev);
      begin
         Ada.Text_IO.New_Line;
         Ada.Text_IO.New_Line;
         Ada.Text_IO.Put_Line
           ("Time=" & Diff'Image & "/16 spin=" & Spin'Image);

         for Value of Vector loop
            declare
               X : constant String := Value.X'Image;
               Y : constant String := Value.Y'Image;
               Z : constant String := Value.Z'Image;
            begin
               Ada.Text_IO.Put_Line ("X=" & X & " Y=" & Y & " Z=" & Z);
            end;
         end loop;

         Ada.Text_IO.Put_Line ("Sleeping 2s...");
         Ravenscar_Time.Delays.Delay_Seconds (2);
      end;
   end loop;
end Main;
