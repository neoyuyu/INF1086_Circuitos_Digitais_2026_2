`timescale 1ns / 1ps

module tb_unidade_controle;

  reg        clk;
  reg        rst;
  reg  [3:0] opcode;
  reg        n;
  reg        z;

  wire       cargaREM;
  wire       incrementaPC;
  wire       cargaRI;
  wire       sel;
  wire       cargaRDM;
  wire       read;
  wire       write;
  wire       ula_y;
  wire       ula_add;
  wire       ula_or;
  wire       ula_and;
  wire       ula_not;
  wire       cargaAC;
  wire       cargaNZ;
  wire       cargaPC;
  wire       goto_t0;
  wire       hlt;
  wire       illegal_op;
  wire [7:0] t;

  unidade_controle dut (
      .clk         (clk),
      .rst         (rst),
      .opcode      (opcode),
      .n           (n),
      .z           (z),
      .cargaREM    (cargaREM),
      .incrementaPC(incrementaPC),
      .cargaRI     (cargaRI),
      .sel         (sel),
      .cargaRDM    (cargaRDM),
      .read        (read),
      .write       (write),
      .ula_y       (ula_y),
      .ula_add     (ula_add),
      .ula_or      (ula_or),
      .ula_and     (ula_and),
      .ula_not     (ula_not),
      .cargaAC     (cargaAC),
      .cargaNZ     (cargaNZ),
      .cargaPC     (cargaPC),
      .goto_t0     (goto_t0),
      .hlt         (hlt),
      .illegal_op  (illegal_op),
      .t           (t)
  );

  // Clock de 10ns (período)
  always #5 clk = ~clk;

  // Retorna o índice do tempo ativo (t0..t7)
  function [2:0] t_idx;
    input [7:0] t_bus;
    begin
      case (t_bus)
        8'b0000_0001: t_idx = 3'd0;
        8'b0000_0010: t_idx = 3'd1;
        8'b0000_0100: t_idx = 3'd2;
        8'b0000_1000: t_idx = 3'd3;
        8'b0001_0000: t_idx = 3'd4;
        8'b0010_0000: t_idx = 3'd5;
        8'b0100_0000: t_idx = 3'd6;
        8'b1000_0000: t_idx = 3'd7;
        default:      t_idx = 3'd0;
      endcase
    end
  endfunction

  task print_cycle;
    input [63:0] nome_inst;
    begin
      #1;
      $write("[%s | opcode=%b N=%b Z=%b] t%0d -> ", nome_inst, opcode, n, z, t_idx(t));
      if (cargaREM)     $write("sel=%0d cargaREM | ", sel);
      if (read)         $write("Read | ");
      if (write)        $write("Write | ");
      if (incrementaPC) $write("incrementaPC | ");
      if (cargaPC)      $write("cargaPC | ");
      if (cargaRI)      $write("cargaRI | ");
      if (cargaRDM)     $write("cargaRDM | ");
      if (ula_y)        $write("UAL(Y) | ");
      if (ula_add)      $write("UAL(ADD) | ");
      if (ula_or)       $write("UAL(OR) | ");
      if (ula_and)      $write("UAL(AND) | ");
      if (ula_not)      $write("UAL(NOT) | ");
      if (cargaAC)      $write("cargaAC | ");
      if (cargaNZ)      $write("cargaNZ | ");
      if (goto_t0)      $write("goto_t0 | ");
      if (hlt && t[3])  $write("HALT (congelado)");
      $write("\n");
    end
  endtask

  task run_instruction;
    input [63:0] nome_inst;
    input [3:0]  op;
    input        flag_n;
    input        flag_z;
    input integer cycles;
    integer i;
    begin
      $display("----------------------------------------------------------------------");
      opcode = op;
      n      = flag_n;
      z      = flag_z;
      for (i = 0; i < cycles; i = i + 1) begin
        print_cycle(nome_inst);
        @(posedge clk);
      end
    end
  endtask

  initial begin
    $dumpfile("unidade_controle.vcd");
    $dumpvars(0, tb_unidade_controle);

    clk    = 0;
    rst    = 1;
    opcode = 4'b0000;
    n      = 0;
    z      = 0;

    #2;
    rst = 0;

    // Testa todas as instruções conforme slides 15 e 16 do PDF
    run_instruction("NOP     ", 4'b0000, 0, 0, 4);
    run_instruction("STA     ", 4'b0001, 0, 0, 8);
    run_instruction("LDA     ", 4'b0010, 0, 0, 8);
    run_instruction("ADD     ", 4'b0011, 0, 0, 8);
    run_instruction("OR      ", 4'b0100, 0, 0, 8);
    run_instruction("AND     ", 4'b0101, 0, 0, 8);
    run_instruction("NOT     ", 4'b0110, 0, 0, 4);
    run_instruction("JMP     ", 4'b1000, 0, 0, 6);
    run_instruction("JN (N=1)", 4'b1001, 1, 0, 6);
    run_instruction("JN (N=0)", 4'b1001, 0, 0, 4);
    run_instruction("JZ (Z=1)", 4'b1010, 0, 1, 6);
    run_instruction("JZ (Z=0)", 4'b1010, 0, 0, 4);
    run_instruction("HLT     ", 4'b1111, 0, 0, 6); // Mostra que trava em t3

    $display("----------------------------------------------------------------------");
    $finish;
  end

endmodule
