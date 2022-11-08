`timescale  1ns/1ns                     //�������ʱ�䵥λ1ns�ͷ���ʱ�侫��Ϊ1ns

module  tb_hdmi_colorbar_top;              

//parameter  define
parameter  T = 20;                      //ʱ������Ϊ20ns

//reg define
reg          sys_clk;                   //ʱ���ź�
reg          sys_rst_n;                 //��λ�ź�

//wire define
wire         tmds_clk_p;
wire         tmds_clk_n;
wire  [2:0]  tmds_data_p;
wire  [2:0]  tmds_data_n;      

//*****************************************************
//**                    main code
//*****************************************************

//�������źų�ʼֵ
initial begin
    sys_clk            = 1'b0;
    sys_rst_n          = 1'b0;     //��λ
    #(T+1)  sys_rst_n  = 1'b1;     //�ڵ�21ns��ʱ��λ�ź��ź�����
end

//50Mhz��ʱ�ӣ�������Ϊ1/50Mhz=20ns,����ÿ10ns����ƽȡ��һ��
always #(T/2) sys_clk = ~sys_clk;

//����HDMI��������ģ��
hdmi_colorbar_top  u_hdmi_colorbar_top(
    .sys_clk       (sys_clk),
    .sys_rst_n     (sys_rst_n),
     
    .tmds_clk_p    (tmds_clk_p),
    .tmds_clk_n    (tmds_clk_n),
    .tmds_data_p   (tmds_data_p),
    .tmds_data_n   (tmds_data_n)
    );

endmodule
