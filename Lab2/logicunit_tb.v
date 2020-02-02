module logicunit_test;
    // cycle through all combinations of A and B every 4 time units
    reg A = 0;
    always #1 A = !A;
    reg B = 0;
    always #2 B = !B;

    reg [1:0] control = 0;

    initial begin
        $dumpfile("logicunit.vcd");
        $dumpvars(0, logicunit_test);

        // control is initially 0
        # 4 control = 1; // wait 4 time units (why 4?) and then set it to 1
        # 4 control = 2; // wait 4 time units and then set it to 2
        # 4 control = 3; // wait 4 time units and then set it to 3
        # 4 $finish; // wait 4 time units and then end the simulation
    end

    wire out;
    logicunit lu(out, A, B, control);

    // you really should be using gtkwave instead
    /*
    initial begin
        $display("A B C D s o");
        $monitor("%d %d %d %d %d %d (at time %t)", A, B, C, D, control, out, $time);
    end
    */
endmodule // logicunit_test
