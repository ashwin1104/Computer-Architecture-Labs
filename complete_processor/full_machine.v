// full_machine: execute a series of MIPS instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock   (input) - the clock signal
// reset   (input) - set to 1 to set all registers to zero, set to 0 for normal execution.

module full_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst, PC, nextPC, z_ext, s_ext, w_data, Rrt, Rrs, B, pc_0, pc_1, pc_2, pc_3, branch_offset, data_in, mem_read_0, mem_read_1, mem_addr, negative_ext, lui_0, data_out, byte_load_1, addr, addm_sel_0, addm_sel_1;
    wire [15:0] imm16 = inst[15:0];
    wire [7:0] byte_load_1_eight;
    wire [5:0] opcode = inst[31:26];
    wire [5:0] funct = inst[5:0];
    wire [4:0] rs = inst[25:21];
    wire [4:0] rt = inst[20:16];
    wire [4:0] rd = inst[15:11];
    wire [4:0] w_addr;
    wire [2:0] alu_op;
    wire [1:0] alu_src2, control_type, byte_select;
    wire zero, negative, rd_src, wr_enable, mem_read, word_we, byte_we, byte_load, slt, lui, addm;

    // PC stuff
    register #(32) PC_reg(PC, nextPC, clock, 1'b1, reset);
    alu32 #(32) a2(pc_0, , , , PC, 32'b100, 3'b010);
    instruction_memory im(inst, PC[31:2]);
    alu32 #(32) a3(pc_1, , , , pc_0, branch_offset, 3'b010);
    assign pc_2 = {pc_0[31:28], inst[25:0], 2'b00};
    assign pc_3 = Rrs;
    mux4v #(32) mx1(nextPC, pc_0, pc_1, pc_2, pc_3, control_type);

    // rest
    assign branch_offset[31:0] = {s_ext[29:0], 2'b00};
    assign z_ext[31:16] = {16{zero}};
    assign s_ext[31:16] = {16{imm16[15]}};
    assign z_ext[15:0] = imm16[15:0];
    assign s_ext[15:0] = imm16[15:0];

    assign data_in[31:0] = Rrt[31:0];
    assign negative_ext[31:0] = {31'b0, negative};
    assign byte_select[1:0] = addr[1:0];
    assign byte_load_1[31:0] = {24'b0, byte_load_1_eight[7:0]};

    mux2v #(5) m1(w_addr, rd, rt, rd_src);
    mux2v #(32) m2(mem_read_0, mem_addr, negative_ext, slt);
    mux2v #(32) m3(lui_0, mem_read_0, mem_read_1, mem_read);
    mux2v #(32) m4(addm_sel_0, lui_0, {imm16, 16'b0}, lui);
    mux2v #(32) m5(mem_read_1, data_out, byte_load_1, byte_load);
    mux2v #(32) m6(addr, mem_addr, Rrs, addm);
    mux2v #(32) m7(w_data, addm_sel_0, addm_sel_1, addm);
    mux3v #(32) mu1(B, Rrt, s_ext, z_ext, alu_src2);
    mux4v #(8) mx2(byte_load_1_eight, data_out[7:0], data_out[15:8], data_out[23:16], data_out[31:24], byte_select);
    alu32 #(32) a1(mem_addr, , zero, negative, Rrs, B, alu_op);
    alu32 #(32) a4(addm_sel_1, , , , addm_sel_0, Rrt, 3'b010);
    mips_decode mi1(alu_op, wr_enable, rd_src, alu_src2, except, control_type, mem_read, word_we, byte_we, byte_load, slt, lui, addm, opcode, funct, zero);
    data_mem d1(data_out, addr, data_in, word_we, byte_we, clock, reset);
    regfile rf(Rrs, Rrt, rs, rt, w_addr, w_data, wr_enable, clock, reset);

endmodule // full_machine
