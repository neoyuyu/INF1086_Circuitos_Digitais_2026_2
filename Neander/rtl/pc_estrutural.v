module pc_estrutural (
    input  wire       clk,
    input  wire       rst,
    input  wire       cargaPC,       // Habilita carga paralela (JMP)
    input  wire       incrementaPC,  // Habilita incremento (+1)
    input  wire [7:0] data_in,       // Barramento de entrada
    output wire [7:0] pc             // Saída de 8 bits do PC
);

  wire [7:0] c;  // Vetor de propagação do carry

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_pc_bits
      pc_bit_slice bit_inst (
          .clk(clk),
          .rst(rst),
          .cargaPC(cargaPC),
          .incrementaPC(incrementaPC),
          .data_in(data_in[i]),
          .cin((i == 0) ? 1'b1 : c[i-1]),
          .q(pc[i]),
          .cout(c[i])
      );
    end
  endgenerate

endmodule

