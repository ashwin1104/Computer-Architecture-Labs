module sc2_block(s, cout, a, b, cin);
    output s, cout;
    input a, b, cin;
    wire w1, w2, w3;

    // using module sc_block
    sc_block sc0(w1, w2, a, b);
    sc_block sc1(s, w3, w1, cin);

    // "cout" output is the OR of the two sc_block outputs w3 and w2
    or o1(cout, w3, w2);

endmodule // sc2_block
