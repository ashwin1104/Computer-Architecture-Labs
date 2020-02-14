// arith_machine: execute a series of arithmetic instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock  (input)  - the clock signal
// reset  (input)  - set to 1 to set all registers to zero, set to 0 for normal execution.

module arith_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;
    wire [31:0] PC;
    wire [31:0] nextPC;

    wire [4:0] rt = inst[25:21];
    wire [4:0] rs = inst[20:16];
    wire [4:0] rd = inst[15:11];
    wire [31:0] w_addr;

    wire [15:0] imm16 = inst[15:0];
    wire [5:0] opcode = inst[31:26];
    wire [5:0] funct = inst[5:0];

    wire rd_src, wr_enable;
    wire zero = 0;

    wire [2:0] alu_op;
    wire [1:0] alu_src2;
    wire [31:0] rd_32;
    wire [31:0] rt_32;

    wire [31:0] z_ext;
    wire [31:0] s_ext;
    wire [31:0] w_data;
    wire [31:0] B;
    wire [31:0] B2;
    wire [31:0] A;

    register #(32) PC_reg(PC, nextPC, clock, 1'b1, reset);
    alu32 a2(nextPC, , , , PC, 32'h4, `ALU_ADDU);
    instruction_memory im(inst[31:0], PC[31:2]);

    assign rd_32[31:5] = {27{zero}};
    assign rd_32[4:0] = rd[4:0];
    assign rt_32[31:5] = {27{zero}};
    assign rt_32[4:0] = rt[4:0];

    assign z_ext[31:16] = {16{zero}};
    assign s_ext[31:16] = {16{imm16[15]}};
    assign z_ext[15:0] = imm16[15:0];
    assign s_ext[15:0] = imm16[15:0];
    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (A, B, rs, rt, w_addr[5:0], w_data, wr_enable, clock, reset);

    mux2v m1(w_addr, rd_32, rt_32, rd_src);

    mux3v mu1(B2, B, s_ext, z_ext, alu_src2);

    alu32 a1(w_data, , , , A, B2, alu_op);
    mips_decode mi1(rd_src, wr_enable, alu_src2, alu_op, except, opcode, funct);

endmodule // arith_machine
