module RGB_Control1(
	input	clk,
	input	rst_n,
	input	tx_done,		//一帧(24bit)数据结束标志
	input [1439:0] rgb_reg,//颜色
	output	tx_en,			//发送数据使能
	output	reg	[23:0]	RGB
);

//一维数组还原为二维数组
//reg unpack;
wire [23:0] RGB_reg [59:0];
//`UNPACK_ARRAY(24,8,RGB_reg,rgb_reg)
generate 
genvar unpk_idx; 
	for (unpk_idx=0; unpk_idx<(8); unpk_idx=unpk_idx+1) begin :unpack
				assign RGB_reg[unpk_idx][((24)-1):0] = rgb_reg[((24)*unpk_idx+(24-1)):((24)*unpk_idx)]; 
	end 
endgenerate

//-------------接口信号------------//
reg		[31:0]	cnt;
//reg 	[23:0]	RGB_reg	[7:0];	//存RGB数据的数组
reg 	[4:0]	k;				
reg 	tx_en_r;
//--------------------------------//
reg 	tx_done_r0;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		tx_done_r0 <= 0;
	end
	else	begin
		tx_done_r0 <= tx_done;
	end
end
//--------------------------------//


//--------------------------------//

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		k <= 0;
		RGB <= 0;
	end
	else if(tx_en_r)	begin
		case (k)
			6'd0,6'd1,6'd2,6'd3,6'd4,6'd5,6'd6,6'd7,6'd8,6'd9,
			6'd10,6'd11,6'd12,6'd13,6'd14,6'd15,6'd16,6'd17,6'd18,6'd19,
			6'd20,6'd21,6'd22,6'd23,6'd24,6'd25,6'd26,6'd27,6'd28,6'd29,
			6'd30,6'd31,6'd32,6'd33,6'd34,6'd35,6'd36,6'd37,6'd38,6'd39,
			6'd40,6'd41,6'd42,6'd43,6'd44,6'd45,6'd46,6'd47,6'd48,6'd49,
			6'd50,6'd51,6'd52,6'd53,6'd54,6'd55,6'd56,6'd57,6'd58,6'd59:
				if(tx_done_r0)	begin
					RGB <= RGB_reg[k];
					k <= k + 1;
				end
			6'd60:
				if(tx_done)	begin
					RGB <= 0;
					k <= 0;
				end
		  	default: k <= 0;
		endcase
	end
	else ;
end
//--------------------------------//

//-------------计数器-------------//
always @(posedge clk) begin
	if((!rst_n) || (tx_en_r))	begin
		cnt <= 0;
	end
	else if(cnt == 32'd14999)	begin	//RESET时间(300us*50M=15000)
		cnt <= cnt;
	end
	else	begin
		cnt <= cnt + 1;
	end
end
//--------------------------------//

//--------------------------------//
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		tx_en_r <= 0;
	end
	else if((k == 6'd60) && (tx_done))	begin
		tx_en_r <= 0;			//一组数据发送结束，RESTE
	end
	else if((cnt == 32'd14999) && tx_done)	begin
		tx_en_r <= 1;			//重新开始发送
	end
	else	begin
		tx_en_r <= tx_en_r;
	end
end

assign	tx_en = tx_en_r;
//--------------------------------//

endmodule