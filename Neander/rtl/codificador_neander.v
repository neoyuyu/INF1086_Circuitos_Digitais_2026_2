// Gabriel Tafarel
// Sayid Safa
//   000 = Y | 001 = ADD | 010 = AND | 011 = OR | 100 = NOT
// Codificador da ULA
module codificador_neander(
    input            ula_y,
    input            ula_add,
    input            ula_and,
    input            ula_or,
    input            ula_not,
    output reg [2:0] sel
);
    always @(*) begin
        sel = 3'b000;                  // evita latch de outras operacoes

        if (ula_y)   sel = 3'b000;     // UAL(Y)
        if (ula_add) sel = 3'b001;     // UAL(ADD)
        if (ula_and) sel = 3'b010;     // UAL(AND)
        if (ula_or)  sel = 3'b011;     // UAL(OR)
        if (ula_not) sel = 3'b100;     // UAL(NOT)
    end
endmodule