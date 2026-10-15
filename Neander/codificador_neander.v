// Gabriel Tafarel
// Sayid Safa
//   000 = Y | 001 = ADD | 010 = AND | 011 = OR | 100 = NOT
// Codificador da ULA
module codificador_ula(
    input      [10:0] operation,
    output reg [2:0]  sel
);
    always @(*) begin
        sel = 3'b000;                 		 // evita latch de outras operacoes
		  
        if (operation[2]) sel = 3'b000;   // LDA -> Y ???
        if (operation[3]) sel = 3'b001;   // ADD
        if (operation[5]) sel = 3'b010;   // AND
        if (operation[4]) sel = 3'b011;   // OR
        if (operation[6]) sel = 3'b100;   // NOT
    end
endmodule