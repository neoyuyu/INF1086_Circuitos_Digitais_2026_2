// Gabriel Tafarel
// Sayid Safa
//   sel = 00: carga paralela   (Qt <- D)
//   sel = 01: armazenamento    (Qt <- Qt-1)
//   sel = 10: incremento       (Qt <- Qt-1 + 1)
//   sel = 11: decremento       (Qt <- Qt-1 - 1)
module contador(
    input  [7:0] d,          // dado para carga paralela
    input  [1:0] sel,        // selecao da operacao
    input        clk,        
    input        rstn,       // reset assincrono, ativo em 0
    output [7:0] q
);

    wire sel_carga  = ~sel[1] & ~sel[0];   // 00
    wire sel_mantem = ~sel[1] &  sel[0];   // 01
    wire sel_inc    =  sel[1] & ~sel[0];   // 10
    wire sel_dec    =  sel[1] &  sel[0];   // 11

    // ---- Cadeias de toggle ----
    // sobe[i]  = 1 quando todos os bits abaixo de i sao 1 (vai-um)
    // desce[i] = 1 quando todos os bits abaixo de i sao 0 (pede emprestado)
	 
    wire [7:0] sobe;
    wire [7:0] desce;
    assign sobe[0]  = 1'b1;    // o bit 0 sempre inverte
    assign desce[0] = 1'b1;

    // ---- Valor que cada ff_d vai receber ----
    wire [7:0] proximo_carga;
    wire [7:0] proximo_mantem;
    wire [7:0] proximo_inc;
    wire [7:0] proximo_dec;
    wire [7:0] proximo;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bit_contador

            // cadeias: cada bit olha o bit anterior e a cadeia anterior
            if (i > 0) begin : cadeia
                assign sobe[i]  = sobe[i - 1]  &  q[i - 1];
                assign desce[i] = desce[i - 1] & ~q[i - 1];
            end

            // as quatro opcoes de valor para o bit i
            assign proximo_carga[i]  = d[i];
            assign proximo_mantem[i] = q[i];
            assign proximo_inc[i]    = q[i] ^ sobe[i];
            assign proximo_dec[i]    = q[i] ^ desce[i];

            // MUX 4:1 em AND-OR: so a opcao escolhida passa
            assign proximo[i] = (sel_carga  & proximo_carga[i])
                              | (sel_mantem & proximo_mantem[i])
                              | (sel_inc    & proximo_inc[i])
                              | (sel_dec    & proximo_dec[i]);

            ff_d FF(
                .d(proximo[i]),
                .clk(clk),
                .rstn(rstn),
                .q(q[i]),
                .qn()
            );
        end
    endgenerate

endmodule