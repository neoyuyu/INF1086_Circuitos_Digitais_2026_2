// ULA 8 bits, complemento de 2 - versao estrutural
// Gabriel Tafarel
// Sayid Safa
// ULA do Neander, 8 bits - comportamental
module ula(
    input      [7:0] x,     
    input      [7:0] y,      
    input      [2:0] sel,    // seletor
    output reg [7:0] s,		  // output que vai para AC ao resultado
    output           n,      // flag negativo
    output           z       // flag zero
);

    always @(*) begin
        case (sel)
            3'b000:  s = y;         // UAL(Y)
            3'b001:  s = x + y;     // UAL(ADD)
            3'b010:  s = x & y;     // UAL(AND)
            3'b011:  s = x | y;     // UAL(OR)
            3'b100:  s = ~x;        // UAL(NOT)
            default: s = 8'b00000000;
        endcase
    end

    assign n = s[7];						// Flag último bit negativo
    assign z = ~|s;                 // NOR de todos os bits

endmodule