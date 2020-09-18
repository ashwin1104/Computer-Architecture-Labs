module test;
    reg       clk = 0, enable = 0, reset = 1;  // start by reseting the register file

    /* Make a regular pulsing clock with a 10 time unit period. */
    always #5 clk = !clk;

    reg [31:0] d;

    wire [31:0] q;
    initial begin
        $dumpfile("register.vcd");
        $dumpvars(0, test);

        # 10  reset = 0;      // stop reseting the register

        # 10
          // write 50 to the register
          enable = 1;
          d = 50;

        # 10  reset = 1; // test if q resets after q is defined
        # 10
          // write 100 to the register
          reset = 0;
          enable = 1;
          d = 100;
        # 10
          reset = 0;
          d = 10; // q should change from 100 to 10
        # 10
        reset = 0;
        d = 30; // q should not change since clk is 0 (qstill=10)

        # 4
        d = 40; // q should now be 40 since clk is 1
        # 1
        d = 50; // q should still be 40 since clk is already 1
        #5
        enable = 0;
        d = 60; // q should not change sinc clk is 0 and enable is 0 (qstill=50)
        # 4
          // try writing to the register when its disabled
          enable = 0;
          d = 89;

        # 700 $finish;
    end

    initial begin
    end

    register reg1(q, d, clk, enable, reset);

endmodule // test
