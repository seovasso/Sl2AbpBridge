`timescale 1ns / 1ps
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

    logic clk; //тактовые сигналы: блока
    logic pclk;// apb
    // сигналы шины apb
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
    logic                   pdata;
    logic                   pslverr;
    //определение модуля
         Apb2Sl mod (
          .clk(clk),
          .pclk(pclk),
          .reset_n(reset_n),
          .psel1(psel2),
          .paddr(paddr),
          .pwdata(pwdata),
          .prdata(prdata),
          .penable(penable),
          .pready(pready),
          .pslverr(pslverr),
          .pstrb(pstrb),
          .preset_n(preset_n)
   );
    
    
    // сценарии транзакций чтения и записи
    task writeTransaction;
      input bit [paddrWidth-1:0] wrAddr;
      input bit [31:0] wrData;
      begin 
      #(clkPeriod-2);
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
      end
    endtask;
    task readTransaction();
          begin 
          
          end
        endtask;
    
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
     clk=0;
     pclk=1;
     preset_n=1;
     paddr=0;
     pprot=0;
     psel2=0;
     penable=0;
     pwrite=0;
     pwdata=0;
     pstrb=0;
     #25;
     preset_n=0;
     #15;
     preset_n=1;
     #40
     writeTransaction(10'd6,32'd3156);
     end

endmodule
