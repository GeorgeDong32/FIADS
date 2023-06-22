//VGA驱动模块
module vga_driver(
    input vga_clk, //VGA驱动时钟
    input rst_n, //复位信号
    input [11:0]pixel_data,//像素点数据 
    //VGA接口
    output wire vga_hs, //行同步信号
    output wire vga_vs, //场同步信号
    output[11:0]vga_rgb, //红、绿、蓝三原色输出
    output [9:0]pixel_xpos,//像素点横坐标 
    output [9:0] pixel_ypos //像素点纵坐标
);

    //VGA时序参数定义
    parameter H_SYNC=10'd96; //行同步
    parameter H_BACK=10'd48; //行显示后沿
    parameter H_DISP=10'd640;// 行有效数据 
    parameter H_FRONT=10'd16;// 行显示前沿 
    parameter H_TOTAL=10'd800;// 行扫描周期 
    parameter V_SYNC=10'd2;//场同步
    parameter V_BACK=10'd33;//场显示后沿 
    parameter V_DISP=10'd480;//场有效数据
    parameter V_FRONT=10'd10;//场显示前沿
    parameter V_TOTAL=10'd525;// 场扫描周期

    //用于行列计数 r
    reg [9:0] cnt_h; 
    reg [9:0] cnt_v;
    wire vga_en;
    wire data_req ;

    //VGA行、场同步信号定义
    assign vga_hs =(cnt_h <= H_SYNC-1'b1)? 1'b0:1'b1;
    assign vga_vs=(cnt_v <=V_SYNC -1'b1)? 1'b0:1'b1;

    //RGB444数据输出使能信号
    assign vga_en=( ( (cnt_h>=H_SYNC+H_BACK)&&(cnt_h<H_SYNC+H_BACK +H_DISP) ) && ( (cnt_v>= V_SYNC +V_BACK) &&(cnt_v <V_SYNC+V_BACK + V_DISP) ) )? 1'b1: 1'b0;
    //RGB444 数据输出
    assign vga_rgb =vga_en? pixel_data: 12'd0;

    //像素点颜色数据输入请求信号
    assign data_req=(( (cnt_h >=H_SYNC+H_BACK-1'b1)&&(cnt_h < H_SYNC+H_BACK+H_DISP-1'b1))&&((cnt_v >=V_SYNC + V_BACK)&&(cnt_v < V_SYNC+V_BACK +V_DISP)))? 1'b1: 1'b0;
    //像素点坐标
    assign pixel_xpos = data_req ?(cnt_h -(H_SYNC+H_BACK-1'b1)):10'd0; 
    assign pixel_ypos=data_req?(cnt_v-(V_SYNC+V_BACK-1'b1)):10'd0;

    //行计数器对像素时钟计数
    always@ (posedge vga_clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_h <=10'd0; 
        end
        else begin
            if(cnt_h <H_TOTAL-1'b1)
                cnt_h <= cnt_h + 1'b1 ; 
            else
                cnt_h <=10'd0;
            end 
    end

    //场计数器对行计数
    always @ (posedge vga_clk or negedge rst_n)begin
        if(! rst_n) begin
            cnt_v<=10'd0; 
        end
        else if(cnt_h==H_TOTAL-1'b1) begin
            if(cnt_v<V_TOTAL-1'b1)
                cnt_v<=cnt_v+1'b1; 
            else
                cnt_v<=10'd0;
        end
    end

endmodule