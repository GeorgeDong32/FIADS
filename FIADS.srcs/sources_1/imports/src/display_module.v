//显示部分顶层模块
module display_module (
    input clk,//系统时钟
    input rst_n,//系统复位
    input [11:0] ram_data,//BRAM中读取的数据 

    output wire vga_hs,//VGA 模块行同步信�?
    output wire vga_vs,//VGA 模块场同步信�?
    output wire [11:0] vga_rgb,//VGA模块图像数据
    output reg [16:0] ram_addr //BRAM 读地�? 
);

    wire [11:0] pixel_data; //像素点数�?
    wire [9:0] pixel_xpos; //像素点横坐标
    wire [9:0] pixel_ypos; //像素点纵坐标

    //例化VGA驱动模块
    vga_driver inst_vga_driver (
        .vga_clk(clk),
        .rst_n(rst_n),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs),
        .vga_rgb(vga_rgb),
        .pixel_data(pixel_data),
        .pixel_xpos(pixel_xpos),
        .pixel_ypos(pixel_ypos)
    );

    //例化VGA显示模块
    vga_display  inst_vga_display(
        .vga_clk(clk),
        .rst_n(rst_n),
        .pixel_xpos(pixel_xpos),
        .pixel_ypos(pixel_ypos),
        .ram_data(ram_data),
        .ram_addr(ram_addr),
        .pixel_data(pixel_data)
    );

endmodule