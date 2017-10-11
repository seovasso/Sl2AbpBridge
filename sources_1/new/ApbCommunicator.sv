`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2017 13:10:39
// Design Name: 
// Module Name: ApbCommunicator
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
parameter dataAddr=32'd3;
parameter configAddr=32'd3;


module ApbCommunicator(
    input logic clock, //синхронизаци€ обычна€
    input logic reset, //обычный ресет
    input logic pclk, //синхронизаци€ шины
    input logic preset_n,
    input logic [31:0] paddr,
    input logic psel1,
    input logic peneble,
    input logic pwrite,
    input logic [31:0] pwdata,
    input logic [3:0]  pstrb,
    output logic pready,
    output logic [31:0] prdata,
    output logic pslverr,
    output logic [31:0] dataRegOut,
    output logic [31:0] configRegOut,
    input logic [31:0] dataRegIn,
    input logic [31:0] configRegIn
    );
    logic [31:0] dataReg;
    logic [31:0] configReg;
    assign dataRegOut=dataReg;
    assign configRegOut=configReg;
    always_ff @(posedge PCLK, posedge RESETn) begin
    if (!PRESETn) begin
        dataReg<=31'd0;
        configReg<=31'd0;
    end else begin
        if(PSEL1)begin//если выбран наш блок
        if((PADDR==dataAddr)||(PADDR==configAddr))
            if(PWRITE) begin//если идет стади€ записи
                if (PREADY==0)begin
                    PREADY<=1;
                end else begin
                    if (PENABLE)begin
                        unique case(PADDR) //завписываем по стробам ьайты в регистры
                            dataAddr:for (int i=0; i <= 3; i=i+1)
                            if(PSTRB[i]==1)dataReg[8*i+7:8*i]<=PWDATA[8*i+7:8*i];
                            configAddr:for (int i=0; i <= 3; i=i+1)
                            if(PSTRB[i]==1)configReg[8*i+7:8*i]<=PWDATA[8*i+7:8*i];
                            default: ;// TODO:ƒописать обработку ошибок
                        endcase
                        PREADY<=0;
                    end
                end
            end else begin //если идет стади€ чтени€
                   if (PREADY==0)begin
                        PREADY<=1;
                    end else begin
                    if (PENABLE)begin//записываем регистры
                          unique case(PADDR)
                              dataAddr:PRDATA<=dataReg;
                              configAddr:PRDATA<=configReg;
                              default: ;// TODO:ƒописать обработку ошибок
                           endcase
                       end
                           PREADY<=0;
                    end
            end
        end
    end 
    end
endmodule
