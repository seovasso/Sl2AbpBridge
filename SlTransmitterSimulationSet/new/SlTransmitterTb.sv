`timescale 100ps / 1ps
`include "C:/Users/Vasso/Documents/vivadoprojects/project_1/project_1.srcs/sources_1/new/SlTransmitter.sv"

module SlTransmitterTb();

     logic reset_n; //ресет
     logic sl0wire;//для соединения модулей
     logic sl1wire;//для соединения модулей
     logic [1:0] mode; // 
     logic [31:0] dataIn;
     logic [31:0] dataOut;
     logic transReady;
     logic recReady;
     logic enable; // включение передатчика
     logic valid;// правильность сообщения, принятого приемником
     logic clk; //тактовый сигнал

    SlTransmitter trans (
    .reset_n(reset_n),
     .sl0(sl0wire),
     .sl1(sl1wire),
    .mode(mode),
    .data(dataIn),
    .ready(transReady),
    .clk(clk),
    .enable(enable)
    );
     SlReciever res (
    .reset_n(reset_n),
     .sl0(sl0wire),
     .sl1(sl1wire),
    .mode(mode),
    .data(dataOut),
     .valid(valid),
    .ready(recReady)
    );
    initial begin
    forever #5 clk<=~clk;
    end
    initial begin
        clk=0;
        mode=2'b01;
        dataIn=32'd2134;
        enable=1;
        reset_n = 1;
        #10
        reset_n = 0;
        #10 
        reset_n = 1;
        #150
        enable=0;
        #100;
    end
endmodule