module bit_slice (
    input  clk,
    rstn,
    carga,
    carga_sel,
    output saida
);

wire entrada;

assign entrada = carga_sel ? carga : saida;

ff_d inst(
    .d(entrada),
    .clk(clk),
    .rstn(rstn),
    .q(saida)
);

endmodule
