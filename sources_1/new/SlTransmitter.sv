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
    input  logic clk,
    input  logic reset_n
    );
    logic [31:0] buff;//буфер для данных
    logic [6:0] counter;//переменная счетчика
    logic [6:0] maxCount;//максимальное число, до которого считает счетчик
    logic [5:0] endBit;//номер бита завершения, когда sl0=0 и sl1=0 
    logic parSl0;//четность sl0
    logic parSl1;//четность sl1
    always_comb begin:maxcount_get //нахождение максимального числа счетчика
        case (mode)
            0: maxCount = 7'd19;
            1: maxCount = 7'd35;
            2: maxCount = 7'd67;
            default: maxCount=6'd0;//непредвиденная ситуация
        endcase
    end:maxcount_get
    assign endBit=maxCount[6:1];
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            counter<=6'b0;
            ready  <=1'b1;
            parSl0 <=1'b1;
            parSl1 <=1'b0;
            sl0    <=1'b1;
            sl1    <=1'b1;
        end else begin
                if (ready) begin
                    buff<=data; 
                    ready<=1'b0;
                end else 
                begin
                    if (counter[0]) begin // на нечетных тактах возвращаем шину обратно 
                        sl0 <= 1;
                        sl1 <= 1;

                    end else begin
                        if( counter[6:1] < (endBit-1))  begin //отправка битов сообщения
                            if( !buff[0] )begin //в зависимости от содержимого буфера отправляем 0 или 1 
                                    sl0 <= 0;
                                    parSl0 <= ~parSl0; // подсчет четности по 0-м
                                end else begin
                                    sl1 <= 0;
                                    parSl1 <= ~parSl1; // подсчет четности по 1-м
                                end
                            buff <= buff >> 1; // сдвиг регистра
                        end else
                        if(counter[6:1] == (endBit-1))begin//отправка бита четности
                            sl0 <= parSl0; // бит четности по 0
                            sl1 <= parSl1; // бит четности по 1 
                        end else 
                        if(counter[6:1] == (endBit)) begin //завершение сообщения 
                            sl0 <= 1'b0; // выставляем на обоих каналах 0-и
                            sl1 <= 1'b0; 
                            ready <= 1'b1; // бит окончания отправки
                            parSl0 <= 1'b1; //выставляем биты подсчета четности в исходное состояние
                            parSl1 <= 1'b0;
                        end else
                        if(counter [6:1] == (endBit)) begin //сбой в работе счетчика
                            sl0 <= 1'b1;
                            sl1 <= 1'b1;
                            ready <= 1'b1;
                            parSl0 <= 1'b1;
                            parSl1 <= 1'b0;
                        end
                    end   
                    counter <= (counter<maxCount?(counter+1):6'd0);//инкрементируем счетчик             
            end
        end
    end
    
endmodule
