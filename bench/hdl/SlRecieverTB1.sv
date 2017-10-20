`timescale 100ps / 1ps
`include "C:/Users/Vasso/Documents/vivadoprojects/project_1/project_1.srcs/rtl/SlReciever.sv"
module SlRecieverTb();

     logic reset_n;
     logic sl0;
     logic sl1;
     logic [1:0] mode;
     logic [31:0] data;
     logic valid;
     logic ready;
     bit mess [16:0] ;

    SlReciever res (
    .reset_n(reset_n),
     .sl0(sl0),
     .sl1(sl1),
    .mode(mode),
    .data(data),
     .valid(valid),
    .ready(ready)
    );

    initial begin
        mode=2'b01;
        sl0=1;
        sl1=1;
        reset_n = 1;
        #10
        reset_n = 0;
        #10 
        reset_n =1;
        #100
         mess  = '{0,1,0,1,0,0,1,1,0,1,1,0,1,0,0,1,1};//отправляемое сообщение
        for (int i=0; i <= 16; i=i+1) begin
            if(mess[i]==0)begin 
            #10 sl1=1;
            #10 sl0=1;
            #10 sl0=0;
            #10 sl0=1;
        end else begin
            #10 sl1=1;
            #10 sl0=1;
            #10 sl1=0;
            #10 sl1=1;
            end 
        end
        #10
        sl0=0;
        #2
        sl1=0;
        #10;
        sl0=1;
        sl1=1;
    end
    
   

endmodule