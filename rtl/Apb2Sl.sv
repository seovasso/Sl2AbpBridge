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
parameter DATA_REG_ADDR = ADDR_WIDTH'd5; //адрес регистра данных
parameter CONFIG_REG_ADDR = ADDR_WIDTH'd6; //адрес конфигурационного регистра
parameter STATUS_REG_ADDR = ADDR_WIDTH'd7; //адрес статусного регистра
module Apb2Sl(
input                      clk, //синхронизаци€ обычна€
input                      reset_n, //обычный ресет
input                      pclk, //синхронизаци€ шины
input                      preset_n, //ресет apb
input   [ADDR_WIDTH-1:0]    paddr,
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

endmodule
