module machine(clk, reset);
   input        clk, reset;

   wire [31:0]  PC;
   wire [31:2]  next_PC, PC_plus4, PC_target;
   wire [31:0]  inst;

   wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
   wire [4:0]   rs = inst[25:21];
   wire [4:0]   rt = inst[20:16];
   wire [4:0]   rd = inst[15:11];

   wire [4:0]   wr_regnum;
   wire [2:0]   ALUOp;

   wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET;
   wire         PCSrc, zero, negative;
   wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

   // NEW WIRES
   wire [31:2] old_next_pc, middle_next_pc;
   wire [31:0] c0_rd_data, cycle, t_data, t_address;
   wire [31:0] c0_wr_data, old_wr_data;
   wire [31:0] TI_input;
   wire [29:0] EPC;
   wire        TimerInterrupt, TakenInterrupt, TimerAddress, not_io, Final_MemRead, Final_MemWrite;

   // END OF WIRES
   assign not_io = ~TimerAddress;
   assign TI_input = 32'h80000180;
   assign t_data = rd2_data;
   assign c0_wr_data = rd2_data;

   assign t_address = alu_out_data;
   assign cycle = load_data;

   register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, /* enable */1'b1, reset);
   assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
   adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
   adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);

   mux2v #(30) branch_mux(old_next_pc, PC_plus4, PC_target, PCSrc);
   mux2v #(30) pc_first_mux(middle_next_pc, old_next_pc, EPC, ERET);
   mux2v #(30) pc_second_mux(next_PC, middle_next_pc, TI_input[31:2], TakenInterrupt);

   assign PCSrc = BEQ & zero;

   instruction_memory imem (inst, PC[31:2]);

   mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET,
                      inst);

   regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum, wr_data,
               RegWrite, clk, reset);

   mux2v #(32) imm_mux(B_data, rd2_data, imm, ALUSrc);
   alu32 alu(alu_out_data, zero, negative, ALUOp, rd1_data, B_data);

   and a1(Final_MemRead, not_io, MemRead);
   and a2(Final_MemWrite, not_io, MemWrite);

   data_mem data_memory(load_data, alu_out_data, rd2_data, Final_MemRead, Final_MemWrite, clk, reset);

   mux2v #(32) wb_mux(old_wr_data, alu_out_data, load_data, MemToReg);
   mux2v #(32) c0_wb_mux(wr_data, old_wr_data, c0_rd_data, MFC0);
   mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

   cp0 cp_run(c0_rd_data, EPC, TakenInterrupt,rd2_data, rd, old_next_pc, MTC0, ERET, TimerInterrupt, clk, reset);
   timer t1(TimerInterrupt, load_data, TimerAddress, rd2_data, alu_out_data, MemRead, MemWrite, clk, reset);

endmodule // machine
