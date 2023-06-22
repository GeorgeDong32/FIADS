`timescale 1ns / 1ps

module acq_module_test();

    reg clk;
    localparam clk_period = 20;

    reg rst_n;
    reg init_en;
    wire scl;
    wire sda;
    wire init_done;

    pullup(sda);

    acquisition_module test(
        .clk(clk),
        .rst_n(rst_n),
        .scl(scl),
        .sda(sda),
        .init_done(init_done)
    );

    initial clk = 0;
    
    always #(clk_period/2) clk = ~clk;

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

        #(clk_period*15000*168);
        $stop;
    end
    
endmodule



