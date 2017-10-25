`timescale 100ps / 1ps

module SlRecieverTb();

     logic        reset_n;
     logic        parSl0;
     logic        parSl1;
     logic        inSl0;
     logic        inSl1;

     logic [1:0] mode;
     logic [31:0] data;
     logic valid;
     logic ready;
     bit mess [16:0] ;


task slTransaction;
          input bit [31:0] mess;//отправляемое сообщение
          input int mesLength;//длинна сообщения
          input bit parityRight;//если 1, то правильная четность, если 0 то неправильная
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
     #2
     inSl1=0;
     #10;
     inSl0=1;
     inSl1=1;
     #10;
     end
endtask

    SlReciever res (
    .reset_n(reset_n),
     .sl0(inSl0),
     .sl1(inSl1),
    .mode(mode),
    .data(data),
     .valid(valid),
    .ready(ready)
    );
 bit [31:0] mes;
logic curTest,allTest;
    initial begin
        allTest=1;
        mode=2'b00;
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
        if ((data [31:24] == mes[7:0]) && valid && ready)begin
          curTest=1;
        end else  begin
          curTest=0;
          allTest=0;
        end
        if(curTest) begin
          $display("test passed");
        end else $display("test failed");


        $display("Test #1: 1 correct message l=16");
        mes=$urandom();
        mode=2'b10;
        slTransaction(mes,16,1);
        if ((data [31:16] == mes[15:0]) && valid && ready)begin
          curTest=1;
        end else  begin
          curTest=0;
          allTest=0;
        end
        if(curTest) begin
          $display("test passed");
        end else $display("test failed");


        $display("Test #1: 1 correct message l=32");
        mes=$urandom();
        mode=2'b10;
        slTransaction(mes,32,1);
        if ((data [31:0] == mes[31:0]) && valid && ready)begin
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
