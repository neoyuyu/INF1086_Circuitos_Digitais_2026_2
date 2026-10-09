module seg_E (
	input [3:0] in,
	output segE
);

// Representação da Soma e Produto (SOP) para o segmento E
// 1 apaga, 0 acende

	
	//SE for ímpar menor que 8 OU SE for 4 ou 5 OU SE for 1 ou 9
	assign segE = 	(~in[3] & in[0]) | (~in[3] & in[2] & ~in[1]) | (~in[2] & ~in[1] & in[0]); 

	
endmodule


						