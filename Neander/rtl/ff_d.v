// Gabriel Tafarel
// Sayid Safa
// Flip-flopD baseado no lab5: com latch mestre-escravo, borda de subida, reset assincrono ativo em 0.
module ff_d(
    input  d,
    input  clk,
    input  rstn,         // reset assincrono, ativo em 0
    output q,
    output qn
);

    // Clocks dos latches
    wire clk_n = ~clk;        // mestre transparente com clk = 0
    wire clk_p = ~clk_n;      // escravo transparente com clk = 1

    // Latch mestre
    wire d_n = ~d;
    wire m1  = ~(d   & clk_n & rstn);    // NAND3
    wire m2  = ~(d_n & clk_n);           // NAND2
    wire qm, qm_n;
    assign qm   = ~(m1 & qm_n);          // NAND2
    assign qm_n = ~(m2 & qm & rstn);     // NAND3

    // Latch escravo
    wire qm_inv = ~qm;
    wire s1 = ~(qm & clk_p & rstn);  // NAND3
    wire s2 = ~(qm_inv & clk_p);         // NAND2
    assign q  = ~(s1 & qn);              // NAND2
    assign qn = ~(s2 & q & rstn);        // NAND3

endmodule