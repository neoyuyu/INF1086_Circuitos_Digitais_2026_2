module ff_async (
    input clk,
    rst,
    d,
    output reg q
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      q <= 1'b0;
    end else begin
      q <= d;
    end
  end

endmodule

module pc_bit_slice (  // Menor unidade que resolve o problema
    input  wire clk,
    input  wire rst,
    input  wire cargaPC,
    input  wire incrementaPC,
    input  wire data_in,
    input  wire cin,
    output wire q,
    output wire cout
);
  wire soma;
  wire d_in_ff;

  // Lógica do incremento (half-adder)
  assign soma    = q ^ cin;
  assign cout    = q & cin;

  // Lógica de seleção (Multiplexador para a entrada D)
  assign d_in_ff = (cargaPC) ? data_in : (incrementaPC) ? soma : q;

  // Instanciação do flip-flop (atômico)
  ff_async ff_inst (
      .clk(clk),
      .rst(rst),
      .d  (d_in_ff),
      .q  (q)
  );
endmodule

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

