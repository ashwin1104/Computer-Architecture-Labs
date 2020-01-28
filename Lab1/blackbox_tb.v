module blackbox_test;

    reg v_in, t_in, b_in;

    wire n_out;

    blackbox b1 (n_out, v_in, t_in, b_in);

    initial begin

        $dumpfile("blackbox.vcd");
        $dumpvars(0, blackbox_test);

// check outputs for all possible combinations of inputs (2^3 = 8)
// change combination every 10 time units
        v_in = 0; t_in = 0; b_in = 0; #10;
        v_in = 0; t_in = 0; b_in = 1; #10;
        v_in = 0; t_in = 1; b_in = 0; #10;
        v_in = 0; t_in = 1; b_in = 1; #10;
        v_in = 1; t_in = 0; b_in = 0; #10;
        v_in = 1; t_in = 0; b_in = 1; #10;
        v_in = 1; t_in = 1; b_in = 0; #10;
        v_in = 1; t_in = 1; b_in = 1; #10;

        $finish;
    end

    initial
      $monitor("At time %2t, v_in = %d t_in = %d b_in = %d n_out = %d",
                $time, v_in, t_in, b_in, n_out);
endmodule // blackbox_test
