//	��������ΪRGB����(24bit)
//	�������Ϊ�����Թ�����(Return Zero Code)

module RZ_Code(
	input				clk,
	input				rst_n,
	input	[23:0]	RGB,	//����GRB��˳������
	
	input	   		tx_en,	   //��������ʹ��
   output			tx_done,		//һ֡(24bit)���ݽ�����־

	output			RZ_data
);

//-----------------�ӿ��ź�----------------//
wire     [23:0]  GRB;

reg 		[31:0]  cnt;		   //����һ����Ԫ����
reg 		[4:0]   i;			   //����24bit
reg 				  symbol;		//1bit���ݽ�����־
reg 				  RGB_RZ;		//��Ҫ���͵�RGB����
reg				  data_out;	   //ת����ĵ����Թ�����

//reg 	tx_done_sig;

assign  GRB = {RGB[15:8],RGB[23:16],RGB[7:0]};

//----------------------------------------//
//-----------------������-----------------//
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		cnt <= 0;
	end
	else if(cnt == 32'd62)	begin		//����һ����Ԫ����(62.5=1.25us * 50M)
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
	else if(cnt == 32'd61)	begin		//��Ԫ���ڽ���
		symbol <= 1;
	end
	else	begin
		symbol <= 0;
	end
end

//---------------------------------------//
assign	tx_done = symbol && (i == 5'd23);

//assign	tx_done = tx_done_sig;
//--------------ѭ������һ֡--------------//
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
				RGB_RZ <= GRB[23 - i];		//�Ӹ�λ����λ��ֵ
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
//-------------�����Թ�����---------------//
always @(posedge clk ) begin
	if((!rst_n) || (!tx_en))	begin
		data_out <= 0;
	end
	else if((RGB_RZ == 0) && (tx_en == 1))	begin
		if(cnt <= 32'd15)	begin		//����ߵ�ƽ��0.3us*50M=15
			data_out <= 1;
		end
		else	begin
			data_out <= 0;
		end
	end
	else if((RGB_RZ == 1) && (tx_en == 1))	begin
		if(cnt <= 32'd45)	begin		//һ��ߵ�ƽ��0.9us*50M=45
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

