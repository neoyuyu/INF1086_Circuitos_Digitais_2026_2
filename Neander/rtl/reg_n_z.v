module reg_n_z (
    input  clk,
    input  rstn,   // reset assincrono, ativo em 0
    input  cargaNZ,
    input  n,
    input  z,
    output n_out,
    output z_out
);

	ff_d_carga ff_n (.d(n), .clk(clk), .rstn(rstn), .carga(cargaNZ), .q(n_out));
	ff_d_carga ff_z (.d(z), .clk(clk), .rstn(rstn), .carga(cargaNZ), .q(z_out));
	
endmodule

module ff_d_carga(
    input      d,
    input      clk,
    input      rstn,   // reset assincrono, ativo em 0
    input      carga,
    output reg q
);

  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      q <= 1'b0;
    else if (carga)
      q <= d;
  end

endmodule