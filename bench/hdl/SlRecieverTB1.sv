`timescale 100ps / 1ps

module SlRecieverTb();
     logic        enable;
     logic        reset_n;
     logic        inSl0;
     logic        inSl1;
     logic [4:0]  bitCount;
     logic [31:0] data;
     logic wordReady;
     logic wordInProces;
     logic parityValid;
     logic bitCountValid;


task slTransaction;
          input bit [31:0] mess;//отправляемое сообщение
          input int mesLength;//длинна сообщения
          input bit parityRight;//если 1, то правильная четность, если 0 то неправильная
          logic        parSl0;
          logic        parSl1;
   begin
   parSl0 =1'b1;
   parSl1 =1'b0;
     for (int i=0; i < mesLength; i=i+1) begin
      if(!mess[i])begin
           parSl0 = ~parSl0;
           #10 inSl0=1;
           #10 inSl0=0;
           #10 inSl0=1;
      end else begin
           parSl1 = ~parSl1;
           #10 inSl1=1;
           #10 inSl1=0;
           #10 inSl1=1;
      end
     end
     #10 inSl1 = 1;
     inSl0 = 1;
     if (parityRight)begin
       inSl0 = parSl0; // бит четности по 0
       inSl1 = parSl1; // бит четности по 1
     end else begin
       inSl0 = !parSl0; // неправильный бит четности по 0
       inSl1 = !parSl1; // неправильный бит четности по 1
     end
     #10 inSl1 = 1;
     inSl0 = 1;
     #10
     inSl0=0;
     inSl1=0;
     #10;
     inSl0=1;
     inSl1=1;
     #10;
     end
endtask

    SlReciever res (
        .enable       (enable),
        .reset_n      (reset_n),
        .sl0          (inSl0),
        .sl1          (inSl1),
        .bitCount     (bitCount),
        .wordInProces(wordInProces),
        .wordReady    (wordReady),
        .dataOut      (data),
        .parityValid  (parityValid),
        .bitCountValid(bitCountValid)
    );
 bit [31:0] mes;
logic curTest,allTest;
    initial begin
        allTest=1;
        bitCount=5'd7;
        inSl0=1;
        inSl1=1;
        reset_n = 1;
        #10
        reset_n = 0;
        #10
        reset_n =1;
        #100

        $display("Test #1: 1 correct message l=8");
        mes=$urandom();
        slTransaction(mes,8,1);
        if ((data [31:24] == mes[7:0]) && bitCountValid && wordReady)begin
          curTest=1;
        end else  begin
          curTest=0;
          allTest=0;
        end
        if(curTest) begin
          $display("test passed");
        end else $display("test failed");

        bitCount=5'd14;

        $display("Test #1: 1 correct message l=15");
        mes=$urandom();
        slTransaction(mes,16,1);
        if ((data [31:17] == mes[14:0]) && bitCountValid && wordReady)begin
          curTest=1;
        end else  begin
          curTest=0;
          allTest=0;
        end
        if(curTest) begin
          $display("test passed");
        end else $display("test failed");



      if(allTest) begin
        $display("All test passed");
       end else $display("Some tests failed");
    end



endmodule
