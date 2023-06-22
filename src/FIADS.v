module FIADS (
    input clk, //系统时钟100 MHz
    input rst_n, //系统复位
    input vsync, //ov7670模块输入场同步信号
    input href, //ov7670 模块输入行同步信号
    input [7:0] din, //ov7670模块摄像头数据输入
    input pclk, //ov7670模块像素时钟输入
    output scl, //ov7670模块配置SCCB协议时钟线
    inout sda, //ov7670模块配置SCCB 协议数据线
    output xclk, //ov7670模块输入时钟
    output pwdn, //ov7670模块模式选择 0:工作，1:power down
    output reset, //ov7670模块初始化所有寄存器到默认值  0:reset模式，1:一般模式
    output wire [11:0] vga_rgb,//VGA模块图像数据
    output wire vga_hs,//VGA 模块行同步信号
    output wire vga_vs//VGA 模块场同步信号
);

    wire clk_25_MHz;
    wire[11:0] data_rgb444;
    wire [11:0] ram_data_o; //读BRAM 数据
    wire [16:0] ram_addr_i; //写BRAM 地址
    wire [16:0] ram_addr_o; //读BRAM 地址
    wire wr_en;
    assign xclk=clk_25_MHz; //系统时钟为25 MHz
    assign pwdn =1'b0; 
    assign reset=1'b1;

    //例化PLL 
    pll inst_pll(
        .clk_in1(clk),
        .clk_out1(clk_25_MHz)
    );

    //例化图像采集部分顶层模块
    acquisition_module inst_acquisition_module(
        .clk(clk_25_MHz),
        .pclk(pclk),
        .rst_n(rst_n),
        .vsync(vsync),
        .href(href),
        .din(din),
        .scl(scl),
        .sda(sda),
        .data_rgb444(data_rgb444),
        .ram_addr_i(ram_addr_i),
        .wr_en(wr_en)
    );

    //例化 BRAM
    BRAM inst_BRAM(
        .addra(ram_addr_i),
        .clka (pclk),
        .dina (data_rgb444),
        .wea(wr_en),
        .addrb(ram_addr_o),
        .clkb(clk_25_MHz),
        .doutb(ram_data_o)
    );

    //例化显示模块
    display_module inst_display_module(
        .clk(clk_25_MHz),
        .rst_n(rst_n),
        .ram_data(ram_data_o),
        .ram_addr(ram_addr_o),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs),
        .vga_rgb(vga_rgb)
    );

endmodule