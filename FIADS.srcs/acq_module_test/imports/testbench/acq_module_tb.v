`timescale 1ns / 1ps

module acq_module_test();

    reg clk;
    reg pclk;
    localparam clk_period = 10;
    localparam pclk_period = 40;

    reg rst_n;
    reg init_en;
    wire scl;
    wire sda;
    reg vsync;
    reg href;
    reg [7:0] din;
    wire [11:0] data_rgb444;
    wire wr_en;
    wire [16:0] ram_addr_i;

    pullup(sda);

    acquisition_module test(
        .clk(clk),
        .pclk(pclk),
        .vsync(vsync),
        .href(href),
        .din(din),
        .rst_n(rst_n),
        .scl(scl),
        .sda(sda),
        .data_rgb444(data_rgb444),
        .ram_addr_i(ram_addr_i),
        .wr_en(wr_en)
    );

    BRAM inst_BRAM(
        .addra(ram_addr_i),
        .clka(clk),
        .dina(data_rgb444),
        .wea(wr_en),

        .addrb(ram_addr),
        .clkb(clk),
        .doutb(ram_data)
    );

    initial clk = 0;
    initial pclk = 0;
    
    always #(clk_period/2) clk = ~clk;
    always #(pclk_period/2) pclk = ~pclk;

    initial begin
        #2;
        rst_n = 0;
        init_en = 0;
        clk = 0;
        #(clk_period*20);
            rst_n = 1;
        #(clk_period*10);
            init_en = 1;
        #clk_period;
        
        repeat(12) begin
            #(clk_period*500);
            dvp_data();
        end

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



