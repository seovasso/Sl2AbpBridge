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
    logic [31:0] buff;//����� ��� ������
    logic [6:0] counter;//���������� ��������
    logic [6:0] maxCount;//������������ �����, �� �������� ������� �������
    logic [5:0] endBit;//����� ���� ����������, ����� sl0=0 � sl1=0 
    logic parSl0;//�������� sl0
    logic parSl1;//�������� sl1
    always_comb begin:maxcount_get //���������� ������������� ����� ��������
        case (mode)
            0: maxCount = 7'd19;
            1: maxCount = 7'd35;
            2: maxCount = 7'd67;
            default: maxCount=6'd0;//�������������� ��������
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
                    if (counter[0]) begin // �� �������� ������ ���������� ���� ������� 
                        sl0 <= 1;
                        sl1 <= 1;

                    end else begin
                        if( counter[6:1] < (endBit-1))  begin //�������� ����� ���������
                            if( !buff[0] )begin //� ����������� �� ����������� ������ ���������� 0 ��� 1 
                                    sl0 <= 0;
                                    parSl0 <= ~parSl0; // ������� �������� �� 0-�
                                end else begin
                                    sl1 <= 0;
                                    parSl1 <= ~parSl1; // ������� �������� �� 1-�
                                end
                            buff <= buff >> 1; // ����� ��������
                        end else
                        if(counter[6:1] == (endBit-1))begin//�������� ���� ��������
                            sl0 <= parSl0; // ��� �������� �� 0
                            sl1 <= parSl1; // ��� �������� �� 1 
                        end else 
                        if(counter[6:1] == (endBit)) begin //���������� ��������� 
                            sl0 <= 1'b0; // ���������� �� ����� ������� 0-�
                            sl1 <= 1'b0; 
                            ready <= 1'b1; // ��� ��������� ��������
                            parSl0 <= 1'b1; //���������� ���� �������� �������� � �������� ���������
                            parSl1 <= 1'b0;
                        end else
                        if(counter [6:1] == (endBit)) begin //���� � ������ ��������
                            sl0 <= 1'b1;
                            sl1 <= 1'b1;
                            ready <= 1'b1;
                            parSl0 <= 1'b1;
                            parSl1 <= 1'b0;
                        end
                    end   
                    counter <= (counter<maxCount?(counter+1):6'd0);//�������������� �������             
            end
        end
    end
    
endmodule
