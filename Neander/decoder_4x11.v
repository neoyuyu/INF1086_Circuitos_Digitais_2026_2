// Esse módulo descreve o decodificador do opcode.
// Recebe uma halfword (4bits) e decodifica para o bit da operação
// é importante notar que apesar de 4 bits de entrada, não temos 16 bits de
// saída, e sim apenas 11. Não existe representação para opcode decimal 7, 11,
// 12, 13 e 14. Esses opcodes serão mapeados para instrução NOP? Ou
// conseguimos tratar o erro?


module decoder_4x11 (
    input [3:0] opcode,
    output reg [10:0] operation
);

  always @* begin

    operation = 11'b0;  // Trata inferência de latch

    case (opcode)
      4'b0000: operation[0] = 1;
      4'b0001: operation[1] = 1;
      4'b0010: operation[2] = 1;
      4'b0011: operation[3] = 1;
      4'b0100: operation[4] = 1;
      4'b0101: operation[5] = 1;
      4'b0110: operation[6] = 1;
      4'b1000: operation[7] = 1;  // Notar que pula o opcode decima 7
      4'b1001: operation[8] = 1;
      4'b1010: operation[9] = 1;
      4'b1111: operation[10] = 1;  // Notar que pula tbm o 11, 12, 13 e 14
      default: operation[0] = 1;  // caso contrário, não faz nada "NOP"
    endcase

  end

endmodule
