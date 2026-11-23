`timescale 1ns / 1ps

// Testbench autoverificavel (Verilog-2001) para o modulo ula (ULA 8 bits do Neander)
module tb_ula;

  reg  [7:0] x;
  reg  [7:0] y;
  reg  [2:0] sel;
  wire [7:0] s;
  wire       n;
  wire       z;

  integer    total_tests;
  integer    pass_count;
  integer    fail_count;
  integer    directed_count;
  integer    walking_count;
  integer    sweep_count;
  integer    random_count;
  integer    op_pass [0:7];

  integer    i;
  integer    j;
  integer    k;
  integer    seed;
  reg [31:0] rand_word;
  reg  [7:0] patterns [0:15];
  reg  [7:0] wx;
  reg  [7:0] wy;

  ula dut (
      .x  (x),
      .y  (y),
      .sel(sel),
      .s  (s),
      .n  (n),
      .z  (z)
  );

  // Modelo de referencia dourado (golden reference)
  function [7:0] golden_s;
    input [7:0] fx;
    input [7:0] fy;
    input [2:0] fsel;
    begin
      case (fsel)
        3'b000:  golden_s = fy;
        3'b001:  golden_s = fx + fy;
        3'b010:  golden_s = fx & fy;
        3'b011:  golden_s = fx | fy;
        3'b100:  golden_s = ~fx;
        default: golden_s = 8'h00;
      endcase
    end
  endfunction

  function golden_n;
    input [7:0] fs;
    begin
      golden_n = fs[7];
    end
  endfunction

  function golden_z;
    input [7:0] fs;
    begin
      golden_z = (fs == 8'h00) ? 1'b1 : 1'b0;
    end
  endfunction

  // Verificacao direcionada com valores esperados explicitos e checagem contra referencia
  task check_exact;
    input [7:0]      tx;
    input [7:0]      ty;
    input [2:0]      tsel;
    input [7:0]      exp_s;
    input            exp_n;
    input            exp_z;
    input [8*48-1:0] label;
    reg   [7:0]      ref_s;
    reg              ref_n;
    reg              ref_z;
    begin
      ref_s = golden_s(tx, ty, tsel);
      ref_n = golden_n(ref_s);
      ref_z = golden_z(ref_s);

      if (exp_s !== ref_s || exp_n !== ref_n || exp_z !== ref_z) begin
        $display("[TB BUG] %0s | expectativa explicita diverge do modelo dourado!", label);
        $fatal(1, "Internal testbench expectation mismatch");
      end

      x   = tx;
      y   = ty;
      sel = tsel;
      #1;

      total_tests = total_tests + 1;
      if (s !== exp_s || n !== exp_n || z !== exp_z) begin
        fail_count = fail_count + 1;
        $display("[FAIL] %0s | sel=%b x=0x%02h y=0x%02h | got s=0x%02h n=%b z=%b | exp s=0x%02h n=%b z=%b",
                 label, sel, x, y, s, n, z, exp_s, exp_n, exp_z);
        $fatal(1, "ULA mismatch in directed test");
      end else begin
        pass_count     = pass_count + 1;
        directed_count = directed_count + 1;
        op_pass[tsel]  = op_pass[tsel] + 1;
        $display("[PASS] %0s | sel=%b x=0x%02h y=0x%02h -> s=0x%02h n=%b z=%b",
                 label, sel, x, y, s, n, z);
      end
    end
  endtask

  // Verificacao contra o modelo dourado para varreduras
  task check_golden;
    input [7:0]      tx;
    input [7:0]      ty;
    input [2:0]      tsel;
    input [8*24-1:0] phase_tag;
    reg   [7:0]      exp_s;
    reg              exp_n;
    reg              exp_z;
    begin
      exp_s = golden_s(tx, ty, tsel);
      exp_n = golden_n(exp_s);
      exp_z = golden_z(exp_s);

      x   = tx;
      y   = ty;
      sel = tsel;
      #1;

      total_tests = total_tests + 1;
      if (s !== exp_s || n !== exp_n || z !== exp_z) begin
        fail_count = fail_count + 1;
        $display("[FAIL] %0s | sel=%b x=0x%02h y=0x%02h | got s=0x%02h n=%b z=%b | exp s=0x%02h n=%b z=%b",
                 phase_tag, sel, x, y, s, n, z, exp_s, exp_n, exp_z);
        $fatal(1, "ULA mismatch against golden reference");
      end else begin
        pass_count    = pass_count + 1;
        op_pass[tsel] = op_pass[tsel] + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("ula.vcd");
    $dumpvars(0, tb_ula);

    x              = 8'h00;
    y              = 8'h00;
    sel            = 3'b000;
    total_tests    = 0;
    pass_count     = 0;
    fail_count     = 0;
    directed_count = 0;
    walking_count  = 0;
    sweep_count    = 0;
    random_count   = 0;
    seed           = 32'h2026_1086;

    for (i = 0; i < 8; i = i + 1) begin
      op_pass[i] = 0;
    end

    // Padroes representativos para varredura exaustiva de cantos
    patterns[0]  = 8'h00;
    patterns[1]  = 8'h01;
    patterns[2]  = 8'h0A;
    patterns[3]  = 8'h0F;
    patterns[4]  = 8'h3C;
    patterns[5]  = 8'h55;
    patterns[6]  = 8'h7E;
    patterns[7]  = 8'h7F;
    patterns[8]  = 8'h80;
    patterns[9]  = 8'h81;
    patterns[10] = 8'hAA;
    patterns[11] = 8'hF0;
    patterns[12] = 8'hF5;
    patterns[13] = 8'hF6;
    patterns[14] = 8'hFE;
    patterns[15] = 8'hFF;

    $display("========================================================================");
    $display("Iniciando Testbench da ULA (tb_ula)");
    $display("========================================================================");

    // ------------------------------------------------------------------------
    // 1. Testes direcionados: UAL(Y) - sel = 3'b000 (ignora x)
    // ------------------------------------------------------------------------
    $display("-- [Fase 1a] UAL(Y) sel=3'b000 --");
    check_exact(8'h00, 8'h00, 3'b000, 8'h00, 1'b0, 1'b1, "Y: y=00, x=00 (z=1)");
    check_exact(8'hFF, 8'h00, 3'b000, 8'h00, 1'b0, 1'b1, "Y: y=00, ignora x=FF (z=1)");
    check_exact(8'h80, 8'h00, 3'b000, 8'h00, 1'b0, 1'b1, "Y: y=00, ignora x=80 (z=1)");
    check_exact(8'h00, 8'h80, 3'b000, 8'h80, 1'b1, 1'b0, "Y: y=80, ignora x=00 (n=1)");
    check_exact(8'h7F, 8'h80, 3'b000, 8'h80, 1'b1, 1'b0, "Y: y=80, ignora x=7F (n=1)");
    check_exact(8'hFF, 8'h7F, 3'b000, 8'h7F, 1'b0, 1'b0, "Y: y=7F, ignora x=FF (n=0,z=0)");
    check_exact(8'h00, 8'hFF, 3'b000, 8'hFF, 1'b1, 1'b0, "Y: y=FF, ignora x=00 (n=1)");
    check_exact(8'h55, 8'hFF, 3'b000, 8'hFF, 1'b1, 1'b0, "Y: y=FF, ignora x=55 (n=1)");
    check_exact(8'hAA, 8'h01, 3'b000, 8'h01, 1'b0, 1'b0, "Y: y=01, ignora x=AA (n=0,z=0)");

    // ------------------------------------------------------------------------
    // 2. Testes direcionados: UAL(ADD) - sel = 3'b001
    // ------------------------------------------------------------------------
    $display("-- [Fase 1b] UAL(ADD) sel=3'b001 --");
    check_exact(8'h00, 8'h00, 3'b001, 8'h00, 1'b0, 1'b1, "ADD: 00 + 00 = 00 (z=1)");
    check_exact(8'h7F, 8'h01, 3'b001, 8'h80, 1'b1, 1'b0, "ADD: 7F + 01 = 80 (signed ovf n=1)");
    check_exact(8'hFF, 8'h01, 3'b001, 8'h00, 1'b0, 1'b1, "ADD: FF + 01 = 00 (8-bit wrap z=1)");
    check_exact(8'hFF, 8'hFF, 3'b001, 8'hFE, 1'b1, 1'b0, "ADD: FF + FF = FE (n=1,z=0)");
    check_exact(8'hF6, 8'h0A, 3'b001, 8'h00, 1'b0, 1'b1, "ADD: F6 + 0A = 00 (prog.mif 2s comp)");
    check_exact(8'h0A, 8'hF6, 3'b001, 8'h00, 1'b0, 1'b1, "ADD: 0A + F6 = 00 (comutativo z=1)");
    check_exact(8'hF6, 8'h0B, 3'b001, 8'h01, 1'b0, 1'b0, "ADD: F6 + 0B = 01 (prog.mif neq)");
    check_exact(8'h80, 8'h80, 3'b001, 8'h00, 1'b0, 1'b1, "ADD: 80 + 80 = 00 (wrap z=1)");
    check_exact(8'h80, 8'h7F, 3'b001, 8'hFF, 1'b1, 1'b0, "ADD: 80 + 7F = FF (n=1)");
    check_exact(8'h55, 8'hAA, 3'b001, 8'hFF, 1'b1, 1'b0, "ADD: 55 + AA = FF (n=1)");
    check_exact(8'h01, 8'h02, 3'b001, 8'h03, 1'b0, 1'b0, "ADD: 01 + 02 = 03 (n=0,z=0)");
    check_exact(8'h00, 8'h80, 3'b001, 8'h80, 1'b1, 1'b0, "ADD: 00 + 80 = 80 (n=1)");

    // ------------------------------------------------------------------------
    // 3. Testes direcionados: UAL(AND) - sel = 3'b010
    // ------------------------------------------------------------------------
    $display("-- [Fase 1c] UAL(AND) sel=3'b010 --");
    check_exact(8'h00, 8'h00, 3'b010, 8'h00, 1'b0, 1'b1, "AND: 00 & 00 = 00 (zeros z=1)");
    check_exact(8'hFF, 8'h00, 3'b010, 8'h00, 1'b0, 1'b1, "AND: FF & 00 = 00 (z=1)");
    check_exact(8'h00, 8'hFF, 3'b010, 8'h00, 1'b0, 1'b1, "AND: 00 & FF = 00 (z=1)");
    check_exact(8'hFF, 8'hFF, 3'b010, 8'hFF, 1'b1, 1'b0, "AND: FF & FF = FF (all ones n=1)");
    check_exact(8'hAA, 8'h55, 3'b010, 8'h00, 1'b0, 1'b1, "AND: AA & 55 = 00 (alt masks z=1)");
    check_exact(8'h55, 8'hAA, 3'b010, 8'h00, 1'b0, 1'b1, "AND: 55 & AA = 00 (alt masks rev)");
    check_exact(8'hAA, 8'hAA, 3'b010, 8'hAA, 1'b1, 1'b0, "AND: AA & AA = AA (n=1)");
    check_exact(8'h55, 8'h55, 3'b010, 8'h55, 1'b0, 1'b0, "AND: 55 & 55 = 55 (n=0,z=0)");
    check_exact(8'hAA, 8'h0F, 3'b010, 8'h0A, 1'b0, 1'b0, "AND: AA & 0F = 0A (low nibble)");
    check_exact(8'hAA, 8'hF0, 3'b010, 8'hA0, 1'b1, 1'b0, "AND: AA & F0 = A0 (high nibble n=1)");
    check_exact(8'h80, 8'h80, 3'b010, 8'h80, 1'b1, 1'b0, "AND: 80 & 80 = 80 (MSB n=1)");
    check_exact(8'h80, 8'h7F, 3'b010, 8'h00, 1'b0, 1'b1, "AND: 80 & 7F = 00 (MSB off z=1)");
    check_exact(8'hFF, 8'h7F, 3'b010, 8'h7F, 1'b0, 1'b0, "AND: FF & 7F = 7F (MSB off n=0)");

    // ------------------------------------------------------------------------
    // 4. Testes direcionados: UAL(OR) - sel = 3'b011
    // ------------------------------------------------------------------------
    $display("-- [Fase 1d] UAL(OR) sel=3'b011 --");
    check_exact(8'h00, 8'h00, 3'b011, 8'h00, 1'b0, 1'b1, "OR : 00 | 00 = 00 (zeros z=1)");
    check_exact(8'hFF, 8'hFF, 3'b011, 8'hFF, 1'b1, 1'b0, "OR : FF | FF = FF (all ones n=1)");
    check_exact(8'hFF, 8'h00, 3'b011, 8'hFF, 1'b1, 1'b0, "OR : FF | 00 = FF (n=1)");
    check_exact(8'h00, 8'hFF, 3'b011, 8'hFF, 1'b1, 1'b0, "OR : 00 | FF = FF (n=1)");
    check_exact(8'hAA, 8'h55, 3'b011, 8'hFF, 1'b1, 1'b0, "OR : AA | 55 = FF (alt masks n=1)");
    check_exact(8'h55, 8'hAA, 3'b011, 8'hFF, 1'b1, 1'b0, "OR : 55 | AA = FF (alt masks rev)");
    check_exact(8'hAA, 8'h00, 3'b011, 8'hAA, 1'b1, 1'b0, "OR : AA | 00 = AA (MSB n=1)");
    check_exact(8'h55, 8'h00, 3'b011, 8'h55, 1'b0, 1'b0, "OR : 55 | 00 = 55 (MSB n=0)");
    check_exact(8'h80, 8'h00, 3'b011, 8'h80, 1'b1, 1'b0, "OR : 80 | 00 = 80 (MSB n=1)");
    check_exact(8'h00, 8'h80, 3'b011, 8'h80, 1'b1, 1'b0, "OR : 00 | 80 = 80 (MSB n=1)");
    check_exact(8'h7F, 8'h01, 3'b011, 8'h7F, 1'b0, 1'b0, "OR : 7F | 01 = 7F (MSB n=0)");
    check_exact(8'h7F, 8'h80, 3'b011, 8'hFF, 1'b1, 1'b0, "OR : 7F | 80 = FF (MSB n=1)");

    // ------------------------------------------------------------------------
    // 5. Testes direcionados: UAL(NOT) - sel = 3'b100 (ignora y)
    // ------------------------------------------------------------------------
    $display("-- [Fase 1e] UAL(NOT) sel=3'b100 --");
    check_exact(8'h00, 8'h00, 3'b100, 8'hFF, 1'b1, 1'b0, "NOT: ~00 = FF (y=00, n=1)");
    check_exact(8'h00, 8'hFF, 3'b100, 8'hFF, 1'b1, 1'b0, "NOT: ~00 = FF (ignora y=FF)");
    check_exact(8'hFF, 8'h00, 3'b100, 8'h00, 1'b0, 1'b1, "NOT: ~FF = 00 (y=00, z=1)");
    check_exact(8'hFF, 8'hFF, 3'b100, 8'h00, 1'b0, 1'b1, "NOT: ~FF = 00 (ignora y=FF)");
    check_exact(8'h80, 8'hAA, 3'b100, 8'h7F, 1'b0, 1'b0, "NOT: ~80 = 7F (ignora y=AA)");
    check_exact(8'h7F, 8'h55, 3'b100, 8'h80, 1'b1, 1'b0, "NOT: ~7F = 80 (ignora y=55)");
    check_exact(8'hAA, 8'hFF, 3'b100, 8'h55, 1'b0, 1'b0, "NOT: ~AA = 55 (ignora y=FF)");
    check_exact(8'h55, 8'h00, 3'b100, 8'hAA, 1'b1, 1'b0, "NOT: ~55 = AA (ignora y=00)");
    check_exact(8'h0A, 8'h01, 3'b100, 8'hF5, 1'b1, 1'b0, "NOT: ~0A = F5 (prog.mif step)");

    // ------------------------------------------------------------------------
    // 6. Testes direcionados: seletores invalidos 3'b101, 3'b110, 3'b111
    // ------------------------------------------------------------------------
    $display("-- [Fase 1f] Seletores invalidos 3'b101, 3'b110, 3'b111 --");
    for (i = 5; i <= 7; i = i + 1) begin
      check_exact(8'h00, 8'h00, i[2:0], 8'h00, 1'b0, 1'b1, "INV: sel invalido x=00 y=00");
      check_exact(8'hFF, 8'hFF, i[2:0], 8'h00, 1'b0, 1'b1, "INV: sel invalido x=FF y=FF");
      check_exact(8'hAA, 8'h55, i[2:0], 8'h00, 1'b0, 1'b1, "INV: sel invalido x=AA y=55");
      check_exact(8'h80, 8'h01, i[2:0], 8'h00, 1'b0, 1'b1, "INV: sel invalido x=80 y=01");
      check_exact(8'h7F, 8'h80, i[2:0], 8'h00, 1'b0, 1'b1, "INV: sel invalido x=7F y=80");
    end

    // ------------------------------------------------------------------------
    // 7. Varredura de sensibilidade apenas de sel (x e y constantes)
    // ------------------------------------------------------------------------
    $display("-- [Fase 1g] Transicoes de sel com x,y estaticos (0..7 e 7..0) --");
    for (k = 0; k < 8; k = k + 1) begin
      check_golden(8'hF6, 8'h0A, k[2:0], "SEL_SWEEP_UP");
      directed_count = directed_count + 1;
    end
    for (k = 7; k >= 0; k = k - 1) begin
      check_golden(8'hAA, 8'h55, k[2:0], "SEL_SWEEP_DOWN");
      directed_count = directed_count + 1;
    end

    // ------------------------------------------------------------------------
    // 8. Varredura walking-1 / propagacao de bits por todas as operacoes 0..7
    // ------------------------------------------------------------------------
    $display("-- [Fase 2] Varredura walking-1 e complemento por sel=0..7 --");
    for (k = 0; k < 8; k = k + 1) begin
      for (i = 0; i < 8; i = i + 1) begin
        wx = (8'h01 << i);
        for (j = 0; j < 8; j = j + 1) begin
          wy = (8'h01 << j);
          check_golden(wx, wy, k[2:0], "WALKING_1");
          walking_count = walking_count + 1;
        end
        // Propagacao de carry em cascata (ex: 8'hFF + (1<<i))
        check_golden(8'hFF, wx, k[2:0], "CARRY_RIPPLE");
        walking_count = walking_count + 1;
      end
    end

    // ------------------------------------------------------------------------
    // 9. Varredura exaustiva da matriz de padroes de canto (8 x 16 x 16 = 2048)
    // ------------------------------------------------------------------------
    $display("-- [Fase 3] Matriz de padroes representativos (8 x 16 x 16 = 2048) --");
    for (k = 0; k < 8; k = k + 1) begin
      for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
          check_golden(patterns[i], patterns[j], k[2:0], "PATTERN_MATRIX");
          sweep_count = sweep_count + 1;
        end
      end
    end

    // ------------------------------------------------------------------------
    // 10. Varredura pseudo-aleatoria deterministica (8 x 256 = 2048 vetores)
    // ------------------------------------------------------------------------
    $display("-- [Fase 4] Varredura pseudo-aleatoria deterministica (2048 vetores) --");
    for (k = 0; k < 8; k = k + 1) begin
      for (i = 0; i < 256; i = i + 1) begin
        rand_word = $random(seed);
        check_golden(rand_word[7:0], rand_word[15:8], k[2:0], "RANDOM_SWEEP");
        random_count = random_count + 1;
      end
    end

    // ------------------------------------------------------------------------
    // Resumo final
    // ------------------------------------------------------------------------
    $display("========================================================================");
    $display("RESUMO DA SIMULACAO - tb_ula");
    $display("------------------------------------------------------------------------");
    $display("  Testes direcionados (edge cases) : %0d", directed_count);
    $display("  Testes walking-1 / carry ripple  : %0d", walking_count);
    $display("  Matriz de padroes representativos: %0d", sweep_count);
    $display("  Varredura aleatoria              : %0d", random_count);
    $display("------------------------------------------------------------------------");
    $display("  Cobertura por sel:");
    $display("    sel=3'b000 (Y)      : %0d passed", op_pass[0]);
    $display("    sel=3'b001 (ADD)    : %0d passed", op_pass[1]);
    $display("    sel=3'b010 (AND)    : %0d passed", op_pass[2]);
    $display("    sel=3'b011 (OR)     : %0d passed", op_pass[3]);
    $display("    sel=3'b100 (NOT)    : %0d passed", op_pass[4]);
    $display("    sel=3'b101 (INV)    : %0d passed", op_pass[5]);
    $display("    sel=3'b110 (INV)    : %0d passed", op_pass[6]);
    $display("    sel=3'b111 (INV)    : %0d passed", op_pass[7]);
    $display("------------------------------------------------------------------------");
    $display("  TOTAL: %0d | PASS: %0d | FAIL: %0d", total_tests, pass_count, fail_count);
    $display("========================================================================");

    if (fail_count != 0 || pass_count != total_tests) begin
      $fatal(1, "Testbench finalizado com falhas!");
    end

    $display("TODOS OS TESTES PASSARAM COM SUCESSO!");
    $finish;
  end

endmodule
