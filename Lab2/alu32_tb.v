module alu32_test;
    reg [31:0] A = 0, B = 0;
    reg [2:0] control = 0;

    initial begin
        $dumpfile("alu32.vcd");
        $dumpvars(0, alu32_test);

            # 10 A = 8; B = 4; control = `ALU_ADD; // try adding 8 and 4
            # 10 A = 0; B = 0; control = `ALU_ADD; // try adding 0 and 0

            # 10 A = -6; B = 4; control = `ALU_ADD; // try adding -6 and 4
            # 10 A = -6; B = 6; control = `ALU_ADD; // try adding -6 and 6
            # 10 A = -6; B = 8; control = `ALU_ADD; // try adding -6 and 8

            # 10 A = 32'h7ffffffe; B = 1; control = `ALU_ADD; // try adding 2^31-2 and 1
            # 10 A = 32'h7fffffff; B = 1; control = `ALU_ADD; // try adding 2^31-1 and 1
            # 10 A = 32'h7fffffff; B = 2; control = `ALU_ADD; // try adding 2^31-1 and 2
            # 10 A = 32'h7fffffff; B = -10; control = `ALU_ADD; // try adding 2^31-1 and -10

            # 10 A = 32'h80000000; B = -1; control = `ALU_ADD; // try adding -2^31 and -1
            # 10 A = 32'h80000000; B = -2; control = `ALU_ADD; // try adding -2^31 and -2
            # 10 A = 32'h80000000; B = 36; control = `ALU_ADD; // try adding -2^31 and 36

            # 10 A = 32'h80000000; B = 32'h80000000; control = `ALU_ADD; // try adding -2^31 and -2^31
            # 10 A = 32'h7fffffff; B = 32'h7fffffff; control = `ALU_ADD; // try adding 2^31-1 and 2^31-1


        # 10 A = 0; B = 0; control = `ALU_SUB; // try subtracting 0 from 0
        # 10 A = 2; B = 5; control = `ALU_SUB; // try subtracting 5 from 2
        # 10 A = 5; B = 5; control = `ALU_SUB; // try subtracting 5 from 5
        # 10 A = -5; B = 5; control = `ALU_SUB; // try subtracting 5 from -5
        # 10 A = 5; B = -5; control = `ALU_SUB; // try subtracting -5 from 5
        # 10 A = 10; B = 32'h7ffffff0; control = `ALU_SUB; // try subtracting 2^31 -1 from 10
        # 10 A = 32'h7ffffff0; B = 32'h81101000; control = `ALU_SUB; // try subtracting very large negative number from large positive number

        # 10 A = 0; B = 0; control = `ALU_UADD; // try adding 0 to 0
        # 10 A = 10; B = 1; control = `ALU_UADD; // try adding 10 to 10
        # 10 A = 32'h7ffffff0; B = 32'h7fffff00; control = `ALU_UADD; // try adding large and large

        # 10 A = 0; B = 0; control = `ALU_AND;
        # 10 A = 1; B = 0; control = `ALU_AND;
        # 10 A = 0; B = 1; control = `ALU_AND;
        # 10 A = 1; B = 1; control = `ALU_AND;
        # 10 A = 32'h7ffffff0; B = 32'h000100111; control = `ALU_AND;

        # 10 A = 0; B = 0; control = `ALU_OR;
        # 10 A = 1; B = 0; control = `ALU_OR;
        # 10 A = 0; B = 1; control = `ALU_OR;
        # 10 A = 1; B = 1; control = `ALU_OR;
        # 10 A = 32'h7ffffff0; B = 32'h000100111; control = `ALU_OR;

        # 10 A = 0; B = 0; control = `ALU_NOR;
        # 10 A = 1; B = 0; control = `ALU_NOR;
        # 10 A = 0; B = 1; control = `ALU_NOR;
        # 10 A = 1; B = 1; control = `ALU_NOR;
        # 10 A = 32'h7ffffff0; B = 32'h000100111; control = `ALU_NOR;

        # 10 A = 0; B = 0; control = `ALU_XOR;
        # 10 A = 1; B = 0; control = `ALU_XOR;
        # 10 A = 0; B = 1; control = `ALU_XOR;
        # 10 A = 1; B = 1; control = `ALU_XOR;
        # 10 A = 32'h7ffffff0; B = 32'h000100111; control = `ALU_XOR;

        # 10 $finish;
    end

    wire [31:0] out;
    wire overflow, zero, negative;
    alu32 a(out, overflow, zero, negative, A, B, control);
endmodule // alu32_test
