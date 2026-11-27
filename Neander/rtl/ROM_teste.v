// Versao Verilog equivalente a rtl/ROM_teste.vhd (para sintese/visualizacao RTL via Yosys)
module ROM_teste (
    input  wire [7:0] entrada,
    output reg  [7:0] saida
);
    always @(*) begin
        case (entrada)
            // PROGRAMA: compara posicoes 0x80 e 0x82. Carrega 1 no AC se sao iguais e 0 c.c.
            8'h00: saida = 8'h20; // LDA
            8'h01: saida = 8'h80; // 0x80
            8'h02: saida = 8'h60; // NOT
            8'h03: saida = 8'h30; // ADD
            8'h04: saida = 8'h81; // 0x81
            8'h05: saida = 8'h30; // ADD
            8'h06: saida = 8'h82; // 0x82
            8'h07: saida = 8'hA0; // JZ
            8'h08: saida = 8'h0D; // 0x0D
            8'h09: saida = 8'h20; // LDA
            8'h0A: saida = 8'h83; // 0x83
            8'h0B: saida = 8'h80; // JMP
            8'h0C: saida = 8'h0F; // 0x0F
            8'h0D: saida = 8'h20; // LDA
            8'h0E: saida = 8'h84; // 0x84
            8'h0F: saida = 8'hF0; // HLT

            // DADOS
            8'h80: saida = 8'h0A; // 0x0A = 10
            8'h81: saida = 8'h01; // 0x01 = 1
            8'h82: saida = 8'h0A; // 0x0A = 10
            8'h83: saida = 8'h00; // 0x00 = 0 (not equal)
            8'h84: saida = 8'h01; // 0x01 = 1 (equal)

            default: saida = 8'h00;
        endcase
    end
endmodule
