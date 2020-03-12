module timer(TimerInterrupt, cycle, TimerAddress,
             data, address, MemRead, MemWrite, clock, reset);
    output        TimerInterrupt;
    output [31:0] cycle;
    output        TimerAddress;
    input  [31:0] data, address;
    input         MemRead, MemWrite, clock, reset;


    wire [31:0] address_compare, address_compare_2, Q_interrupt, Q_cycle, D_cycle;
    wire        address_is_equal, address_is_equal_2, interrupt_enable, interrupt_reset;
    wire        TimerWrite, TimerRead, Acknowledge;

    assign address_compare = 32'hffff001c;
    assign address_compare_2 = 32'hffff006c;
    assign address_is_equal = (address_compare == address);
    assign address_is_equal_2 = (address_compare_2 == address);
    assign interrupt_enable = (Q_cycle == Q_interrupt);

    or o1(TimerAddress, address_is_equal, address_is_equal_2);
    or o2(interrupt_reset, Acknowledge, reset);
    and a1(Acknowledge, address_is_equal_2, MemWrite);
    and a2(TimerWrite, address_is_equal, MemWrite);
    and a3(TimerRead, address_is_equal, MemRead);

    register #(32) interrupt_cycle(Q_interrupt, data, clock, TimerWrite, reset);
    register #(32) cycle_counter(Q_cycle, D_cycle, clock, 1'b1, reset);
    register #(1) interrupt_line(TimerInterrupt, 1'b1, clock, interrupt_enable, interrupt_reset);
    tristate t1(cycle, Q_cycle, TimerRead);
    alu32 increment(D_cycle, , , 3'b010, Q_cycle, 32'b1);

    // complete the timer circuit here

    // HINT: make your interrupt cycle register reset to 32'hffffffff
    //       (using the reset_value parameter)
    //       to prevent an interrupt being raised the very first cycle
endmodule
