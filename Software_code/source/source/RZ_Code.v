//	输入数据为RGB数据(24bit)
//	输出数据为单极性归零码(Return Zero Code)

module RZ_Code(
	input				clk,
	input				rst_n,
	input	[23:0]	RGB,	//按照GRB的顺序排列
	
	input	   		tx_en,	   //发送数据使能
   output			tx_done,		//一帧(24bit)数据结束标志

	output			RZ_data
);

//-----------------接口信号----------------//
wire     [23:0]  GRB;

reg 		[31:0]  cnt;		   //计数一个码元周期
reg 		[4:0]   i;			   //计数24bit
reg 				  symbol;		//1bit数据结束标志
reg 				  RGB_RZ;		//需要发送的RGB数据
reg				  data_out;	   //转换后的单极性归零码

//reg 	tx_done_sig;

assign  GRB = {RGB[15:8],RGB[23:16],RGB[7:0]};

//----------------------------------------//
//-----------------计数器-----------------//
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		cnt <= 0;
	end
	else if(cnt == 32'd62)	begin		//计数一个码元周期(62.5=1.25us * 50M)
		cnt <= 32'd0;
	end
	else	begin
		cnt <= cnt + 1'b1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		symbol <= 0;
	end
	else if(cnt == 32'd61)	begin		//码元周期结束
		symbol <= 1;
	end
	else	begin
		symbol <= 0;
	end
end

//---------------------------------------//
assign	tx_done = symbol && (i == 5'd23);

//assign	tx_done = tx_done_sig;
//--------------循环发送一帧--------------//
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		i <= 0;
		RGB_RZ <= 0;
	end
	else	begin
		case (i)
		5'd0,5'd1,5'd2,5'd3,5'd4,5'd5,5'd6,5'd7,5'd8,5'd9,5'd10,5'd11,5'd12,5'd13,5'd14,5'd15,5'd16,5'd17,5'd18,5'd19,5'd20,5'd21,5'd22,5'd23:
			if(symbol)	begin
				i <= i + 1;
				RGB_RZ <= GRB[23 - i];		//从高位到低位赋值
			end
			else	begin
					i <= i;
					RGB_RZ <= RGB_RZ;
				end
		  	default:	i <= 0;

		endcase
	end
end

//---------------------------------------//
//-------------单极性归零码---------------//
always @(posedge clk ) begin
	if((!rst_n) || (!tx_en))	begin
		data_out <= 0;
	end
	else if((RGB_RZ == 0) && (tx_en == 1))	begin
		if(cnt <= 32'd15)	begin		//零码高电平，0.3us*50M=15
			data_out <= 1;
		end
		else	begin
			data_out <= 0;
		end
	end
	else if((RGB_RZ == 1) && (tx_en == 1))	begin
		if(cnt <= 32'd45)	begin		//一码高电平，0.9us*50M=45
			data_out <= 1;
		end
		else	begin
			data_out <= 0;
		end
	end
	else	begin
		data_out <= data_out;
	end
end
//-----------------------------------------//
assign	RZ_data = data_out;

endmodule

