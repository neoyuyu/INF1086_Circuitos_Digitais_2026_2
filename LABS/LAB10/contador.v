// Gabriel Tafarel
// Sayid Safa
//   sel = 00: carga paralela   (Qt <- D)
//   sel = 01: armazenamento    (Qt <- Qt-1)
//   sel = 10: incremento       (Qt <- Qt-1 + 1)
//   sel = 11: decremento       (Qt <- Qt-1 - 1)

module contador_bit (
    input  d,
    input  sel_carga,
    input  sel_mantem,
    input  sel_inc,
    input  sel_dec,
    input  cin_sobe,
    input  cin_desce,
    input  clk,
    input  rstn,
    output q,
    output cout_sobe,
    output cout_desce
);

  // Propagacao das cadeias de vai-um (sobe) e pede-emprestado (desce)
  assign cout_sobe  = cin_sobe & q;
  assign cout_desce = cin_desce & ~q;

  // Quatro opcoes de proximo estado para o bit
  wire proximo_carga = d;
  wire proximo_mantem = q;
  wire proximo_inc = q ^ cin_sobe;
  wire proximo_dec = q ^ cin_desce;

  // MUX 4:1 em AND-OR: so a opcao escolhida passa
  wire proximo = (sel_carga  & proximo_carga)
               | (sel_mantem & proximo_mantem)
               | (sel_inc    & proximo_inc)
               | (sel_dec    & proximo_dec);

  ff_d FF (
      .d(proximo),
      .clk(clk),
      .rstn(rstn),
      .q(q),
      .qn()
  );

endmodule

module contador (
    input  [7:0] d,     // dado para carga paralela
    input  [1:0] sel,   // selecao da operacao
    input        clk,
    input        rstn,  // reset assincrono, ativo em 0
    output [7:0] q
);

  wire sel_carga  = ~sel[1] & ~sel[0];   // 00
  wire sel_mantem = ~sel[1] &  sel[0];   // 01
  wire sel_inc    =  sel[1] & ~sel[0];   // 10
  wire sel_dec    =  sel[1] &  sel[0];   // 11

  // ---- Cadeias de toggle ----
  // sobe[i]  = 1 quando todos os bits abaixo de i sao 1 (vai-um)
  // desce[i] = 1 quando todos os bits abaixo de i sao 0 (pede emprestado)
  wire [8:0] sobe;
  wire [8:0] desce;
  assign sobe[0]  = 1'b1;  // o bit 0 sempre inverte
  assign desce[0] = 1'b1;

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_bit_contador
      contador_bit BIT (
          .d(d[i]),
          .sel_carga(sel_carga),
          .sel_mantem(sel_mantem),
          .sel_inc(sel_inc),
          .sel_dec(sel_dec),
          .cin_sobe(sobe[i]),
          .cin_desce(desce[i]),
          .clk(clk),
          .rstn(rstn),
          .q(q[i]),
          .cout_sobe(sobe[i+1]),
          .cout_desce(desce[i+1])
      );
    end
  endgenerate

endmodule
