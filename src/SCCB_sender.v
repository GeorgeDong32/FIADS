//SCCB 发送模块
module SCCB_sender (
    input clk, //系统时钟25 MHz
    input rst_n, //系统复位
    input send_en, //发送使能
    input [7:0] addr, //发送寄存器地址
    input [7:0] value, //发送寄存器地址对应数据
    output reg done, //发送结束标志
    output reg state, //发送状态，忙为0，不忙为1
    output reg scl, //输出时钟线
    inout sda //输出数据线
);
    reg [7:0] addr_r;
    reg [7:0] value_r;

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            addr_r<=8'd0;
            value_r<=8'd0; 
        end
            //当发送使能时，接收输入的寄存器地址和数据 
        else if(send_en) begin
            addr_r <= addr; 
            value_r<= value; 
        end
        //其他时候不接收输入的数据 
        else begin
            addr_r <= addr_r;
            value_r <= value_r;
        end 
    end

    //生成发送状态信号
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <=1'b1;
        end
        else if(send_en)begin
            state<=1'b0; 
        end
        else if(done) begin
            state <=1'b0;
        end
        else begin
            state <= state; 
        end 
    end

    localparam SCL_CNT_MAX =9'd500;
    reg [8:0] scl_cnt;//生成 scl_cnt 计数信号
    
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            scl_cnt<=9'd1; 
        end
        else if (state ==1'b0) begin
            if(scl_cnt==SCL_CNT_MAX-1'b1 || done) begin
                scl_cnt <=0; 
            end
            else begin
                scl_cnt <= scl_cnt  + 1'b1;
            end 
        end
    end

    //而当scl_cnt 数至SCL_CNT_MAX 的一半时，将 scl 拉高，从而将 sda 中的数据写入寄存器
    wire scl_high_mid;
    wire scl_low_mid;

    assign scl_high_mid = (scl_cnt  ==SCL_CNT_MAX/4-1'b1);
    assign scl_low_mid =(scl_cnt ==SCL_CNT_MAX-SCL_CNT_MAX/4-1'b1 );

    reg [5:0]scl_mid_cnt;

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            scl_mid_cnt<=6'b0; 
        end
        //当scl_cnt数至scl_high_mid和scl_low_mid时，scl_mid_ent加1 
        else if(scl_high_mid|| scl_low_mid) begin
            scl_mid_cnt<=scl_mid_cnt+1'b1; 
        end
        else if(done) begin
            scl_mid_cnt <=6'b0;
        end 
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            scl <=1'b1;
        end
        else if (state ==1'b0) begin
            if(scl_cnt <=SCL_CNT_MAX/2-1'b1) begin
                scl <=1'b1;
            end
            else begin
                scl <=1'b0; 
            end 
        end
        else begin
            scl<=1'b1;
        end
    end

    reg sda_en ; 
    reg sda_reg ;

    //sda是inout 信号，当FPGA 不提供数据时，需要设置为高阻态，接收来自摄像头的应答信号
    assign sda=sda_en? sda_reg: 1'bz;

    parameter device_id=8'b0100_0010;//V7670的设备id为 0x42 
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sda_reg <=1'b1; 
        end
        else if (state ==0 &&(scl_high_mid ||scl_low_mid)) begin
            case(scl_mid_cnt)
                6'd0:sda_reg<=1'b0;//起始条件
                //从高到低写入 device_id
                6'd1:sda_reg <=device_id [7];
                6'd3:sda_reg <=device_id [6];
                6'd5:sda_reg <=device_id [5];
                6'd7:sda_reg <=device_id [4];
                6'd9:sda_reg<=device_id [3] ;
                6'd11:sda_reg<=device_id [2];
                6'd13: sda_reg<=device_id [1] ;
                6'd15: sda_reg<= device_id [0] ;
                
                //从高到低写入寄存器地址
                6'd19:sda_reg<=addr_r [7];
                6'd21:sda_reg<=addr_r [6];
                6'd23:sda_reg<=addr_r [5];
                6'd25:sda_reg<=addr_r [4];
                6'd27:sda_reg<=addr_r [3];
                6'd29:sda_reg<=addr_r [2];
                6'd31:sda_reg<=addr_r [1];
                6'd33:sda_reg<=addr_r [0];
                
                //从高到低写入寄存器数据
                6'd37: sda_reg<=value_r [7] ;
                6'd39:sda_reg<=value_r [6];
                6'd41: sda_reg<=value_r [5];
                6'd43:sda_reg<= value_r [4];
                6'd45:sda_reg<=value_r [3];
                6'd47:sda_reg<= value_r [2] ;
                6'd49:sda_reg<= value_r [1];
                6'd51:sda_reg<=value_r [0];
                
                6'd55:sda_reg<= 1'b0;
                6'd56:sda_reg<=1'b1 ; //结束条件
                default:sda_reg<=sda_reg;
            endcase 
        end 
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(! rst_n)begin
            sda_en <=1'b0; 
        end
        else if (state ==0) begin
        //这些时刻对应摄像头的应答时刻，sda_en 置0，接收来自摄像头的
            if(scl_mid_cnt ==6'd18 || scl_mid_cnt==6'd19 || scl_mid_cnt==6'd36 || scl_mid_cnt==6'd37 || scl_mid_cnt==6'd54 || scl_mid_cnt==6'd55) begin
                sda_en <=1'b0; 
            end
            else begin
                sda_en <=1'b1; 
            end 
        end
        else begin
            sda_en <=1'b0;
        end 
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            done <=1'b0; 
        end
        else if(scl_mid_cnt==6'd57 && scl_cnt==SCL_CNT_MAX/2-2) begin
            done <=1'b1;
        end
        else begin
            done <=1'b0; 
        end 
    end
endmodule
