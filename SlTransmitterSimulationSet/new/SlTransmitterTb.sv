`timescale 100ps / 1ps
`include "C:/Users/Vasso/Documents/vivadoprojects/project_1/project_1.srcs/sources_1/new/SlTransmitter.sv"

module SlTransmitterTb();

     logic reset; //�����
     logic sl0wire;//��� ���������� �������
     logic sl1wire;//��� ���������� �������
     logic [1:0] mode; // 
     logic [31:0] dataIn;
     logic [31:0] dataOut;
     logic transReady;
     logic recReady;
     logic en; // ��������� �����������
     logic valid;// ������������ ���������, ��������� ����������
     logic clk; //�������� ������

    SlTransmitter trans (
    .reset(reset),
     .sl0(sl0wire),
     .sl1(sl1wire),
    .mode(mode),
    .data(dataIn),
     .en(en),
    .ready(transReady),
    .clk(clk)
    );
     SlReciever res (
    .reset(reset),
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
        mode=2'b00;
        dataIn=32'd134;
        en=1;
        
        reset = 0;
        #10
        reset = 1;
        #10 
        reset=0;
        #100;
    end
endmodule