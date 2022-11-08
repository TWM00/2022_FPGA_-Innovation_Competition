module average 
(
    //module clock
    input               clk_pixel             ,   // 模块驱动时钟
    input               rst_n           ,   // 复位信号

    //图像处理前的数据接口
    input               pre_frame_vsync ,   // vsync信号
    input               pre_frame_hsync ,   // hsync信号
    input               [23:0]brg,
	  input               pixel_xpos,
	  input               pixel_ypos,
    //图像处理后的数据接口
    output  reg            post_frame_vsync,   // vsync信号
    output  reg            post_frame_hsync,   // hsync信号
    output   [1439:0]framebuffer      // 输出60个区块像素数据
);


    parameter           nblocks=60;//区块个数
    parameter  [0:11*nblocks-1]  startx={11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,
	                      11'd9,11'd59,11'd109,11'd159,11'd209,11'd259,11'd309,11'd359,11'd409,11'd459,11'd509,11'd559,11'd609,11'd659,11'd709,11'd759,
								        11'd759,11'd709,11'd659,11'd609,11'd559,11'd509,11'd459,11'd409,11'd359,11'd309,11'd259,11'd209,11'd159,11'd109,11'd59,11'd9};
	  parameter  [0:11*nblocks-1]  starty={11'd1274,11'd1229,11'd1184,11'd1139,11'd1094,11'd1049,11'd1004,11'd959,11'd914,11'd869,11'd824,11'd779,11'd734,11'd689,
	                      11'd644,11'd599,11'd554,11'd509,11'd464,11'd419,11'd374,11'd329,11'd284,11'd239,11'd194,11'd149,11'd104,11'd59,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,
									      11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd0,11'd1242,11'd1242,11'd1242,11'd1242,11'd1242,11'd1242,11'd1242,
		                    11'd1242,11'd1242,11'd1242,11'd1242,11'd1242,11'd1242,11'd1242,11'd1242,11'd1242};
	reg                  [23:0]a_brg;								 
	reg                  pre_frame_hsync_d;
	reg                  pre_frame_vsync_d;
	reg         [33:0]	 accumulator  [0:nblocks];
	reg         [1439:0] a_framebuffer ;
integer i;
always@(posedge clk_pixel or negedge rst_n) begin
    
	for (i=0; i<= nblocks-1; i=i+1) begin 
	      if(pixel_xpos >= startx[11*i+:10] & pixel_xpos < startx[11*i+:10]+6'd32 &
	         pixel_ypos >= starty[11*i+:10] & pixel_ypos <= starty[11*i+:10]+6'd32)
	     // We are a part of block bn. Accumulate the color info.
		
		   accumulator[i] <= accumulator[i]+ a_brg;
	    
	      
  end 
		a_brg <= brg;

end


always@(posedge clk_pixel ) begin
integer j;
   if (pre_frame_vsync == 1'b1 )
			for (j=0; j <= nblocks-1; j=j+1) begin 
				   
					a_framebuffer [j*24+:23] <= accumulator[j][33:10];
				  accumulator[j] <=0;
			end 
end 					
         
//延时2拍以同步数据信号
always@(posedge clk_pixel or negedge rst_n) begin
    if(!rst_n) begin
        pre_frame_vsync_d <= 1'd0;
        pre_frame_hsync_d <= 1'd0;
    end
    else begin
	    pre_frame_vsync_d <= pre_frame_vsync  ;
        post_frame_vsync  <= pre_frame_vsync_d;
		pre_frame_hsync_d <= pre_frame_hsync  ;
        post_frame_hsync  <= pre_frame_hsync_d;
    end
end	

assign framebuffer = a_framebuffer;
		
endmodule