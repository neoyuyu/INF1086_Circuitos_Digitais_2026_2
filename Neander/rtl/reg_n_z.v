module reg_n_z (
    input  clk,
    input  cargaNZ,
    input  n,
    input  z,
    output n_out,
    output z_out
);
	
	ff_d_carga ff_n (.d(n), .clk(clk), .rstn(1'b1), .carga(cargaNZ), .q(n_out));
	ff_d_carga ff_z (.d(z), .clk(clk), .rstn(1'b1), .carga(cargaNZ), .q(z_out));
	
endmodule

module ff_d_carga(
    input  d,
    input  clk,
    input  rstn,   //reset para dar valor inicial correto
    input  carga,
    output q

);
    wire d_in = carga ? d : q;      

    wire qm;                         // saida do latch mestre

    // latch mestre: transparente com clk=0, segura com clk=1
    assign qm = ~rstn ? 1'b0 : (~clk ? d_in : qm);

    // latch escravo: transparente com clk=1, segura com clk=0
    assign q  = ~rstn ? 1'b0 : (clk ? qm : q);
endmodule