`timescale 1ns / 1ps
`include "const.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2017 17:57:40
// Design Name: 
// Module Name: ApbSlTb
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
parameter clkPeriod=10;//период клока
parameter clkTimeDiff=3;//смещение тактовых сигналов относительно друг друга
parameter paddrWidth=10;// ширина адресной шины apb
module Apb2SlTb(

    );
    logic parSl0;
    logic parSl1;
    logic clk; //тактовые сигналы: блока
    logic pclk;// apb
    // сигналы шины apb
    logic   [31:0]          readedData;
    logic                   preset_n;
    logic                   reset_n;
    logic [paddrWidth-1:0]  paddr;
    logic                   pprot;
    logic                   psel2;
    logic                   penable;
    logic                   pwrite;
    logic [31:0]            pwdata;
    logic [31:0]            prdata;
    logic [3:0]             pstrb;
    logic                   pready;
    logic                   pslverr;
    logic                   outSl0;
    logic                   outSl1;
    logic                   inSl0;
    logic                   inSl1;
    //определение модуля
         Apb2Sl mod (
          .clk(clk),
          .pclk(pclk),
          .reset_n(reset_n),
          .psel1(psel2),
          .pwrite(pwrite),
          .paddr(paddr),
          .pwdata(pwdata),
          .prdata(prdata),
          .penable(penable),
          .pready(pready),
          .pslverr(pslverr),
          .pstrb(pstrb),
          .preset_n(preset_n),
          .outSl0(outSl0),
          .outSl1(outSl1),
          .inSl0(inSl0),
          .inSl1(inSl1)
   );
    //сценарий посылки sl сообщения
task slTransaction;
          input bit [31:0] mess;//отправляемое сообщение
          input int mesLength;//длинна сообщения
          input bit parityRight;//если 1, то правильная четность, если 0 то неправильная
   begin 
   parSl0 =1'b1;
   parSl1 =1'b0;
     for (int i=0; i < mesLength; i=i+1) begin
      if(mess[i])begin 
           parSl0 = ~parSl0;
           #10 inSl0=1;
           #10 inSl0=0;
           #10 inSl0=1;
      end else begin
           parSl1 = ~parSl1;
           #10 inSl1=1;
           #10 inSl1=0;
           #10 inSl1=1;
      end 
     end 
     #10 inSl1 = 1;
     inSl0 = 1;
     if (parityRight)begin
       inSl0 = parSl0; // бит четности по 0
       inSl1 = parSl1; // бит четности по 1
     end else begin
       inSl0 = !parSl0; // неправильный бит четности по 0
       inSl1 = !parSl1; // неправильный бит четности по 1
     end
     #10 inSl1 = 1;
     inSl0 = 1;
     #10
     inSl0=0;
     #2
     inSl1=0;
     #10;
     inSl0=1;
     inSl1=1;
     end
endtask
   // сценарии транзакций чтения и записи
    task writeTransaction;
      input bit [paddrWidth-1:0] wrAddr;
      input bit [31:0] wrData;
      begin 
        #2;
        paddr=wrAddr;
        pwrite=1;
        penable=0;
        pstrb=4'b1111;
        pwdata=wrData;
        psel2=1;
        #clkPeriod;
        penable=1;
        #clkPeriod;
        //while(!pready)begin
        psel2=0;
        penable=0;
        pwdata=0;
        paddr=0; 
        pstrb=0;  
        pwrite=0;
        #(clkPeriod-2);
        
      end
    endtask;
    
    task readTransaction;
      input  bit [paddrWidth-1:0] rdAddr;
      begin 
        #2;
        paddr=rdAddr;
        pwrite=0;
        penable=0;
        psel2=1;
        #clkPeriod;
        penable=1;
        #clkPeriod;
        //while(!pready)begin
        //readedData=prdata;
        psel2=0;
        penable=0;
        paddr=0; 
        pwrite=0;
        #(clkPeriod-2);
        
      end
    endtask
    initial
      begin
       #(clkTimeDiff);
        forever #(clkPeriod/2) clk<=~clk;//первый клок
      end
    initial
      begin
        forever #(clkPeriod/2) pclk<=~pclk;//второй клок
      end
     initial begin
     //инициализация
     inSl0=1;
     inSl1=1;
     readedData=1;
     clk=0;
     pclk=1;
     preset_n=1;
     reset_n=1;
     paddr=0;
     pprot=0;
     psel2=0;
     penable=0;
     pwrite=0;
     pwdata=0;
     pstrb=0;
     #25;
     preset_n=0;
     reset_n=0;
     #15;
     preset_n=1;
     reset_n=1;
     #40
//    writeTransaction(CONFIG_REG_ADDR,32'd3156);
//    writeTransaction(DATA_REG_ADDR,32'd43156);
//    writeTransaction(STATUS_REG_ADDR,32'd0);
    writeTransaction(DATA_REG_ADDR,32'd4453);
    writeTransaction(STATUS_REG_ADDR,32'd0);
     #100;
    writeTransaction(CONFIG_REG_ADDR,32'd1);
    #10;
    slTransaction(32'd134,8,1);
//     readTransaction(10'd6);
     end
     

endmodule
