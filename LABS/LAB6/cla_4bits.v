module cla_4bits (
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] S,
    output       Cout
);

    wire [3:0] P;
    wire [3:0] G;
    wire [4:0] C;

    assign C[0] = Cin;

    // Propagate e Generate
    assign P = A ^ B;
    assign G = A & B;

    // Carry Look-Ahead
    assign C[1] = G[0] |
                  (P[0] & C[0]);

    assign C[2] = G[1] |
                  (P[1] & G[0]) |
                  (P[1] & P[0] & C[0]);

    assign C[3] = G[2] |
                  (P[2] & G[1]) |
                  (P[2] & P[1] & G[0]) |
                  (P[2] & P[1] & P[0] & C[0]);

    assign C[4] = G[3] |
                  (P[3] & G[2]) |
                  (P[3] & P[2] & G[1]) |
                  (P[3] & P[2] & P[1] & G[0]) |
                  (P[3] & P[2] & P[1] & P[0] & C[0]);

    // Soma
    assign S = P ^ C[3:0];

    assign Cout = C[4];

endmodule
