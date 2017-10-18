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

parameter ADDR_WIDTH = 10;//ширина шины адрес
parameter DATA_REG_ADDR = 10'd5; //адрес регистра данных
parameter CONFIG_REG_ADDR = 10'd6; //адрес конфигурационного регистра
parameter STATUS_REG_ADDR = 10'd7; //адрес статусного регистра
parameter CONFIG_REG_WIDTH = 8;//размер конфигурационного регистра
parameter STATUS_REG_WIDTH = 8;//размер статусного регистра
module Apb2Sl(
input                      clk, //синхронизация обычная
input                      reset_n, //обычный ресет
input                      pclk, //синхронизация шины
input                      preset_n, //ресет apb
input   [ADDR_WIDTH-1:0]   paddr,
input                      psel1,
input                      penable,
input                      pwrite,
input   [31:0]             pwdata,
input   [3:0]              pstrb,
output  logic              pready,
output  logic [31:0]       prdata,
output  logic              pslverr
//TODO: Описать выходы
    );
//внутренние переменные: 
logic [CONFIG_REG_WIDTH-1:0] configApbReg;//буферные регистры синхронизирующиеся по клоку apb
logic [STATUS_REG_WIDTH-1:0] statusApbReg;
logic [31:0]                 dataApbReg;
logic [CONFIG_REG_WIDTH-1:0] configBuffReg [0:1];//буферные регистры синхронизирующиеся по клоку clk
logic [STATUS_REG_WIDTH-1:0] statusBuffReg [0:1];
logic [31:0]                 dataBuffReg [0:1];
logic [CONFIG_REG_WIDTH-1:0] configMainReg;//основные регистры синхронизирующиеся по основному клоку 
logic [STATUS_REG_WIDTH-1:0] statusMainReg;
logic [31:0]                 dataMainReg;
logic [1:0]                  stateReg;// переменная чочтояния транзакции
//переменные для генерации: 
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
      stateReg      <= 2'b00;//ожидание сообщения
    end: reset_branch 
    else begin: pclk_branch
        unique case(stateReg)
        2'b00:
          begin: wait_transaction_state
            pslverr <= 0;//обнуляем ошибку, если она была
            if(psel1&&((paddr == DATA_REG_ADDR) ||(paddr == CONFIG_REG_ADDR)||(paddr == STATUS_REG_ADDR)))
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
          if(!penable) pslverr<=1;
            stateReg <= 2'b01;
          end: read_transaction_state
        2'b11:
          begin: write_transaction_state
            if (penable)begin
                unique case(paddr)//выбираем, куд писать
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
              pslverr <= 1;
            end
            stateReg <= 2'b00;
          end: write_transaction_state
        default: stateReg <= 2'b00;
        endcase;
      end: pclk_branch
  end: apb_transaction
  
//описание транзакции чтения
always_comb  begin: read_transaction
  if (( psel1 && (~pwrite) )&&((paddr == DATA_REG_ADDR) ||(paddr == CONFIG_REG_ADDR)
  ||(paddr == STATUS_REG_ADDR))) begin  
    unique case(paddr)//выбираем, откуда читать
    DATA_REG_ADDR:prdata   = dataMainReg;
    CONFIG_REG_ADDR:prdata = 32'd0 || configMainReg; //удлиняем регистры до требуемого размера
    STATUS_REG_ADDR:prdata = 32'd0 || statusMainReg;
    default: prdata = 32'd0;
    endcase
  end
end: read_transaction
  
//описание двойной буферизации мужду pclk и clk
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
  statusBuffReg [0] <= statusApbReg;
  dataBuffReg   [0] <= dataApbReg;
  configBuffReg [1] <= configBuffReg [0];
  statusBuffReg [1] <= statusBuffReg [0];
  dataBuffReg   [1] <= dataBuffReg [0];
 end: clk_branch
end: double_buffer

always_ff @(posedge clk, negedge reset_n) begin: main_register_description
  if (!preset_n) begin: reset_branch 
    configMainReg  <= 0;
    statusMainReg  <= 0;
    dataMainReg    <= 0;
  end: reset_branch
  else begin: clk_branch
    configMainReg  <= configBuffReg [1];
    statusMainReg  <= statusBuffReg [1] ;
    dataMainReg    <= dataBuffReg [1];
  end:clk_branch
end: main_register_description

endmodule
