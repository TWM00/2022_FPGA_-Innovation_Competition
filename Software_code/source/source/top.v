module top(
    input                       sys_clk,
    input                        rst_n,
    input                       uart_rxd,           //UART接收端口
	 output		                data_RGB,     
    output                      tmds_clk_p,
    output                      tmds_clk_n,
    output[2:0]                 tmds_data_p,       
    output[2:0]                 tmds_data_n        
);

//parameter define
parameter  CLK_FREQ = 50000000;         //定义系统时钟频率
parameter  UART_BPS = 115200;           //定义串口波特率

//wire define   
wire       uart_recv_done;              //UART接收完成
wire [7:0] uart_recv_data;              //UART接收数据
wire       uart_send_en;                //UART发送使能
wire [7:0] uart_send_data;              //UART发送数据
wire       uart_tx_busy;                //UART发送忙状态标志
wire [7:0] uart_data;
wire                            video_clk;
wire                            video_clk5x;

wire[7:0]                       video_r/*synthesis syn_keep=1*/;
wire[7:0]                       video_g/*synthesis syn_keep=1*/;
wire[7:0]                       video_b/*synthesis syn_keep=1*/;
wire                            video_hs/*synthesis syn_keep=1*/;
wire                            video_vs/*synthesis syn_keep=1*/;
wire                            video_de/*synthesis syn_keep=1*/;
wire                            hdmi_hs;
wire                            hdmi_vs;
wire                            hdmi_de;
wire[7:0]                       hdmi_r;
wire[7:0]                       hdmi_g;
wire[7:0]                       hdmi_b;

wire                            osd_hs;
wire                            osd_vs;
wire                            osd_de;
wire[7:0]                       osd_r/*synthesis syn_keep=1*/;
wire[7:0]                       osd_g/*synthesis syn_keep=1*/;
wire[7:0]                       osd_b/*synthesis syn_keep=1*/;



assign hdmi_hs     = osd_hs;
assign hdmi_vs    = osd_vs;
assign hdmi_de     = osd_de;
assign hdmi_r      = osd_r[7:0];
assign hdmi_g      = osd_g[7:0];
assign hdmi_b      = osd_b[7:0];
wire                             sys_clk_g;
wire                             video_clk_w;       
wire                             video_clk5x_w;
GTP_CLKBUFG sys_clkbufg
(
  .CLKOUT                    (sys_clk_g                ),
  .CLKIN                     (sys_clk                  )
);
GTP_CLKBUFG video_clk5xbufg
(
  .CLKOUT                    (video_clk5x               ),
  .CLKIN                     (video_clk5x_w             )
);
GTP_CLKBUFG video_clkbufg
(
  .CLKOUT                    (video_clk                 ),
  .CLKIN                     (video_clk_w               )
);

color_bar color_bar_m0(
	.uart_data                      (uart_data),
   .clk                        (video_clk                ),
	.rst                        (~rst_n                   ),
	.hs                         (video_hs                 ),
	.vs                         (video_vs                 ),
	.de                         (video_de                 ),
	.rgb_r                      (video_r                  ),
	.rgb_g                      (video_g                  ),
	.rgb_b                      (video_b                  )
);

video_pll video_pll_m0
 (
    .pll_rst(1'b0),
    .clkin1(sys_clk_g),
    .pll_lock(),
    .clkout0(video_clk5x_w),
    .clkout1(video_clk_w));


dvi_encoder dvi_encoder_m0
 (
     .pixelclk      (video_clk          ),// system clock
     .pixelclk5x    (video_clk5x        ),// system clock x5
     .rstin         (~rst_n             ),// reset
     .blue_din      (hdmi_b            ),// Blue data in
     .green_din     (hdmi_g            ),// Green data in
     .red_din       (hdmi_r            ),// Red data in
     .hsync         (hdmi_hs           ),// hsync data
     .vsync         (hdmi_vs           ),// vsync data
     .de            (hdmi_de         ),// data enable
     .tmds_clk_p    (tmds_clk_p         ),
     .tmds_clk_n    (tmds_clk_n         ),
     .tmds_data_p   (tmds_data_p        ),//rgb
     .tmds_data_n   (tmds_data_n        ) //rgb
 );

//串口接收模块     
uart_recv #(                          
    .CLK_FREQ       (CLK_FREQ),         //设置系统时钟频率
    .UART_BPS       (UART_BPS))       //设置串口接收波特率
u_uart_recv(                 
    .sys_clk        (video_clk), 
    .sys_rst_n      (rst_n),
    
    .uart_rxd       (uart_rxd),
    .uart_done      (uart_recv_done),
    .uart_data      (uart_data)
    );	
osd_display  osd_display_m0(
	.rst_n                 (rst_n                      ),
	.pclk                  (video_clk                  ),
	.i_hs                  (video_hs                   ),
	.i_vs                  (video_vs                   ),
	.i_de                  (video_de                   ),
	.i_data                ({video_r,video_g,video_b}  ),
   //.i_data                (uart_data),
	.o_hs                  (osd_hs                     ),
	.o_vs                  (osd_vs                     ),
	.o_de                  (osd_de                     ),
	.o_data                ({osd_r,osd_g,osd_b}        )
); 
average u_average 
(
     .clk_pixel       (video_clk),   // 模块驱动时钟
     .rst_n           (rst_n),   // 复位信号
     .pre_frame_vsync (video_hs),   // vsync信号
     .pre_frame_hsync (video_vs),   // hsync信号
     .brg				 ({osd_r,osd_g,osd_b}),
	  .pixel_xpos		 (pixel_xpos_w),
	  .pixel_ypos		 (pixel_ypos_w),
     .post_frame_vsync(),   // vsync信号
     .post_frame_hsync(),   // hsync信号
     .framebuffer     (rgb_reg) // 输出60个区块像素数据
);
wire [1439:0]rgb_reg;
RGB_Control1 u_RGB_Control1(
	.clk(video_clk),
	.rst_n(rst_n),
	.tx_done(tx_done),		//一帧(24bit)数据结束标志
	.rgb_reg(rgb_reg),//颜色
	.tx_en(tx_en),			//发送数据使能
	.RGB(ARGB)
);

RZ_Code  RZ_Code_inst(
	.clk    	(video_clk),
	.rst_n  	(rst_n),
	.RGB    	(ARGB) ,			//按照GRB的顺序排列
	
	.tx_en   (tx_en),	
	.tx_done (tx_done),
	
	.RZ_data	(data_RGB)
);

endmodule