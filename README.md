# FIADS

> 本系统是中山大学电信院硬件描述语言与FPGA设计课程的期末实验设计
>
> 参考：粟涛老师的实验指导书
>
> Copyright (C) GeorgeDong32. All rights reserved.

  <p align="center">
    <a href="./README-EN.md">English</a>
    |
    <a href="./README.md">简体中文</a>
   </p>

基于FPGA的图像采集与显示系统（FIADS），由DIGILENT Nexys A7开发板和OV7670组成，通过VGA接口输出显示数据。

## 配置清单

* DIGILENT Nexys A7开发板，固件型号为`xc7a100tcsg324-1`
* OV7670摄像头模块，无需FIFO
* VIVADO 2022.2 ML Edition

## 系统结构

![image-20230703110416659](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031104808.png)

### 注意

系统中BRAM、PLL为IP核，需按以下说明配置，不包含在仓库代码中。

#### BRAM配置

* IP名称：`Block Memory Generator`
* 生成的模块名称：BRAM
* 类型：Simple Dual Port RAM
* Port A：
  * Width：12
  * Depth：76800
  * Enable Pin Type：`Always Enable`
  * Operating Mode：`No Change`
* Port B:
  * Width：12
  * Enable Pin Type：`Always Enable`
  * Operating Mode：`Write First`
* 其余保持默认即可

#### PLL配置

* IP名称：`Clocking Wizard`
* 生成的模块名称：pll
* Output Clock：仅勾选clk_out1，频率设置为25MHz，并在下方取消勾选 `reset` 和 `locked`
* 其余保持默认即可

## 仿真验证

使用 `testbench` 文件夹中的测试代码即可进行测试，项目中已经添加的测试资源可能需要修改配置才能重新完成各部分测试。

测试波形如下：

### 采集模块测试

![image-20230703115025971](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031150096.png)

![image-20230703115035757](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031150838.png)

### 显示模块测试

![image-20230703115102717](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031151799.png)

### 顶层模块测试

![image-20230703115127466](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031151535.png)

## 最终效果

![image-20230703115407957](https://raw.githubusercontent.com/GeorgeDong32/PicGo-Storage/main/202307031154435.png)

## License

Repository is under CC BY-NC-SA License.

本作品采用 <a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/">知识共享署名-非商业性使用-相同方式共享 4.0 国际许可协议</a> 进行许可。<br />
<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="知识共享许可协议" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a>
