`timescale 1ns / 1ps
`include "const.vh"
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
module doubleBuffer#(parameter width=32) (
input               clock   ,
input               reset_n ,
input   [width-1:0] in      ,
output  [width-1:0] out
    ) ;

logic [width-1:0] buffReg [0:1];
always_ff @(posedge clock, negedge reset_n)  begin: double_buffer
 if (!reset_n) begin: reset_branch 
  buffReg [0] <= 0;
  buffReg [1] <= 0;
 end: reset_branch
 else begin: clk_branch
  buffReg [0] <= in;
  buffReg [1] <= buffReg [0];
 end: clk_branch
end: double_buffer
assign out=buffReg[1];
endmodule

module Apb2Sl(
input                       clk, //синхронизация обычная
input                       reset_n, //обычный ресет
input                       pclk, //синхронизация шины
input                       preset_n, //ресет apb
input   [ADDR_WIDTH-1:0]    paddr,
input                       psel1,
input                       penable,
input                       pwrite,
input   [31:0]              pwdata,
input   [3:0]               pstrb,
output  logic               pready,
output  logic [31:0]        prdata,
output  logic               pslverr,
output  logic               outSl0,
output  logic               outSl1,
input                      inSl0,
input                      inSl1
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
logic [1:0]                  stateReg;// переменная состояния транзакции

//переменные для подключения передатчика и приемника 
logic [1:0] transResMode;

//переменные для подключения передатчика
logic         transReady; 
logic         transApbReady; //часть синхронизируемая по Apb pclk
logic         transEnable;
logic         transApbEnable;//часть синхронизируемая по Apb pclk
logic [31:0]  transData;

//переменные для подключения приемника
logic         recReady; 
logic         recApbReady; 
logic         recValid;
logic         recApbValid;
logic [31:0]  recData;
logic [31:0]  recApbData;

//псевдонимы для конфигурациооного регистра
logic       typeFlag;// 0->передатчик 1->приемник
logic [1:0] mode;//00 ->8 бит 01->16 бит 10->32 бита

//подключение псевдонимов 
assign typeFlag = configApbReg[0];
assign mode = configApbReg[2:1];


//описание транзакций чтения и записи
assign pready=stateReg[1];
  always_ff @(posedge pclk, negedge preset_n)
  begin: apb_transaction
    if (!preset_n) begin: reset_branch 
      transApbEnable<=0;
      configApbReg  <= 0;
      statusApbReg  <= 1;
      pslverr       <= 0;
      dataApbReg    <= 0;
      stateReg      <= 2'b00;//ожидание сообщения
    end: reset_branch 
    else begin: pclk_branch
        unique case(stateReg)
        2'b00:
          begin: wait_transaction_state
            pslverr <= 0;//обнуляем ошибку, если она была
            if(psel1&&((paddr == DATA_REG_ADDR) ||(paddr == CONFIG_REG_ADDR)||(paddr == STATUS_REG_ADDR)))//описание транзакции
              begin
                if(pwrite)begin
                  stateReg <= 2'b11;
                end else begin
                  stateReg <= 2'b10;
                end
              end else 
              begin//управление приемом и передачей
                if (!configApbReg[0])begin//если модуль в режиме передатчика
                  if (!statusApbReg[0])begin//если сообщение еще не отправлено
                    if(transApbReady)begin//если передатчик готов отправить
                      transApbEnable<=1;//разрешаем отправку
                      statusApbReg[0]<=1;//помечаем сообщение как отправленное
                    end 
                  end
                  else begin //если передатчик занят
                                        transApbEnable<=0;//запрещаем отправку
                  end
                end else begin //если модуль в режиме приемника
                  if(recApbReady)begin //если сообщение принято
                    if (recApbValid) begin //если четность совпадает
                      unique case (configApbReg[2:1])
                        00:dataApbReg[7:0]<=recApbData[31:24];
                        01:dataApbReg[15:0]<=recApbData[31:16];
                        10:dataApbReg<=recApbData;
                        default: dataApbReg<=recApbData;
                      endcase
                      statusApbReg[1]<=1;//сообщение принято
                      statusApbReg[2]<=1;//четность норм
                    end else begin// если четность не совпадает
                    statusApbReg[1]<=1;//сообщение принято
                    statusApbReg[2]<=0;//четность не норм
                    if (!configApbReg[3])
                      unique case (configApbReg[1:0])
                        00:dataApbReg[7:0]<=recApbData[31:24];
                        01:dataApbReg[15:0]<=recApbData[31:16];
                        10:dataApbReg<=recApbData;
                        default: dataApbReg<=recApbData;
                      endcase
                    end
                  end
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
  if ((psel1 && (~pwrite)) && ((paddr == DATA_REG_ADDR) ||(paddr == CONFIG_REG_ADDR)
  ||(paddr == STATUS_REG_ADDR))) begin  
    unique case(paddr)//выбираем, откуда читать
    DATA_REG_ADDR:prdata   = dataApbReg;
    CONFIG_REG_ADDR:prdata = 32'd0 | configApbReg; //удлиняем регистры до требуемого размера
    STATUS_REG_ADDR:prdata = 32'd0 | statusApbReg;
    default: prdata = 32'd0;
    endcase 
  end else prdata = 32'd0;
end: read_transaction
  
//описание двойной буферизации мужду pclk и clk
doubleBuffer dataDoubleBuff ( .in(dataApbReg),
                              .clock(clk),
                              .out(dataMainReg),
                              .reset_n(reset_n));
doubleBuffer#(CONFIG_REG_WIDTH) configDoubleBuff (.in       (configApbReg ),
                                                  .clock    (clk          ),
                                                  .out      (configMainReg),
                                                  .reset_n  (reset_n)     );
                                                  
