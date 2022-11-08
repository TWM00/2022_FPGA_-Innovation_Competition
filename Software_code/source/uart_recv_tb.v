`timescale 1ns/1ns
`define clock_period 20

module uart_recv_tb;


//parameter define
parameter  CLK_FREQ = 50000000;         //定义系统时钟频率
parameter  UART_BPS = 115200;           //定义串口波特率

reg sys_clk;
reg sys_rst_n;
reg uart_rxd;
wire uart_recv_done;
wire [7:0]uart_data;
wire rx_flag;
wire [3:0]rx_cnt;
uart_recv #(                          
    .CLK_FREQ       (CLK_FREQ),         //设置系统时钟频率
    .UART_BPS       (UART_BPS))         //设置串口接收波特率
u_uart_recv(                 
    .sys_clk        (sys_clk), 
    .sys_rst_n      (sys_rst_n),
    .rx_flag		  (rx_flag),
	 .rx_cnt			  (rx_cnt),
    .uart_rxd       (uart_rxd),
    .uart_done      (uart_recv_done),
    .uart_data      (uart_data)
);

initial begin 
sys_clk=1;
sys_rst_n=0;
uart_rxd=0;
#(`clock_period*200);
	sys_rst_n=1;
end

always#(`clock_period/2)begin sys_clk=~sys_clk;uart_rxd= {$random} % 2;end
	

endmodule
	