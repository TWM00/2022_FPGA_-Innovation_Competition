`timescale 1ns/1ns
`define clock_period 20

module RZ_Code_tb;

reg 		 signal_clk;
reg 		 signal_rst_n;
reg [23:0]signal_RGB;
reg 		 signal_tx_en;
wire 		 signal_tx_done;
wire 		 signal_RZ_data;
RZ_Code u_RZ_Code(
	.clk(signal_clk),
	.rst_n(signal_rst_n),
	.RGB(signal_RGB),			//按照GRB的顺序排列
	.tx_en(signal_tx_en),	   //发送数据使能
   .tx_done(signal_tx_done),	//一帧(24bit)数据结束标志
	.RZ_data(signal_RZ_data)
);

initial begin 
signal_clk=1;
signal_rst_n=0;
signal_RGB=24'b10101010_00000000_00000000;
signal_tx_en=1;
#200
signal_rst_n   <=  1'b1;
end
always#(`clock_period/2)signal_clk=~signal_clk;
	

endmodule
