module codprioridade (
    input  wire [7:0] d,    // d[7]=D7 (prioridade) ... d[0]=D0
    output wire [2:0] q,    // q[2]=Q2, q[1]=Q1, q[0]=Q0
    output wire       v
);

    // Bit de validade (OU de todas as entradas)
    assign v = |d; // Equivalente a: d[7] | d[6] | d[5] | d[4] | d[3] | d[2] | d[1] | d[0]

    // Saída Q2
    assign q[2] = d[7] | d[6] | d[5] | d[4];

    // Saída Q1
    assign q[1] = d[7] | d[6] | 
                  ((~d[5]) & (~d[4]) & (d[3] | d[2]));

    // Saída Q0
    assign q[0] = d[7] | 
                  ((~d[6]) & d[5]) | 
                  ((~d[6]) & (~d[4]) & d[3]) | 
                  ((~d[6]) & (~d[4]) & (~d[2]) & d[1]);

endmodule