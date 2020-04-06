module pipelined_machine(clk, reset);
    input        clk, reset;

    wire [31:0]  PC;
    wire [31:2]  next_PC, PC_plus4, PC_target;
    wire [31:0]  inst;

    wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
    wire [4:0]   rs = inst[25:21];
    wire [4:0]   rt = inst[20:16];
    wire [4:0]   rd = inst[15:11];
    wire [5:0]   opcode = inst[31:26];
    wire [5:0]   funct = inst[5:0];

    wire [4:0]   wr_regnum;
    wire [2:0]   ALUOp;

    wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst;
    wire         PCSrc, zero;
    wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

    assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
    assign PCSrc = BEQ & zero;

    wire [31:0]  inst_piped, rd2_data_init, rd2_data_piped, alu_in_data_1, alu_out_data_piped;

    wire [29:0] PC_plus4_piped;
    wire [4:0]   wr_regnum_piped;

    wire is_stalling, fwdB, fwdA;
    wire         RegWrite_piped, MemRead_piped, MemWrite_piped, MemToReg_piped;


    assign fwdA = !(rs == 0) & RegWrite==1 & (wr_regnum == rs);
    assign fwdB = !(rt ==0) & RegWrite == 1 & (wr_regnum == rt);
    assign is_stalling = (MemRead == 1) && (((wr_regnum == rs) && !(rs == 0)) || ((wr_regnum == rt) & !(rt == 0)));

    register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, /* enable */~is_stalling, reset);

    register #(32) piped_inst(inst, inst_piped, clk, /* enable */~is_stalling, reset||PCSrc);

    adder30 next_PC_adder(PC_plus4_piped, PC[31:2], 30'h1);
    adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
    mux2v #(30) branch_mux(next_PC, PC_plus4_piped, PC_target, PCSrc);

    data_mem data_memory(load_data, alu_out_data, rd2_data, MemRead, MemWrite, clk, reset);
    register #(30) piped_pcp4(PC_plus4, PC_plus4_piped, clk, /* enable */~is_stalling, reset||PCSrc);
    instruction_memory imem(inst_piped, PC[31:2]);
    regfile rf (rd1_data, rd2_data_init,
               rs, rt, wr_regnum, wr_data,
               RegWrite, clk, reset);
               
    mux2v #(32) wb_mux(wr_data, alu_out_data, load_data, MemToReg);
    mux2v #(32) Afwd_mux(alu_in_data_1, rd1_data, alu_out_data, fwdA);
    mux2v #(32) Bfwd_mux(rd2_data_piped, rd2_data_init, alu_out_data, fwdB);
    mux2v #(32) imm_mux(B_data, rd2_data_piped, imm, ALUSrc);
    mux2v #(5) rd_mux(wr_regnum_piped, rt, rd, RegDst);

    alu32 alu(alu_out_data_piped, zero, ALUOp, alu_in_data_1, B_data);

    mips_decode decode(ALUOp, RegWrite_piped, BEQ, ALUSrc, MemRead_piped, MemWrite_piped, MemToReg_piped, RegDst,
                      opcode, funct);

    register #(32) piped_rd2data(rd2_data, rd2_data_piped, clk, /* enable */1'b1, reset||PCSrc);
    register #(32) piped_aluout(alu_out_data, alu_out_data_piped, clk, /* enable */1'b1, reset||PCSrc);
    register #(5) piped_wrregnum(wr_regnum, wr_regnum_piped, clk, /* enable */1'b1, reset||PCSrc);
    register #(1) piped_regwrite(RegWrite, RegWrite_piped, clk, /* enable */1'b1, reset||PCSrc);
    register #(1) piped_memwrite(MemWrite, MemWrite_piped, clk, /* enable */1'b1, reset||PCSrc);
    register #(1) piped_memread(MemRead, MemRead_piped, clk, /* enable */1'b1, reset||PCSrc);
    register #(1) piped_memtoreg(MemToReg, MemToReg_piped, clk, /* enable */1'b1, reset||PCSrc);
endmodule // pipelined_machine
