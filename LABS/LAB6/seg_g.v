module seg_g(
    input  [3:0] E,
    output       S
);
    // segG = Soma m(0, 1, 7, 12)   (1 apaga, 0 acende)
    assign S = (~E[3] & ~E[2] & ~E[1])             // m0 e m1
             | (~E[3] &  E[2] &  E[1] &  E[0])     // m7
             | ( E[3] &  E[2] & ~E[1] & ~E[0]);    // m12
endmodule