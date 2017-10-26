`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 27.09.2017 15:02:47
// Design Name:
// Module Name: SlReciever
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


module SlReciever(
    input logic           enable,
    input logic           reset_n,
    input logic           sl0,
    input logic           sl1,
    input logic  [4:0]    bitCount,
    output logic          wordInProces,
    output logic          wordReady,
    output logic [31:0]   dataOut,
    output logic          parityValid,
    output logic          bitCountValid
    );
logic [5:0] counter;//счетчик количества бит в слове
logic [5:0] maxcount;//максимальное количество бит в слове
logic parSl0;//контроль четности sl0
logic parSl1;//конроль четности sl1
logic [31:0] data;//сдвиговый регистр
logic paritySumm;
assign dataOut= data;
assign paritySumm=parSl1&parSl0;
always_ff @(negedge sl0, negedge sl1, negedge reset_n) begin
    if (!reset_n) begin
        maxcount<=6'd8;
        data<=0;
        counter<=0;
        wordReady<=0;
        wordInProces<=0;
        bitCountValid<=0;
        parityValid<=0;
        parSl0<=1'b1;
        parSl1<=1'b0;
    end else begin
        if (counter<=maxcount)begin
            wordInProces<=1;
            bitCountValid<=0;
            parityValid<=0;
            if (counter==1) maxcount<=((bitCount>5'd7)?(bitCount+1):6'd8);
            wordReady<=0;
            case({sl0,sl1})
            2'b01: begin
                     parSl0<=!parSl0;
                     if (counter<(maxcount))begin
                        data[31]<=0;
                        for (int i=30; i >= 0; i=i-1)
                        data[i]<=data[i+1];
                     end
                     counter<=counter+1;
                 end
            2'b10: begin
                     parSl1<=!parSl1;
                     if (counter<(maxcount))begin
                          data[31]<=1;
                          for (int i=30; i >= 0; i=i-1)
                          data[i]<=data[i+1];
                     end
                     counter<=counter+1;
                 end
            2'b00: begin
                 counter <= 0;
                 wordReady <= 1;
                 wordInProces<=0;
                 bitCountValid <= 0;
                 parityValid <= paritySumm;
                 parSl0 <= 1'b1;
                 parSl1 <= 1'b0;
                 end
             endcase
        end else
        if (counter==maxcount+1'b1)begin
              if ({sl0,sl1}==2'b00)
            begin
              counter <= 0;
              wordReady<=1;
              wordInProces<=0;
              bitCountValid<=1;
              parityValid<= paritySumm;
              parSl0<=1'b1;
              parSl1<=1'b0;
            end
        end
    end
end
endmodule
