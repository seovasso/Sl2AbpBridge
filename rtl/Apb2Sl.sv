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
logic                        transactionStarted;// переменная гласящая о начале транзакции 
//переменные для генерации: 
genvar i;

  always_ff @(posedge pclk, negedge preset_n)
  begin: apb_transaction
    if (!preset_n) begin
      configApbReg<=0;
      statusApbReg<=0;
      dataApbReg<=0;
    end else begin
      if (psel1) begin
        if((paddr == DATA_REG_ADDR) 
            ||(paddr == CONFIG_REG_ADDR)
             ||(paddr == STATUS_REG_ADDR))// проверка адреса
         begin
          transactionStarted<=1;
          if (1) pready<=1;//TODO: добавить проверку на начало транзиакции
         end
         //описание задержки если 
         // описание процессов записи и чтения
         if (pready&&penable) begin     //если в предыдущем такте было выставлено pready
          if(pwrite) begin//запись 
            unique case(paddr)//пишем в регистры
              DATA_REG_ADDR: begin
              if(pstrb[0]) dataApbReg[7:0]<=pwdata[7:0];
              if(pstrb[1]) dataApbReg[15:8]<=pwdata[15:8];
              if(pstrb[2]) dataApbReg[23:16]<=pwdata[23:16];
              if(pstrb[3]) dataApbReg[31:24]<=pwdata[31:24];
//               generate
//                for( i = 0; i <= 3; i = i + 1) if(pstrb[i]) dataApbReg[(8*i+7):(8*i)]<=pwdata[(8*i+7):(8*i)];
//               endgenerate
//                почему это не работает????
                end
              CONFIG_REG_ADDR:configApbReg<=pwdata[CONFIG_REG_WIDTH-1:0];
              STATUS_REG_ADDR:statusApbReg<=pwdata[STATUS_REG_WIDTH-1:0];
              default:pslverr<=1;
            endcase
            pready<=0;
            transactionStarted<=0;
          end else begin//чтение
            unique case(paddr)//читаем из регистров
              DATA_REG_ADDR: prdata<=dataApbReg;
              CONFIG_REG_ADDR:prdata[CONFIG_REG_WIDTH-1:0]<=configApbReg;
              STATUS_REG_ADDR:prdata[STATUS_REG_WIDTH-1:0]<=statusApbReg;
              default:pslverr<=1;
            endcase
          end 
          if (!pready) prdata<=0; 
         end
        end
      end      
  end
endmodule
