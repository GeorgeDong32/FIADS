`timescale 1ns / 1ps

module top_module_test();

    reg clk1;
    reg clk2;
    localparam clk_period1 = 10;
    localparam clk_period2 = 40;

    reg rst_n;
    reg init_en;
    wire scl;
    wire sda;

    pullup(sda);

    reg vsync_r;
    reg href_r;
    reg[7:0] din_r;

    wire vsync;
    wire href;
    wire[7:0] din;
    wire pclk;
    wire xclk;
    wire pwdn;
    wire reset;

    wire[11:0] vga_rgb;
    wire vga_hs;
    wire vga_vs;
    
    assign vsync = vsync_r;
    assign href = href_r;
    assign din = din_r;
    assign pclk = clk2;

    FIADS inst_FIADS(
        .clk(clk1),
        .rst_n(rst_n),
        .vsync(vsync),
        .href(href),
        .din(din),
        .pclk(pclk),

        .scl(scl),
        .sda(sda),
        .xclk(xclk),
        .pwdn(pwdn),
        .reset(reset),

        .vga_rgb(vga_rgb),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs)
    );

    initial clk1 = 0;
    initial clk2 = 0;
    always #(clk_period1/2) clk1 = ~clk1;
    always #(clk_period2/2) clk2 = ~clk2;

    initial begin
        #2;
        rst_n = 0;
        init_en = 0;
        #(clk_period1*20);
        rst_n = 1;
        #(clk_period1*20);
        init_en = 1;
        #clk_period1;

        #(clk_period1*15000*168);

        repeat(12) begin
            #(clk_period1*500);
            dvp_data();
        end

        #(clk_period1*20);
        $stop;
    end

    task dvp_data;
        integer i,j;
        begin
            vsync_r = 0;
            #(clk_period1*10);
            vsync_r = 1;
            #(clk_period1*10);
            vsync_r = 0;
            #(clk_period1*100);
            for(i=0;i<480;i=i+1) begin
                for(j=0;j<640*2;j=j+1) begin
                    href_r = 1;
                    #(clk_period1);
                    din_r = din_r + 1'b1;
                end
                href_r = 0;
                #(clk_period1*100);
            end
            din_r = 0;
        end
    endtask
endmodule
