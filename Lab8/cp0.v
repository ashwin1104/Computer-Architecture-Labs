`define STATUS_REGISTER 5'd12
`define CAUSE_REGISTER  5'd13
`define EPC_REGISTER    5'd14

module cp0(rd_data, EPC, TakenInterrupt,
           wr_data, regnum, next_pc,
           MTC0, ERET, TimerInterrupt, clock, reset);
    output [31:0] rd_data;
    output [29:0] EPC;
    output        TakenInterrupt;
    input  [31:0] wr_data;
    input   [4:0] regnum;
    input  [29:0] next_pc;
    input         MTC0, ERET, TimerInterrupt, clock, reset;

// new stuff
    wire [31:0] cause_register, status_register, user_status, d_out, epc_zext;
    wire [29:0] epc_d;
    wire timer_interrupt_mask, exception_and_status, exception_reset, exception_level, epc_enable, user_enable, not_s1;

    assign status_register[31:0] = {16'b0, user_status[15:8], 6'b0, exception_level, user_status[0]};
    assign cause_register[31:0] = {16'b0, TimerInterrupt, 15'b0};
    assign epc_zext[31:0] = {EPC[29:0], 2'b0};

    and a1(timer_interrupt_mask, cause_register[15], status_register[15]);
    not n1(not_s1, status_register[1]);
    and a2(exception_and_status, not_s1, status_register[0]);
    and a3(TakenInterrupt, timer_interrupt_mask, exception_and_status);
    or o1(exception_reset, ERET, reset);
    or o2(epc_enable, d_out[14], TakenInterrupt);

    assign user_enable = d_out[12];


    mux2v #(30) m1(epc_d, wr_data[31:2], next_pc, TakenInterrupt);
    mux3v #(32) m2(rd_data, status_register, cause_register, epc_zext, regnum[1:0]);

    decoder32 regnum_dec(d_out, regnum, MTC0);

    register #(1) ex_lvl(exception_level, 1'b1, clock, TakenInterrupt, exception_reset);
    register #(32) user_stat(user_status, wr_data, clock, user_enable, reset);
    register #(30) epc_reg(EPC, epc_d, clock, epc_enable, reset);
endmodule
