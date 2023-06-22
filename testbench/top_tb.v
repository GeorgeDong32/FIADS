`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/04 16:03:18
// Design Name: 
// Module Name: ov7670_data_16rgb565_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();

    reg rst_n;
    reg clk;

    localparam clk_period = 20;

    reg     vsync;
    reg     href;
    reg[7:0] din;
    reg     init_done;
    wire[11:0] data_rgb444;
    wire    data_rgb444_vld;
    wire[16:0] addr;
    wire    wr_en;

    wire[16:0] ram_addr;
    wire[11:0] ram_data;

    wire    vga_hs;
    wire    vga_vs;
    wire[11:0] vga_rgb;

    wire[11:0] pixel_data;
    wire[9:0]  pixel_xpos;
    wire[9:0]  pixel_ypos;

    ov7670_data_12rgb444 inst_ov7670_data_12rgb444(
        .clk(clk),
        .rst_n(rst_n),
        .vsync(vsync),
        .href(href),
        .din(din),
        .init_done(init_done),
        .data_rgb444(data_rgb444),
        .data_rgb444_vld(data_rgb444_vld),
        .addr(addr),
        .wr_en(wr_en)
    );

    BRAM inst_BRAM(
        .addra(addr),
        .clka(clk),
        .dina(data_rgb444),
        .wea(wr_en),

        .addrb(ram_addr),
        .clkb(clk),
        .doutb(ram_data)
    );

    vga_driver inst_vga_driver(
        .vga_clk(clk),
        .rst_n(rst_n),

        .vga_hs(vga_hs),
        .vga_vs(vga_vs),
        .vga_rgb(vga_rgb),

        .pixel_data(pixel_data),
        .pixel_xpos(pixel_xpos),
        .pixel_ypos(pixel_ypos)
    );

    vga_display inst_vga_display(
        .vga_clk(clk),
        .rst_n(rst_n),
        
        .pixel_xpos(pixel_xpos),
        .pixel_ypos(pixel_ypos),
        .ram_data(ram_data),
        .ram_addr(ram_addr),
        .pixel_data(pixel_data)
    );

    initial clk = 1;
    always #(clk_period/2) clk = ~clk;

    initial begin
        #2;
        rst_n = 0;
        vsync = 0;
        href = 0;
        din = 0;
        init_done = 0;
        #(clk_period*20);
        rst_n = 1;
        #(clk_period*20);
        init_done = 1;
        #clk_period;
        init_done = 0;
        #(clk_period*20);

        repeat(20) begin
            #(clk_period*500);
            dvp_data();
        end

        #(clk_period*20);
        $stop;
    end

    task dvp_data;
        integer i,j;
        begin
            vsync = 0;
            #(clk_period*10);
            vsync = 1;
            #(clk_period*10);
            vsync = 0;
            #(clk_period*100);
            for(i=0;i<480;i=i+1) begin
                for(j=0;j<640*2;j=j+1) begin
                    href = 1;
                    #(clk_period);
                    din = din + 1'b1;
                end
                href = 0;
                #(clk_period*100);
            end
            din = 0;
        end
    endtask
endmodule
