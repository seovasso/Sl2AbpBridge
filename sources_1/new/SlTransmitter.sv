`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.09.2017 12:37:23
// Design Name: 
// Module Name: SlTransmitter
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


module SlTransmitter(
    output logic sl0,
    output logic sl1,
    output logic ready,
    input  logic [31:0] data,
    input  logic [1:0] mode,
    input  logic en,
    input  logic clk,
    input  logic reset
    );
    logic [31:0] buff;//буфер для данных
    logic [5:0] counter;//переменная счетчика
    logic [5:0] maxcount;//максимальное число, до которого считает счетчик
    logic parSl0;//четность sl0
    logic parSl1;//четность sl1
    always_comb begin
        case (mode)
            0: maxcount=6'd8 ;
            1: maxcount=6'd16;
            2: maxcount=6'd32;
            default: maxcount=6'd0;//непредвиденная ситуация
        endcase
    end
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            counter<=6'b0;
            ready  <=1'b1;
            parSl0 <=1'b1;
            parSl1 <=1'b0;
            sl0    <=1'b1;
            sl1    <=1'b1;
        end else begin
            if (en) begin
                if (ready) begin
                    buff<=data;
                    ready<=1'b0;
                end else begin
                    if ((sl0==0)||(sl1==0)) begin
                        sl0<=1;
                        sl1<=1;
                    end else begin
                        if(counter<maxcount)begin
                            case(buff[0])
                                1'b0:begin 
                                    sl0<=0;
                                    parSl0<=~parSl0;
                                end
                                    1'b1: begin
                                    sl1<=0;
                                    parSl1<=~parSl1;
                                end
                            endcase
                            for (int i=0; i <= 30; i=i+1) buff[i]<=buff[i+1];
                            counter<=counter+1;
                        end else
                        if(counter==maxcount)begin
                            sl0<=parSl0;
                            sl1<=parSl1;
                            counter<=counter+1;
                        end else begin
                            sl0<=1'b0;
                            sl1<=1'b0;
                            counter<=6'd0;
                            ready<=1'b1;
                            parSl0 <=1'b1;
                            parSl1 <=1'b0;
                        end
                    end                        
                end
            end
        end
    end
    
endmodule
