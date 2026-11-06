// Gabriel Tafarel
// Sayid Safa
// Módulo Temporizador do Neander (Contador síncrono de 3 bits + Decodificador 3x8)
// Reutiliza pc_bit_slice (e ff_async) definidos em pc_estrutural.v

module decod_3x8 (
    input  wire [2:0] count,
    output wire [7:0] t
);

  assign t[0] = ~count[2] & ~count[1] & ~count[0];
  assign t[1] = ~count[2] & ~count[1] &  count[0];
  assign t[2] = ~count[2] &  count[1] & ~count[0];
  assign t[3] = ~count[2] &  count[1] &  count[0];
  assign t[4] =  count[2] & ~count[1] & ~count[0];
  assign t[5] =  count[2] & ~count[1] &  count[0];
  assign t[6] =  count[2] &  count[1] & ~count[0];
  assign t[7] =  count[2] &  count[1] &  count[0];

endmodule

module temporizador (
    input  wire       clk,
    input  wire       rst,
    input  wire       goto_t0,
    input  wire       hlt,
    output wire [7:0] t
);

  wire [2:0] count;
  wire [2:0] c;  // Vetor de propagação do carry
  wire       halt_t3;

  // Congela o temporizador em t3 quando a instrução é HLT
  assign halt_t3 = hlt & t[3];

  genvar i;
  generate
    for (i = 0; i < 3; i = i + 1) begin : gen_temp_bits
      // Em pc_bit_slice: d_in_ff = (cargaPC) ? data_in : (incrementaPC) ? soma : q
      // - cargaPC = goto_t0 & ~halt_t3 com data_in = 0 -> zera o contador (volta para t0)
      // - incrementaPC = ~halt_t3                      -> incrementa quando não está em HLT
      // - quando halt_t3 = 1                           -> mantém q (congela)
      pc_bit_slice bit_inst (
          .clk         (clk),
          .rst         (rst),
          .cargaPC     (goto_t0 & ~halt_t3),
          .incrementaPC(~halt_t3),
          .data_in     (1'b0),
          .cin         ((i == 0) ? 1'b1 : c[i-1]),
          .q           (count[i]),
          .cout        (c[i])
      );
    end
  endgenerate

  decod_3x8 decod_inst (
      .count(count),
      .t    (t)
  );

endmodule
