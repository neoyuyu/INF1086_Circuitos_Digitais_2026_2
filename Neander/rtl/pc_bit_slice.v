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
  ff_d ff_inst (
      .d   (d_in_ff),
      .clk (clk),
      .rstn(~rst),
      .q   (q),
      .qn  ()
  );
endmodule
