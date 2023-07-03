# FIADS

> This system is the final experimental design of the “hardware description language and FPGA design” course of the SEIT of SYSU
>
> Reference: Mr. Su Tao's experimental guidebook
>
> Copyright (C) GeorgeDong32. All rights reserved.

  <p align="center">
    <a href="./README-EN.md">English</a>
    |
    <a href="./README.md">简体中文</a>
   </p>

The FPGA-based Image Acquisition and Display System (FIADS) consists of a DIGILENT Nexys A7 development board and an OV7670 camera module, which is connected through a VGA interface to output display data. The FIADS system is capable of capturing images from the OV7670 camera module and displaying them on the VGA monitor through the Nexys A7 board.

## Configuration List

- DIGILENT Nexys A7 development board with firmware model `xc7a100tcsg324-1`
- OV7670 camera module without FIFO
- VIVADO 2022.2 ML Edition

## System Structure

![image-20230703110416659](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031104808.png)

### Note

The BRAM and PLL in the system are IP Core and need to be configured as follows. They are not included in the repository code.

#### BRAM configuration

* IP name: `Block Memory Generator`
* Generated module name: `BRAM`
* Type: `Simple Dual Port RAM`
* Port A：
  * Width：12
  * Depth：76800
  * Enable Pin Type：`Always Enable`
  * Operating Mode：`No Change`
* Port B:
  * Width：12
  * Enable Pin Type：`Always Enable`
  * Operating Mode：`Write First`
* Leave the rest as default

#### PLL configuration

* IP name: `Clocking Wizard`
* Generated module name: `pll`
* Output Clock: Check only `clk_out1` with the frequency set to 25MHz and uncheck 'reset' and 'locked' below
* Leave the rest as default

## Simulation verification

Test using the test code in the 'testbench' folder, test resources that have already been added to the project may need to modify the configuration to recomplete each part of the test.

The test waveform is as follows:

### Acquisition module test

![image-20230703115025971](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031150096.png)

![image-20230703115035757](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031150838.png)

### Display module test![image-20230703115102717](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031151799.png)

### Top module test

![image-20230703115127466](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031151535.png)

## Final result

![image-20230703115407957](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031154435.png)

## License

This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a>

