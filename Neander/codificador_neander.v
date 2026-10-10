// Gabriel Tafarel
// Sayid Safa
//   000 = Y | 001 = ADD | 010 = AND | 011 = OR | 100 = NOT
// Codificador da ULA
module codificador_ula(
    input        ula_y,
    input        ula_add,
    input        ula_and,
    input        ula_or,
    input        ula_not,
    output [2:0] sel
);

    assign sel[2] = ula_not;               // 100
    assign sel[1] = ula_and | ula_or;      // 010 e 011
    assign sel[0] = ula_add | ula_or;      // 001 e 011

endmodule