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

module Apb2SlTb(

    );
    parameter clkPeriod=10;//период клока
    parameter clkTimeDiff=3;//смещение тактовых сигналов относительно друг друга
    parameter paddrWidth=10;// ширина адресной шины apb
    logic clk; //тактовые сигналы: блока
    logic pclk;// apb
    // сигналы шины apb
    logic preset_n;
    logic [paddrWidth-1:0] paddr;
    logic pprot;
    logic psel2;
    logic penable;
    logic pwrite;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic [3:0] pstrb;
    logic pready;
    logic pdata;
    logic pslverr;
    // сценарии транзакций чтения и записи
    task writeTransaction;
      input bit [31:0] wrData;
      input bit [paddrWidth-1:0] wrAddr;
      begin 
      #clkPeriod;
      paddr=wrAddr;
      pwrite=1;
      penable=0;
      pwdata=wrData;
      psel2=1;
      #clkPeriod;
      penable=1;
      #clkPeriod;
      //while(!pready)begin
        #clkPeriod;
      psel2=0;
      penable=0;
      pwdata=0;
      paddr=0;   
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
     clk=0;
     pclk=0;
     
     #40
     writeTransaction(10'd2,32'd3156);
     end

endmodule
