# QMC5883

[![Build status](https://github.com/reznikmm/qmc5883/actions/workflows/alire.yml/badge.svg)](https://github.com/reznikmm/qmc5883/actions/workflows/alire.yml)
[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/qmc5883.json)](https://alire.ada.dev/crates/qmc5883.html)
[![REUSE status](https://api.reuse.software/badge/github.com/reznikmm/qmc5883)](https://api.reuse.software/info/github.com/reznikmm/qmc5883)

> Driver for QMC5883L magnetic sensor.

- [Datasheet](https://www.qstcorp.com/en_comp_prod/QMC5883L)

The sensor is available as a module for DIY projects from various
manufacturers, such as
[GY-273](https://www.aliexpress.com/item/1005006314447353.html).
It boasts 2 milli-gauss resolution, low power consumption, a compact size,
and up to 200 Hz output rate.

The QMC5883L driver enables the following functionalities:

- Detect the presence of the sensor.
- Perform soft reset
- Configure the sensor (over smaple rate, output data rate, full scale range)
- Conduct measurements as raw 16-bit values and scaled values.

## Install

Add `qmc5883` as a dependency to your crate with Alire:

    alr with qmc5883

## Usage

The driver implements two usage models: the generic package, which is more
convenient when dealing with a single sensor, and the tagged type, which
allows easy creation of objects for any number of sensors and uniform handling.

Generic instantiation looks like this:

```ada
declare
   package QMC5883_I2C is new QMC5883.Sensor
     (I2C_Port => STM32.Device.I2C_1'Access);

begin
   if QMC5883_I2C.Check_Chip_Id then
      ...
```

While declaring object of the tagged type looks like this:

```ada
declare
   Sensor : QMC5883.Sensors.QMC5883_Sensor
     (I2C_Port => STM32.Device.I2C_1'Access);
begin
   if Sensor.Check_Chip_Id then
      ...
```

### Sensor Configuration

To configure the sensor, use the Configure procedure by passing the settings
(`Sensor_Configuration` type).

Settings include:

- `Over_Sample`: Over Sample Rate - bandwidth of an internal digital filter

- `Data_Rate`: Output Data Rate - desired measurement frequency from
  a predefined list of values (10Hz, 50Hz, 100Hz and 200Hz).

- `Full_Range`: Full Scale Range - sensor sensitivity (and resolution)
  +/- 2 Gauss or +/- 8 Gauss.

- `Mode`: Switch between standby mode and continuous measurement mode.

An example:
```ada
Sensor.Configure
  ((Over_Sample => 512,
    Data_Rate   => 50,
    Full_Range  => 8,
    Mode        => QMC5883.Continuous),
   Ok);
```

### Read Measurement

The best way to determine data readiness is through interrupts using
a separate pin. Otherwise you can ascertain that the data is ready by
waiting while `Is_Data_Ready` returns `True`.

Read raw data (as provided by the sensor) with the `Read_Raw_Measurement`
procedure.

Calling `Read_Measurement` returns scaled measurements in Gauss based on
the current `Full_Range` setting.

## Examples

Examples use `Ada_Drivers_Library`. It's installed by Alire (alr >= 2.1.0 required).
Run Alire to build:

    alr -C examples build

### GNAT Studio

Launch GNAT Studio with Alire:

    alr -C examples exec gnatstudio -- -P qmc5883_put/qmc5883_put.gpr

### VS Code

Make sure `alr` in the `PATH`.
Open the `examples` folder in VS Code. Use pre-configured tasks to build
projects and flash (openocd or st-util). Install Cortex Debug extension
to launch pre-configured debugger targets.

- [Simple example for STM32 F4VE board](examples/qmc5883_put) - complete
  example for the generic instantiation.
- [Advanced example for STM32 F4VE board and LCD & touch panel](examples/qmc5883_lcd) -
  complete example of the tagged type usage.
