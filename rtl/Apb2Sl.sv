`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2017 12:12:28
// Design Name: 
// Module Name: Apb2Sl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

parameter ADDR_WIDTH = 10;//������ ���� �����
parameter DATA_REG_ADDR = 10'd5; //����� �������� ������
parameter CONFIG_REG_ADDR = 10'd6; //����� ����������������� ��������
parameter STATUS_REG_ADDR = 10'd7; //����� ���������� ��������
parameter CONFIG_REG_WIDTH = 8;//������ ����������������� ��������
parameter STATUS_REG_WIDTH = 8;//������ ���������� ��������
module Apb2Sl(
input                      clk, //������������� �������
input                      reset_n, //������� �����
input                      pclk, //������������� ����
input                      preset_n, //����� apb
input   [ADDR_WIDTH-1:0]   paddr,
input                      psel1,
input                      penable,
input                      pwrite,
input   [31:0]             pwdata,
input   [3:0]              pstrb,
output  logic              pready,
output  logic [31:0]       prdata,
output  logic              pslverr
//TODO: ������� ������
    );
//���������� ����������: 
logic [CONFIG_REG_WIDTH-1:0] configApbReg;//�������� �������� ������������������ �� ����� apb
logic [STATUS_REG_WIDTH-1:0] statusApbReg;
logic [31:0]                 dataApbReg;
logic [CONFIG_REG_WIDTH-1:0] configBuffReg [1:0];//�������� �������� ������������������ �� ����� clk
logic [STATUS_REG_WIDTH-1:0] statusBuffReg [1:0];
logic [31:0]                 dataBuffReg [1:0];
logic [CONFIG_REG_WIDTH-1:0] configMainReg;//�������� �������� ������������������ �� ��������� ����� 
logic [STATUS_REG_WIDTH-1:0] statusMainReg;
logic [31:0]                 dataMainReg;
logic [1:0]                  stateReg;// ���������� ��������� ����������
//���������� ��� ���������: 
genvar i;
assign ready=stateReg[1];
  always_ff @(posedge pclk, negedge preset_n)
  begin: apb_transaction
    if (!preset_n) begin: reset_branch 
      configApbReg  <= 0;
      statusApbReg  <= 0;
      pready        <= 0;
      pslverr       <= 0;
      dataApbReg    <= 0;
      prdata        <= 0;
      stateReg      <= 2'b00;//�������� ���������
    end: reset_branch 
    else begin: pclk_branch
        unique case(stateReg)
        2'b00:
          begin: wait_transaction_state
            pslver <= 1;//�������� ������, ���� ��� ����
            if((paddr == DATA_REG_ADDR) ||(paddr == CONFIG_REG_ADDR)||(paddr == STATUS_REG_ADDR))
              begin
                if(pwrite)begin
                  stateReg <= 2'b11;
                end else begin
                  stateReg <= 2'b10;
                end
              end
          end: wait_transaction_state
        2'b01: begin: pause_transaction_state
            stateReg <= 2'b00;
          end: pause_transaction_state
        2'b10:
          begin: read_transaction_state
          if(!penable) slverr<=1;
            stateReg <= 2'b00;
          end: read_transaction_state
        2'b11:
          begin: write_transaction_state
            if (penable)begin
                unique case(paddr)//��������, ��� ������
                DATA_REG_ADDR: begin:writing_in_dataReg
                if(pstrb[0]) dataApbReg[7:0]   <= pwdata[7:0];
                if(pstrb[1]) dataApbReg[15:8]  <= pwdata[15:8];
                if(pstrb[2]) dataApbReg[23:16] <= pwdata[23:16];
                if(pstrb[3]) dataApbReg[31:24] <= pwdata[31:24];
                //               generate
                //                for( i = 0; i <= 3; i = i + 1) if(pstrb[i]) dataApbReg[(8*i+7):(8*i)]<=pwdata[(8*i+7):(8*i)];
                //               endgenerate
                end:writing_in_dataReg
                CONFIG_REG_ADDR:configApbReg<=pwdata[CONFIG_REG_WIDTH-1:0];
                STATUS_REG_ADDR:statusApbReg<=pwdata[STATUS_REG_WIDTH-1:0];
                default: pslverr <= 1;
                endcase
            end else begin
              pslver <= 1;
            end
            stateReg <= 2'b00;
          end: read_or_write_transaction_state
        default: stateReg <= 2'b00;
        endcase;
      end: pclk_branch
  end: apb_transaction
  
//�������� ���������� ������
always_comb @(posedge clk, negedge reset_n) begin: read_transaction
  if (( psel && (~pwrite) )&&((paddr == DATA_REG_ADDR) ||(paddr == CONFIG_REG_ADDR)
  ||(paddr == STATUS_REG_ADDR))) begin  
    unique case(paddr)//��������, ������ ������
    DATA_REG_ADDR:prdata   = dataMainRegister;
    CONFIG_REG_ADDR:prdata = 32'd0 && configMainRegister; //�������� �������� �� ���������� �������
    STATUS_REG_ADDR:prdata = 32'd0 && statusMainRegister;
    default: prdata = 32'd0;
    endcase
  end
end: read_transaction
  
//�������� ������� ����������� ����� pclk � clk
always_ff @(posedge clk, negedge reset_n)  begin: double_buffer
 if (!preset_n) begin: reset_branch 
  configBuffReg [0] <= 0;
  configBuffReg [0] <= 0;
  dataBuffReg   [0] <= 0;
  configBuffReg [1] <= 0;
  statusBuffReg [1] <= 0;
  dataBuffReg   [1] <= 0;
 end: reset_branch
 else begin: clk_branch
  configBuffReg [0] <= configApbReg;
  configBuffReg [0] <= statusApbReg;
  dataBuffReg   [0] <= dataApbReg;
  configBuffReg [1] <= configBuffReg [0];
  statusBuffReg [1] <= statusBuffReg [0];
  dataBuffReg   [1] <= dataBuffReg [0];
 end: clk_branch
end: double_buffer
always_ff @(posedge clk, negedge reset_n) begin: main_register_description
  if (!preset_n) begin: reset_branch 
    configMainReg  <= 0;
    configMainReg  <= 0;
    dataMainReg    <= 0;
  end: reset_branch
  else begin: clk_branch
    if (!preset_n) begin: reset_branch 
    configMainReg  <= configBuffReg [1];
    configMainReg  <= statusBuffReg [1] ;
    dataMainReg    <= dataBuffReg [1];
  end: reset_branch
  end:clk_branch
end: main_register_description

endmodule
