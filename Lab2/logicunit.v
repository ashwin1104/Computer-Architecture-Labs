// 00 -> AND, 01 -> OR, 10 -> NOR, 11 -> XOR
module logicunit(out, A, B, control);
    output      out;
    input       A, B;
    input [1:0] control;
    wire        wAnd, wOr, wNor, wXor, AandB, AorB, AnorB, AxorB, not_control_one, not_control_zero;

    not n1(not_control_zero, control[0]);
    not n2(not_control_one, control[1]);
    and a1(AandB, A, B);
    or o1(AorB, A, B);
    nor no1(AnorB, A, B);
    xor x1(AxorB, A, B);
    and a1(wAnd, AandB, not_control_one, not_control_zero);
    and a2(wOr, AorB, not_control_one, control[0]);
    and a3(wNor, AnorB, control[1], not_control_zero);
    and a4(wXor, AxorB, control[1], control[0]);

    or o1(out, wAnd, wOr, wNor, wXor);

endmodule // logicunit
