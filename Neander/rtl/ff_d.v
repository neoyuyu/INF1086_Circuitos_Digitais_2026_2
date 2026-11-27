// Gabriel Tafarel
// Sayid Safa
// Flip-flop D, borda de subida, reset assincrono ativo em 0.
module ff_d (
    input      d,
    input      clk,
    input      rstn,  // reset assincrono, ativo em 0
    output reg q,
    output     qn
);

  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      q <= 1'b0;
    else
      q <= d;
  end

  assign qn = ~q;

endmodule
