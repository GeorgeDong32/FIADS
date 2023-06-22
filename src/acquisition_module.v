//图像采集部分顶层模块
module acquisition_module (
    input clk,//系统时钟25 MHz
    input pclk,//像素时钟
    input rst_n, //系统复位
    input vsync, //场同步信号
    input href, //行同步信号
    input [7:0] din, //ov7670模块摄像头数据输入
    output scl, //输出时钟线
    inout sda, //输出数据线
    output wire [11:0] data_rgb444, //输出图像数据
    output wire [16:0] ram_addr_i,
    output wire wr_en
);

    wire send_en;
    wire [7:0] addr; 
    wire [7:0] value;
    wire done; 
    wire state; 
    wire flag;
    reg init_en; //初始化寄存器使能
    wire init_done;
    wire data_rgb444_vld;

    assign init_done =flag && done; //表示最后一个数据也发送完毕

    reg[17:0]cnt_3ms; //上电等待3ms 电平稳定后再初始化寄存器 

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            cnt_3ms <=18'd0; 
        end
        else if (cnt_3ms <=18'd150000) begin
            cnt_3ms <=cnt_3ms +1'd1; 
        end 
    end

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            init_en <=1'b0; 
        end
        else if(cnt_3ms==18'd150000 -1'd1) begin
            init_en <=1'b1; 
        end
        else begin
            init_en<=1'b0; 
        end
    end
    
    //例化SCCB_sender模块
    SCCB_sender inst_SCCB_sender (
        .clk(clk),
        .rst_n(rst_n),
        .send_en(send_en),
        .addr(addr),
        .value(value),
        .done (done),
        .state(state),
        .scl(scl),
        .sda(sda)
    );

    //例化SCCB_config模块
    cam_config inst_cam_config(
        .clk(clk),
        .rst_n(rst_n),
        .SCCB_done(init_en || done),
        .flag(flag),
        .data_vld(send_en),
        .addr(addr),
        .value(value)
    );

    format_converter inst_format_converter (
        .clk(pclk),
        .rst_n(rst_n),
        .vsync(vsync),
        .href(href),
        .din (din),
        .init_done(init_done),
        .data_rgb444 (data_rgb444),
        .data_rgb444_vld(data_rgb444_vld), 
        .addr(ram_addr_i),
        .wr_en(wr_en)
    );

endmodule