doubleBuffer#(STATUS_REG_WIDTH) statusDoubleBuff (.in         (statusApbReg ),
                                                  .clock      (clk          ),
                                                  .out        (statusMainReg),
                                                  .reset_n    (reset_n      ));
                                                  
doubleBuffer#(2) modeDoubleBuff ( .in         (mode         ),
                                  .clock      (clk          ),
                                  .out        (transResMode ),
                                  .reset_n    (reset_n      ));

  doubleBuffer#(1) enableDoubleBuff ( .in       (transApbEnable ),
                                      .clock    (clk            ),
                                      .out      (transEnable    ),
                                      .reset_n  (reset_n        ));
                                  
doubleBuffer#(1) transReadyDoubleBuff ( .in       (transReady   ),
                                        .clock    (pclk         ),
                                        .out      (transApbReady),
                                        .reset_n  (preset_n     ));
doubleBuffer#(1) recReadyDoubleBuff (   .in       (recReady     ),
                                        .clock    (pclk         ),
                                        .out      (recApbReady  ),
                                        .reset_n  (preset_n     ));
doubleBuffer#(1) recValidDoubleBuff (   .in       (recValid     ),
                                        .clock    (pclk         ),
                                        .out      (recApbValid  ),
                                        .reset_n  (preset_n     ));
doubleBuffer#(32) recDataDoubleBuff (   .in       (recData      ),
                                        .clock    (pclk         ),
                                        .out      (recApbData   ),
                                        .reset_n  (preset_n     ));
SlTransmitter trans ( .sl0(outSl0),
                      .sl1(outSl1),
                      .ready(transReady),
                      .enable(transEnable),
                      .data(dataMainReg),
                      .mode(transResMode),
                      .clk(clk),
                      .reset_n(reset_n));
SlReciever rec( .sl0    (inSl0      ),
                .sl1    (inSl1      ),
                .mode   (configApbReg[2:1]),
                .data   (recData    ),
                .valid  (recValid   ),
                .ready  (recReady   ),
                .reset_n(reset_n    ));
endmodule
