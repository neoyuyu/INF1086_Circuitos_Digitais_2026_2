// Gabriel Tafarel
// Sayid Safa
// Decodificador de instrucoes 
module decodificador_instrucoes(
    input  [3:0] operacao,
    output lda, sta, add, _or, _and, _not, jn, jz, hlt, jmp, nop
);
    
	 //mapeamento das instrucoes
    assign sta  = (operacao == 4'b0001);
    assign lda  = (operacao == 4'b0010);
    assign add  = (operacao == 4'b0011);
    assign _or  = (operacao == 4'b0100);
    assign _and = (operacao == 4'b0101);
    assign _not = (operacao == 4'b0110);
    assign jmp  = (operacao == 4'b1000);
    assign jn   = (operacao == 4'b1001);
    assign jz   = (operacao == 4'b1010);
    assign hlt  = (operacao == 4'b1111);
	 
	 //instrucoes nao mapeadas vao para nop
	 assign nop = 
	 (operacao == 4'b0000) | (operacao == 4'b0111) | (operacao == 4'b1011) |(operacao == 4'b1100) | (operacao == 4'b1101) |
    (operacao == 4'b1110);
	 
endmodule