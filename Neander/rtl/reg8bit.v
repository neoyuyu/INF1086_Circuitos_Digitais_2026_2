module reg8bit (
    input        sinal_carga,
    clk,
    rstn,
    input  [7:0] entrada,
    output [7:0] saida
);

  genvar i;
  generate
    for (i = 0; i <= 7; i = i + 1) begin : gen_bits
      bit_slice bits (
          .clk(clk),
          .rstn(rstn),
          .carga(entrada[i]),
          .carga_sel(sinal_carga),
          .saida(saida[i])
      );

    end
  endgenerate

endmodule

