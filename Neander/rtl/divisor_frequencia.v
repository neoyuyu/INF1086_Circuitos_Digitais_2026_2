// Gabriel Tafarel
// Sayid Safa
// Divisor de frequencia 50 MHz ate 3Hz
module divisor_frequencia(
    input  clk,   // 50 MHz
    input  rstn,   // reset assincrono, ativo em 0
    output Q      
);

    wire [24:0] clk_est;
    assign clk_est[0] = clk;

    genvar i;
    generate
        for (i = 0; i < 24; i = i + 1) begin : estagio
            wire q, qn;
				
				//Flip flop d para para divisao
            ff_d FF(
                .d(qn),                 // aqui eh feita divisao por 2
                .clk(clk_est[i]),
                .rstn(rstn),
                .q(q),
                .qn(qn)
            );

            assign clk_est[i + 1] = q;
        end
    endgenerate

    assign Q = clk_est[24]; //Ultimo fio com resultado 

endmodule