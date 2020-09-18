module keypad(valid, number, a, b, c, d, e, f, g);
   output valid;
   output [3:0] number;
   input 	a, b, c, d, e, f, g;
   wire zero, one, two, three, four, five, six, seven, eight, nine;

   or o0(valid, a, b, c);

   and a0(zero, b, g);
   and a1(one, a, d);
   and a2(two, b, d);
   and a3(three, c, d);
   and a4(four, a, e);
   and a5(five, b, e);
   and a6(six, c, e);
   and a7(seven, a, f);
   and a8(eight, b, f);
   and a9(nine, c, f);

   or o1(number[3], eight, nine);
   or o2(number[2], e, seven);
   or o3(number[1], two, three, six, seven);
   or o4(number[0], one, three, five, seven, nine);

endmodule // keypad
