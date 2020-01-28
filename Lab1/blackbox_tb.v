module blackbox_test;

    reg c_in, k_in, f_in;

    wire g_out;

    blackbox b1 (g_out, c_in, k_in, f_in);

    initial begin

        $dumpfile("blackbox.vcd");
        $dumpvars(0, blackbox_test);

// check outputs for all possible combinations of inputs (2^3 = 8)
// change combination every 10 time units
        c_in = 0; k_in = 0; f_in = 0; #10;
        c_in = 0; k_in = 0; f_in = 1; #10;
        c_in = 0; k_in = 1; f_in = 0; #10;
        c_in = 0; k_in = 1; f_in = 1; #10;
        c_in = 1; k_in = 0; f_in = 0; #10;
        c_in = 1; k_in = 0; f_in = 1; #10;
        c_in = 1; k_in = 1; f_in = 0; #10;
        c_in = 1; k_in = 1; f_in = 1; #10;

        $finish;
    end

    initial
      $monitor("At time %2t, c_in = %d k_in = %d f_in = %d g_out = %d",
                $time, c_in, k_in, f_in, g_out);
endmodule // blackbox_test
