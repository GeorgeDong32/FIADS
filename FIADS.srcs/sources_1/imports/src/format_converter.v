//获取OV7670 数据并转换成12位 RGB444 图像数据
module format_converter (
    input clk, //摄像头输入像素时钟pclk
    input rst_n, //系统复位
    input vsync, //场同步信号
    input href, //行同步信号
    input[7:0] din, //ov7670 数据输入
    input init_done, //ov7670初始化结束标志，说明此时开始接收数据

    output wire [11:0] data_rgb444, //RGB444 图像数据
    output reg data_rgb444_vld, //图像数据有效标志
    output reg [16:0] addr,//BRAM 写地址
    output wire wr_en//BRAM写使能
);

    reg vsync_r;
    reg href_r;
    reg [7:0] din_r;
    reg vsync_r_ff0;
    reg vsync_r_ff1;
    reg data_start;//数据开始传输
    reg[3:0]frame_cnt;//帧计数，用于计数前10帧
    reg frame_valid;//帧有效信号，过了前10帧后，图像帧有效
    wire vsync_r_pos;
    reg data_en;
    reg[15:0]data_rgb565;
    //将RGB565高位截断为RGB444 数据
    assign data_rgb444 ={data_rgb565 [15:12], data_rgb565[10:7],data_rgb565 [4:1]};
    assign wr_en =data_rgb444_vld;

    //外部信号打一拍
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            vsync_r<=0; href_r <=0; din_r<=8'd0; 
        end
        else begin
            vsync_r <= vsync; href_r<=href; din_r <= din; 
        end 
    end

    //场同步信号上升沿检测
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            vsync_r_ff0<=0;
            vsync_r_ff1 <=0;
        end
        else begin
            vsync_r_ff0 <= vsync_r; 
            vsync_r_ff1 <=  vsync_r_ff0; 
        end 
    end

    assign vsync_r_pos =(vsync_r_ff0 && ~vsync_r_ff1); 

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_start <=0; 
        end
        else if (init_done) begin
            data_start <=1; 
        end
        else begin
            data_start <= data_start;
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            frame_cnt <=0; 
        end
        else if (data_start && frame_valid==0 && vsync_r_pos) begin
            frame_cnt <= frame_cnt +1'b1;
        end
        else begin
            frame_cnt <= frame_cnt ; 
        end 
    end

    always @ (posedge clk or negedge rst_n) begin
        if(! rst_n) begin
            frame_valid <=0;
        end 
        //丢弃前10帧，因为前10 帧可能是不稳定数据
        else if (frame_cnt >=10) begin
            frame_valid <=1;
        end
        else begin
            frame_valid <= frame_valid; 
        end 
    end

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_en<=0; 
        end
        //当帧有效时，开始采集摄像头数据，当场同步信号为低、行同步信号为高时
        //数据有效，data_en信号开始进行01翻转
        else if(href_r && ~vsync_r && frame_valid) begin
            data_en<=~data_en; 
        end
        else begin
            data_en <=0; 
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_rgb444_vld <=0; 
        end
        //数据有效信号随data_en一起进行01翻转，从而做到每两拍写一次BRAM
        //这样每次写入的数据均为两字节的结合，符合摄像头时序 
        else if (data_en) begin
            data_rgb444_vld <=~data_rgb444_vld; 
        end
        else begin
            data_rgb444_vld <= data_rgb444_vld; 
        end

    end


    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            data_rgb565<=16'd0; 
        end
            //将两字节数据进行拼接，拼接为16位RGB565数据 
        else if(data_en) begin
            data_rgb565 <={data_rgb565 [15:8],din_r}; 
        end
        else begin
            data_rgb565 <={din_r,data_rgb565 [7:0] };
        end 
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            addr <=0; 
        end
        //在场同步信号的上升沿，也就是每一帧开始的时候，将地址清零 
        else if (vsync_r_pos) begin
            addr <=0; 
        end
        //解决图像重影问题
        else if (addr <=76800 && data_rgb444_vld && data_en) begin
            addr <= addr +1'b1;
        end 
    end

endmodule