module seg_b(
    input  [3:0] E,
    output       S
);
    // segB = Soma m(5, 6, 11, 12, 14, 15)   (1 apaga, 0 acende)
    assign S = ( E[3] &  E[2] &  E[1])             // m14 e m15
             | ( E[3] &  E[2] & ~E[0])             // m12 e m14
             | (~E[3] &  E[2] & ~E[1] &  E[0])     // m5
             | (~E[3] &  E[2] &  E[1] & ~E[0])     // m6
             | ( E[3] & ~E[2] &  E[1] &  E[0]);    // m11
endmodule