// mips_decode: a decoder for MIPS arithmetic instructions
//
// rd_src      (output) - should the destination register be rd (0) or rt (1)
// writeenable (output) - should a new value be captured by the register file
// alu_src2    (output) - should the 2nd ALU source be a register (0), zero extended immediate or sign extended immediate
// alu_op      (output) - control signal to be sent to the ALU
// except      (output) - set to 1 when the opcode/funct combination is unrecognized
// opcode      (input)  - the opcode field from the instruction
// funct       (input)  - the function field from the instruction
//

module mips_decode(rd_src, writeenable, alu_src2, alu_op, except, opcode, funct);
    output       rd_src, writeenable, except;
    output [1:0] alu_src2;
    output [2:0] alu_op;
    input  [5:0] opcode, funct;

    wire  op_addu = ((opcode == `OP_OTHER0) && (funct == `OP0_ADDU));
    wire  op_addiu = opcode == `OP_ADDIU;

    wire  op_add = (opcode == `OP_OTHER0) && (funct == `OP0_ADD);
    wire  op_addi = opcode == `OP_ADDI;

    wire  op_and = (opcode == `OP_OTHER0) && (funct == `OP0_AND);
    wire  op_andi = opcode == `OP_ANDI;

    wire  op_or = (opcode == `OP_OTHER0) && (funct == `OP0_OR);
    wire  op_ori = opcode == `OP_ORI;

    wire  op_xor = (opcode == `OP_OTHER0) && (funct == `OP0_XOR);
    wire  op_xori = opcode == `OP_XORI;

    wire  op_nor = (opcode == `OP_OTHER0) && (funct == `OP0_NOR);
    wire  op_sub = (opcode == `OP_OTHER0) && (funct == `OP0_SUB);

    assign writeenable = op_addu | op_addiu | op_add | op_addi | op_and | op_andi | op_or | op_ori | op_xor | op_xori | op_nor | op_sub;
    assign except = ~writeenable;

    assign alu_op[0] = op_sub | op_or | op_ori | op_xor | op_xori;
    assign alu_op[1] = op_add | op_addi | op_sub | op_nor | op_xor | op_xori;
    assign alu_op[2] = op_and | op_andi | op_or | op_ori | op_nor | op_xor | op_xori;

    assign alu_src2[0] = op_addi | op_addiu;
    assign alu_src2[1] = op_andi | op_ori | op_xori;

    assign rd_src = op_addi | op_addiu | op_andi | op_ori | op_xori;

endmodule // mips_decode
