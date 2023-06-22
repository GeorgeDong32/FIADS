//vga显示模块
module vga_display(
    input vga_clk, //VGA驱动时钟
    input rst_n, //复位信号
    input[9:0]pixel_xpos,//像素点横坐标
    input [9:0] pixel_ypos,//像素点纵坐标
    input [11:0] ram_data,//BRAM中读取的数据 
    output reg [16:0] ram_addr, //BRAM 读地址 
    output reg [11:0] pixel_data//像素点数据
);
    //参数定义
    parameter INIT_X=100;//图片的左上角x坐标 
    parameter INIT_Y=100; //图片的左上角y坐标 
    parameter IMG_WIDTH=10'd320; //图片的宽度 
    parameter IMG_HEIGHT=10'd240;//图片的高度

    //获取图片地址ram_addr
    always @ (posedge vga_clk or negedge rst_n)begin
        if(! rst_n) begin
            ram_addr <=17'd0; 
        end
        else begin
            if(ram_addr==76799) begin
                ram_addr <=17'd0; 
            end
            else if (pixel_xpos >= INIT_X && pixel_xpos <= INIT_X + IMG_WIDTH-1'd1 &&  pixel_ypos >=INIT_Y &&pixel_ypos <=INIT_Y+IMG_HEIGHT-1'd1) begin
                ram_addr <= ram_addr + 1'd1; 
            end 
        end
    end

    //在屏幕上显示图片
    always @ (posedge vga_clk or negedge rst_n)begin
        if(!rst_n) begin
            pixel_data <=12'd0; 
        end
        else if (pixel_xpos >= INIT_X && pixel_xpos <=INIT_X +IMG_WIDTH-1'd1&& pixel_ypos >=INIT_Y && pixel_ypos <= INIT_Y+IMG_HEIGHT-1'd1) begin
            pixel_data <= ram_data;
        end
        else begin
            pixel_data <=12'b0000_0000_0000; 
        end
    end
endmodule
