`timescale 1 ns / 10 ps  // indica que 1un de tempo = 1ns
// 1- Módulo Vazio
module tb_3;

  // 3- fios de conexçao com o DUT
  reg [7:0] sa, sb;
  wire [8:0] ss;

  // 2- Instância do DUT
  soma DUT (
      .a(),
      .b(),
      .s()
  );

  // 4 - criando estímulos de entrada e saída
  // Initial é onde definimos testes (somente em testbenches)
  initial begin

    sa <= 8'b1001_0011;
    sb <= 8'b0001_0110;

    // anotação de passagem de tempo
    #10  // espere dez unidades de tempo
    $display(
        "%d+%d: %d", sa, sb, ss
    );

    sa <= 8'b0000_0000;
    sb <= 8'b1111_1111;
    $display("%d+%d: %d", sa, sb, ss);

  end

endmodule
