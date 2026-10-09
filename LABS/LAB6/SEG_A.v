module seg_a (
    input  A,
    input  B,
    input  C,
    input  D,
    output Y
);

    wire parte1;
    wire parte2;
    wire parte3;

    assign parte1 = (~A | B | C) & (~A | D);
    assign parte2 = (A | ~B | ~D) & (A | ~C);
    assign parte3 = (~B | ~C) & (B | D);

    assign Y = parte1 & parte2 & parte3;

endmodule
