// Gabriel Tafarel
// Sayid Safa
// Unidade de Controle do Neander integrada com o Decodificador 4x11 e o Temporizador

module unidade_controle (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] opcode,        // Opcode vindo do RI (4 bits mais significativos)
    input  wire       n,             // Flag N (negativo) vindo da ULA / reg NZ
    input  wire       z,             // Flag Z (zero) vindo da ULA / reg NZ
    output wire       cargaREM,
    output wire       incrementaPC,
    output wire       cargaRI,
    output wire       sel,
    output wire       cargaRDM,
    output wire       read,
    output wire       write,
    output wire       ula_y,
    output wire       ula_add,
    output wire       ula_or,
    output wire       ula_and,
    output wire       ula_not,
    output wire       cargaAC,
    output wire       cargaNZ,
    output wire       cargaPC,
    output wire       goto_t0,
    output wire       hlt,
    output wire       illegal_op,
    output wire [7:0] t              // Sinais de tempo t0..t7 (para depuração/testes)
);

  // Sinais decodificados das instruções
  wire [10:0] operation;

  decoder_4x11 decod_inst (
      .opcode    (opcode),
      .operation (operation),
      .illegal_op(illegal_op)
  );

  // Mapeamento das instruções conforme decoder_4x11.v
  wire nop    = operation[0];   // 0000
  wire sta    = operation[1];   // 0001
  wire lda    = operation[2];   // 0010
  wire add    = operation[3];   // 0011
  wire or_op  = operation[4];   // 0100
  wire and_op = operation[5];   // 0101
  wire not_op = operation[6];   // 0110
  wire jmp    = operation[7];   // 1000
  wire jn     = operation[8];   // 1001
  wire jz     = operation[9];   // 1010
  assign hlt  = operation[10];  // 1111

  // Instanciação do Temporizador (gera t0..t7)
  temporizador temp_inst (
      .clk    (clk),
      .rst    (rst),
      .goto_t0(goto_t0),
      .hlt    (hlt),
      .t      (t)
  );

  wire t0 = t[0];
  wire t1 = t[1];
  wire t2 = t[2];
  wire t3 = t[3];
  wire t4 = t[4];
  wire t5 = t[5];
  wire t6 = t[6];
  wire t7 = t[7];

  // Agrupamentos auxiliares recorrentes nas equações de controle
  wire op_mem_ac  = lda | add | or_op | and_op;
  wire op_mem_all = sta | op_mem_ac;
  wire op_desvio  = jmp | (jn & n) | (jz & z);
  wire op_nao_des = (jn & ~n) | (jz & ~z);

  // Expressões booleanas dos sinais de controle (Neander - Organização - Part. 2)
  // carga REM = t0 + t3.(STA+LDA+ADD+OR+AND+JMP+JN.N+JZ.Z) + t5.(STA+LDA+ADD+OR+AND)
  assign cargaREM     = t0 | (t3 & (op_mem_all | op_desvio)) | (t5 & op_mem_all);

  // incrementa PC = t1 + t4.(STA+LDA+ADD+OR+AND) + t3.(JN.N' + JZ.Z')
  assign incrementaPC = t1 | (t4 & op_mem_all) | (t3 & op_nao_des);

  // carga RI = t2
  assign cargaRI      = t2;

  // sel = t5.(STA+LDA+ADD+OR+AND)
  assign sel          = t5 & op_mem_all;

  // carga RDM = t6.STA
  assign cargaRDM     = t6 & sta;

  // Read = t1 + t4.(STA+LDA+ADD+OR+AND+JMP+JN.N+JZ.Z) + t6.(LDA+ADD+OR+AND)
  assign read         = t1 | (t4 & (op_mem_all | op_desvio)) | (t6 & op_mem_ac);

  // Write = t7.STA
  assign write        = t7 & sta;

  // Sinais de operação para o Codificador da ULA
  // UAL(Y)   = t7.LDA
  // UAL(ADD) = t7.ADD
  // UAL(OR)  = t7.OR
  // UAL(AND) = t7.AND
  // UAL(NOT) = t3.NOT
  assign ula_y        = t7 & lda;
  assign ula_add      = t7 & add;
  assign ula_or       = t7 & or_op;
  assign ula_and      = t7 & and_op;
  assign ula_not      = t3 & not_op;

  // carga AC = t7.(LDA+ADD+OR+AND) + t3.NOT
  assign cargaAC      = (t7 & op_mem_ac) | (t3 & not_op);

  // carga NZ = t7.(LDA+ADD+OR+AND) + t3.NOT = carga AC
  assign cargaNZ      = cargaAC;

  // carga PC = t5.(JMP+JN.N+JZ.Z)
  assign cargaPC      = t5 & op_desvio;

  // goto t0 = t7.(STA+LDA+ADD+OR+AND) + t3.(NOP+NOT+JN.N'+JZ.Z') + t5.(JMP+JN.N+JZ.Z)
  assign goto_t0      = (t7 & op_mem_all) | (t3 & (nop | not_op | op_nao_des)) | (t5 & op_desvio);

endmodule
