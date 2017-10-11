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
    input logic reset,
    input logic sl0,
    input logic sl1,
    input logic [1:0] mode,
    output logic [31:0] data,
    output logic valid,
    output logic ready
    );
logic [5:0] counter;//переменная счетчика
logic [5:0] maxcount;//максимальное число, до которого считает счетчик
logic parSl0;//четность sl0
logic parSl1;//четность sl1
always_comb begin
    case (mode)
        0: maxcount=6'd8;
        1: maxcount=6'd16;
        2: maxcount=6'd32;
        default: maxcount=6'd0;//непредвиденная ситуация
    endcase
end
always_ff @(negedge sl0, negedge sl1, posedge reset) begin
    if (reset) begin
        counter<=6'b0;
        data<=32'b0;
        valid<=1'b0;
        ready<=1'b0;
        parSl0<=1'b1;
        parSl1<=1'b0;
    end else begin
        if (counter<=maxcount)begin
            valid<=1'b0;
            ready<=0;
            case({sl0,sl1})
            2'b01: begin
                     parSl0<=!parSl0;
                     if (counter<(maxcount))begin
                        data[31]<=1'b0;
                        for (int i=30; i >= 0; i=i-1)
                        data[i]<=data[i+1];
                     end
                     counter<=counter+1;
                 end
            2'b10: begin
                     parSl1<=!parSl1;
                     if (counter<(maxcount))begin
                          data[31]<=1'b1;
                          for (int i=30; i >= 0; i=i-1)
                          data[i]<=data[i+1];
                     end
                     counter<=counter+1;
                 end
            2'b00: begin
                 counter<=0;
                 ready<=1;
                 valid<=0;
                 end
             endcase
        end else
        if (counter==maxcount+1'b1)begin
            if ({sl0,sl1}==2'b00) begin
                counter<=0;
                ready<=1;
                valid<=parSl1&parSl0;
                parSl0<=1'b1;
                parSl1<=1'b0;
            end
        end
    end     
end
endmodule
