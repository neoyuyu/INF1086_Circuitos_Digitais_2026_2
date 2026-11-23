// Gabriel Tafarel
// Sayid Safa
// Flip-flop D mestre-escravo, borda de subida, reset assincrono ativo em 0.
// Cada latch e escrito como mux com realimentacao (q = en ? d : q): o Quartus
// reconhece como latch
module ff_d (
    input  d,
    input  clk,
    input  rstn,  // reset assincrono, ativo em 0
    output q,
    output qn
);

  wire qm;  // saida do latch mestre

  // Latch mestre: transparente com clk = 0, segura com clk = 1
  assign qm = ~rstn ? 1'b0 : (~clk ? d : qm);

  // Latch escravo: transparente com clk = 1, segura com clk = 0
  assign q  = ~rstn ? 1'b0 : (clk ? qm : q);

  assign qn = ~q;

endmodule
