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
input                      clk, //синхронизаци€ обычна€
input                      reset_n, //обычный ресет
input                      pclk, //синхронизаци€ шины
input                      preset_n, //ресет apb
input   [ADDR_WIDTH-1:0]   paddr,
input                      psel1,
input                      peneble,
input                      pwrite,
input   [31:0]             pwdata,
input   [3:0]              pstrb,
output  logic              pready,
output  logic [31:0]       prdata,
output                     pslverr
//TODO: ќписать выходы
    );
//внутренние переменные: 
logic [CONFIG_REG_WIDTH-1:0] confApbReg;//буферные регистры синхронизирующиес€ по клоку apb
logic [STATUS_REG_WIDTH-1:0] statApbReg;
logic [31:0]                 dataApbReg;
logic                        transactionStarted;// переменна€ глас€ща€ о начале транзакции 
//переменные дл€ генерации: 
genvar i;
 
  always_ff @(posedge pclk, negedge preset_n)
  begin: apb_transaction
    if (!preset_n) begin
      confApbReg<=0;
      statApbReg<=0;
      dataApbReg<=0;
    end else begin
      if (psel1) begin
        if((paddr == DATA_REG_ADDR) 
            ||(paddr == CONFIG_REG_ADDR)
             ||(paddr == STATUS_REG_ADDR))// проверка адреса
         begin
          if (1) pready<=1;//TODO: добавить проверку синхронизации
         end
         //описание задержки если 
         // описание процессов записи и чтени€
         if (pready&&penable) begin     //если в предыдущем такте было выставлено pready
          if(pwrite) begin//запись 
            case(paddr)//пишем в регистры
              DATA_REG_ADDR: for(i=0;i<=3;i++) if(pstrb[i]) dataApbReg[8*i+7:8*i]<=pwdata[8*i+7:8*i];
              CONFIG_REG_ADDR:configApbReg<=pwdata[CONFIG_REG_WIDTH-1:0];
              STATUS_REG_ADDR:statusApbReg<=pwdata[STATUS_REG_WIDTH-1:0];
              default:PSLVERR<=1;
            endcase
          end else begin//чтение
            unique case(paddr)//читаем из регистров
              DATA_REG_ADDR: pwdata<=dataApbReg;
              CONFIG_REG_ADDR:pwdata[CONFIG_REG_WIDTH-1:0]<=configReg;
              STATUS_REG_ADDR:pwdata[STATUS_REG_WIDTH-1:0]<=statusReg;
              default:PSLVERR<=1;
            endcase
          end
         end
        end
      end      

  end
endmodule
