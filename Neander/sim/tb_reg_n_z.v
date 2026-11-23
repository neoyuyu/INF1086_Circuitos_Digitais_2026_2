`timescale 1ns / 1ps

module tb_reg_n_z;

  localparam integer CLK_HALF = 20;

  reg  clk;
  reg  rstn;
  reg  cargaNZ;
  reg  n;
  reg  z;

  wire n_out;
  wire z_out;

  integer pass_count;
  integer fail_count;
  integer cyc;
  integer pat;

  reg [1:0] prev_nz;
  reg [1:0] seq [0:8];

  reg_n_z dut (
      .clk    (clk),
      .rstn   (rstn),
      .cargaNZ(cargaNZ),
      .n      (n),
      .z      (z),
      .n_out  (n_out),
      .z_out  (z_out)
  );

  // Clock de periodo 40 ns (20 ns em 0, 20 ns em 1)
  initial clk = 1'b0;
  always #(CLK_HALF) clk = ~clk;

  // Verifica saidas contra valores esperados usando !== (detecta X/Z)
  task check_nz;
    input exp_n;
    input exp_z;
    input [8*80-1:0] label;
    begin
      if (n_out !== exp_n || z_out !== exp_z) begin
        fail_count = fail_count + 1;
        $display("[FAIL] t=%0t | %0s | esperado=(%b,%b) obtido=(%b,%b) [clk=%b rstn=%b cargaNZ=%b n=%b z=%b]",
                 $time, label, exp_n, exp_z, n_out, z_out, clk, rstn, cargaNZ, n, z);
        $fatal(1, "Falha na verificacao: %0s", label);
      end else begin
        pass_count = pass_count + 1;
      end
    end
  endtask

  // Garante que o clock esteja no nivel esperado no momento do teste
  task check_clk_level;
    input exp_clk;
    input [8*80-1:0] label;
    begin
      if (clk !== exp_clk) begin
        fail_count = fail_count + 1;
        $display("[FAIL] t=%0t | %0s | fase de clock inesperada: esperado clk=%b, obtido clk=%b",
                 $time, label, exp_clk, clk);
        $fatal(1, "Erro de temporizacao no testbench em %0s", label);
      end
    end
  endtask

  // Carrega um par (n, z) de forma sincrona durante clk == 0 e valida antes/apos bordas
  task load_and_verify;
    input next_n;
    input next_z;
    input exp_prev_n;
    input exp_prev_z;
    input [8*80-1:0] label;
    begin
      if (clk !== 1'b0) @(negedge clk);
      #2;
      cargaNZ = 1'b1;
      n       = next_n;
      z       = next_z;
      #2;
      check_clk_level(1'b0, label);
      // Latch escravo deve reter o valor anterior enquanto clk == 0
      check_nz(exp_prev_n, exp_prev_z, {label, " (pre-posedge clk=0)"});

      // Borda de subida captura o novo valor
      @(posedge clk);
      #2;
      check_clk_level(1'b1, label);
      check_nz(next_n, next_z, {label, " (pos-posedge clk=1)"});

      // Borda de descida nao pode corromper a saida armazenada
      @(negedge clk);
      #2;
      check_clk_level(1'b0, label);
      check_nz(next_n, next_z, {label, " (pos-negedge clk=0)"});
    end
  endtask

  initial begin
    $dumpfile("reg_n_z.vcd");
    $dumpvars(0, tb_reg_n_z);

    pass_count = 0;
    fail_count = 0;

    // Sequencia cobrindo 00, 01, 10, 11 e todas as transicoes 0->0, 0->1, 1->0, 1->1
    seq[0] = 2'b01;
    seq[1] = 2'b10;
    seq[2] = 2'b11;
    seq[3] = 2'b00;
    seq[4] = 2'b11;
    seq[5] = 2'b01;
    seq[6] = 2'b00;
    seq[7] = 2'b10;
    seq[8] = 2'b11;

    $display("======================================================================");
    $display("Iniciando testbench de reg_n_z (ff_d_carga mestre-escravo)");
    $display("======================================================================");

    // ------------------------------------------------------------------
    // TESTE 1: Reset assincrono inicial (rstn = 0) com clk=0 e clk=1
    // ------------------------------------------------------------------
    $display("[TESTE 1] Reset assincrono inicial com clk=0 e clk=1");
    rstn    = 1'b0;
    cargaNZ = 1'b0;
    n       = 1'b0;
    z       = 1'b0;
    #1;
    check_clk_level(1'b0, "T1.1");
    check_nz(1'b0, 1'b0, "T1.1 reset inicial clk=0, entradas=000");

    // Varre todas combinacoes de (cargaNZ, n, z) com clk=0 e rstn=0 (sem borda)
    for (pat = 0; pat < 8; pat = pat + 1) begin
      {cargaNZ, n, z} = pat[2:0];
      #1;
      check_clk_level(1'b0, "T1.2");
      check_nz(1'b0, 1'b0, "T1.2 reset ativo clk=0 varredura cargaNZ/n/z");
    end

    // Agora na fase clk=1 mantendo rstn=0 e varrendo entradas
    @(posedge clk);
    #1;
    check_clk_level(1'b1, "T1.3");
    check_nz(1'b0, 1'b0, "T1.3 reset ativo atraves de posedge clk");
    for (pat = 0; pat < 8; pat = pat + 1) begin
      {cargaNZ, n, z} = pat[2:0];
      #1;
      check_clk_level(1'b1, "T1.4");
      check_nz(1'b0, 1'b0, "T1.4 reset ativo clk=1 varredura cargaNZ/n/z");
    end

    // Verifica liberacao de rstn durante clk == 1 com cargaNZ=1, n=1, z=1:
    // Como latch mestre (qm) foi zerado e clk==1 bloqueia qm, saida deve
    // permanecer 00 ate o proximo ciclo (negedge clk + posedge clk).
    @(posedge clk);
    #2;
    cargaNZ = 1'b1;
    n       = 1'b1;
    z       = 1'b1;
    #1;
    check_clk_level(1'b1, "T1.5");
    rstn = 1'b1;
    #2;
    check_clk_level(1'b1, "T1.5 pos-liberacao");
    check_nz(1'b0, 1'b0, "T1.5 rstn sobe durante clk=1 (qm isolado em 0)");
    @(negedge clk);
    #2;
    check_clk_level(1'b0, "T1.6");
    check_nz(1'b0, 1'b0, "T1.6 apos negedge clk com rstn=1 (escravo retem 00)");
    @(posedge clk);
    #2;
    check_clk_level(1'b1, "T1.7");
    check_nz(1'b1, 1'b1, "T1.7 proximo posedge clk captura 11 apos ciclo baixo");

    // Restaura reset para iniciar Teste 2 a partir de 00 limpo
    @(negedge clk);
    #2;
    rstn    = 1'b0;
    cargaNZ = 1'b0;
    n       = 1'b0;
    z       = 1'b0;
    #1;
    check_clk_level(1'b0, "T1.8");
    check_nz(1'b0, 1'b0, "T1.8 reset sincronizando estado inicial em 00");
    #2;
    rstn = 1'b1;
    #1;
    check_clk_level(1'b0, "T1.9");
    check_nz(1'b0, 1'b0, "T1.9 pos-liberacao de reset em clk=0");

    // ------------------------------------------------------------------
    // TESTE 2: Carga sincrona (cargaNZ = 1) - 00, 01, 10, 11 e transicoes
    // ------------------------------------------------------------------
    $display("[TESTE 2] Carga sincrona (cargaNZ = 1) das 4 combinacoes e transicoes");
    prev_nz = 2'b00;
    for (pat = 0; pat <= 8; pat = pat + 1) begin
      load_and_verify(seq[pat][1], seq[pat][0], prev_nz[1], prev_nz[0], "T2 cargaNZ=1");
      prev_nz = seq[pat];
    end

    // ------------------------------------------------------------------
    // TESTE 3: Retencao (cargaNZ = 0) com entradas alternando em todas fases
    // ------------------------------------------------------------------
    $display("[TESTE 3] Retencao (cargaNZ = 0) para os 4 estados armazenados");
    for (pat = 0; pat < 4; pat = pat + 1) begin
      // Primeiro carrega o estado alvo
      if (clk !== 1'b0) @(negedge clk);
      #2;
      cargaNZ = 1'b1;
      {n, z}  = pat[1:0];
      @(posedge clk);
      #2;
      check_nz(pat[1], pat[0], "T3 setup estado armazenado");
      @(negedge clk);
      #2;

      // Desabilita cargaNZ e alterna entradas em clk=0, atraves de posedge e em clk=1 por 3 ciclos
      cargaNZ = 1'b0;
      for (cyc = 0; cyc < 3; cyc = cyc + 1) begin
        // Alterna durante clk == 0
        {n, z} = 2'b00;
        #2;
        check_clk_level(1'b0, "T3 clk=0");
        check_nz(pat[1], pat[0], "T3 hold clk=0 entr=00");
        {n, z} = 2'b11;
        #2;
        check_nz(pat[1], pat[0], "T3 hold clk=0 entr=11");
        {n, z} = ~pat[1:0];
        #2;
        check_nz(pat[1], pat[0], "T3 hold clk=0 entr=~estado");

        // Em cyc==1 alterna exatamente em posedge clk; nos demais mantem ~estado atraves da borda
        @(posedge clk);
        if (cyc == 1) begin
          {n, z} = pat[1:0];
        end
        #2;
        check_clk_level(1'b1, "T3 posedge");
        check_nz(pat[1], pat[0], "T3 hold atraves de posedge clk");

        // Alterna durante clk == 1
        {n, z} = 2'b10;
        #2;
        check_nz(pat[1], pat[0], "T3 hold clk=1 entr=10");
        {n, z} = 2'b01;
        #2;
        check_nz(pat[1], pat[0], "T3 hold clk=1 entr=01");
        {n, z} = ~pat[1:0];
        #2;
        check_clk_level(1'b1, "T3 clk=1");
        check_nz(pat[1], pat[0], "T3 hold clk=1 entr=~estado");

        @(negedge clk);
        #2;
        check_clk_level(1'b0, "T3 negedge");
        check_nz(pat[1], pat[0], "T3 hold pos-negedge clk");
      end
    end

    // ------------------------------------------------------------------
    // TESTE 4: Isolamento do latch mestre com clk == 1 e cargaNZ == 1
    // ------------------------------------------------------------------
    $display("[TESTE 4] Isolamento do latch mestre durante clk=1 com cargaNZ=1");

    // 4A: Armazena (1,1); durante clk==1 varia (n,z) -> nao pode vazar para q
    if (clk !== 1'b0) @(negedge clk);
    #2;
    cargaNZ = 1'b1;
    {n, z}  = 2'b11;
    @(posedge clk);
    #1;
    check_clk_level(1'b1, "T4A");
    check_nz(1'b1, 1'b1, "T4A estado inicial (1,1) em clk=1");

    // Altera entradas enquanto clk=1 e cargaNZ=1; saida deve continuar (1,1)
    {n, z} = 2'b00;
    #3;
    check_clk_level(1'b1, "T4A n,z=00");
    check_nz(1'b1, 1'b1, "T4A muda n,z=00 em clk=1 (sem glitch)");
    {n, z} = 2'b01;
    #3;
    check_nz(1'b1, 1'b1, "T4A muda n,z=01 em clk=1 (sem glitch)");
    {n, z} = 2'b10;
    #3;
    check_nz(1'b1, 1'b1, "T4A muda n,z=10 em clk=1 (sem glitch)");
    {n, z} = 2'b00;
    #3;
    check_clk_level(1'b1, "T4A fim clk=1");
    check_nz(1'b1, 1'b1, "T4A fim de clk=1 ainda retem (1,1)");

    // Cruza negedge clk mantendo (n,z)=(0,0) e cargaNZ=1:
    // mestre agora captura (0,0), mas escravo segura (1,1) ate proximo posedge!
    @(negedge clk);
    #2;
    check_clk_level(1'b0, "T4A negedge");
    check_nz(1'b1, 1'b1, "T4A apos negedge clk escravo ainda retem (1,1)");

    // Proximo posedge clk transfere (0,0) do mestre para o escravo
    @(posedge clk);
    #1;
    check_clk_level(1'b1, "T4A posedge");
    check_nz(1'b0, 1'b0, "T4A proximo posedge clk captura (0,0)");

    // 4B: Polaridade oposta: armazenado (0,0); altera para (1,1) em clk=1
    {n, z} = 2'b11;
    #3;
    check_clk_level(1'b1, "T4B n,z=11");
    check_nz(1'b0, 1'b0, "T4B muda n,z=11 em clk=1 (sem glitch)");
    {n, z} = 2'b10;
    #3;
    check_nz(1'b0, 1'b0, "T4B muda n,z=10 em clk=1 (sem glitch)");
    {n, z} = 2'b11;
    #3;
    check_clk_level(1'b1, "T4B fim clk=1");
    check_nz(1'b0, 1'b0, "T4B fim de clk=1 ainda retem (0,0)");

    @(negedge clk);
    #2;
    check_clk_level(1'b0, "T4B negedge");
    check_nz(1'b0, 1'b0, "T4B apos negedge clk escravo ainda retem (0,0)");
    @(posedge clk);
    #1;
    check_clk_level(1'b1, "T4B posedge");
    check_nz(1'b1, 1'b1, "T4B proximo posedge clk captura (1,1)");

    // 4C: Glitch em n,z durante clk=1 restaurado antes de negedge clk
    {n, z} = 2'b00;
    #5;
    check_clk_level(1'b1, "T4C glitch");
    check_nz(1'b1, 1'b1, "T4C glitch n,z=00 durante clk=1 sem efeito");
    {n, z} = 2'b11;
    #5;
    check_clk_level(1'b1, "T4C restaurado");
    check_nz(1'b1, 1'b1, "T4C restaurado n,z=11 antes de negedge clk");
    @(negedge clk);
    #2;
    check_nz(1'b1, 1'b1, "T4C pos-negedge clk mantem (1,1)");
    @(posedge clk);
    #2;
    check_nz(1'b1, 1'b1, "T4C pos-posedge clk mantem (1,1)");

    // 4D: Pulso de cargaNZ=1 apenas durante clk=1 com n,z=(0,0) nao altera q
    @(negedge clk);
    #2;
    cargaNZ = 1'b0;
    {n, z}  = 2'b00;
    @(posedge clk);
    #2;
    check_clk_level(1'b1, "T4D inicio");
    check_nz(1'b1, 1'b1, "T4D antes do pulso de cargaNZ em clk=1");
    cargaNZ = 1'b1;
    #6;
    check_clk_level(1'b1, "T4D pulso");
    check_nz(1'b1, 1'b1, "T4D durante pulso cargaNZ=1 em clk=1");
    cargaNZ = 1'b0;
    #4;
    check_clk_level(1'b1, "T4D fim pulso");
    check_nz(1'b1, 1'b1, "T4D apos pulso cargaNZ=0 antes de negedge");
    @(negedge clk);
    #2;
    check_nz(1'b1, 1'b1, "T4D pos-negedge clk mantem (1,1)");
    @(posedge clk);
    #2;
    check_nz(1'b1, 1'b1, "T4D pos-posedge clk mantem (1,1)");

    // 4E: cargaNZ sobe e volta para 0 antes do posedge clk (durante clk=0)
    @(negedge clk);
    #2;
    cargaNZ = 1'b1;
    {n, z}  = 2'b00;
    #4;
    check_clk_level(1'b0, "T4E");
    check_nz(1'b1, 1'b1, "T4E cargaNZ=1 temporario em clk=0 nao muda saida");
    cargaNZ = 1'b0;
    #4;
    check_clk_level(1'b0, "T4E pos-queda");
    @(posedge clk);
    #2;
    check_nz(1'b1, 1'b1, "T4E cargaNZ voltou para 0 antes de posedge -> retem (1,1)");

    // ------------------------------------------------------------------
    // TESTE 5: Reset assincrono em operacao com (n_out, z_out) = (1, 1)
    // ------------------------------------------------------------------
    $display("[TESTE 5] Reset assincrono em operacao a partir de (1,1) sem borda");

    // 5A: Reset com clk == 1, cargaNZ=1, n=1, z=1
    if (clk !== 1'b1) @(posedge clk);
    #2;
    cargaNZ = 1'b1;
    {n, z}  = 2'b11;
    check_clk_level(1'b1, "T5A antes reset");
    check_nz(1'b1, 1'b1, "T5A confirma (1,1) antes do reset em clk=1");
    rstn = 1'b0;
    #1;
    // Ainda dentro da mesma fase clk=1, antes de qualquer borda!
    check_clk_level(1'b1, "T5A reset imediato");
    check_nz(1'b0, 1'b0, "T5A reset imediato em clk=1 zera (1,1)->(0,0)");
    @(negedge clk);
    #2;
    check_nz(1'b0, 1'b0, "T5A mantem (0,0) em clk=0 com rstn=0");
    @(posedge clk);
    #2;
    check_nz(1'b0, 1'b0, "T5A mantem (0,0) apos posedge com rstn=0");

    // 5B: Recarrega (1,1) e testa reset assincrono durante clk == 0
    @(negedge clk);
    #2;
    rstn    = 1'b1;
    cargaNZ = 1'b1;
    {n, z}  = 2'b11;
    @(posedge clk);
    #2;
    check_nz(1'b1, 1'b1, "T5B recarrega (1,1) antes do reset em clk=0");
    @(negedge clk);
    #2;
    // Em clk=0, latch mestre esta transparente com (n,z)=(1,1); reset deve vencer!
    check_clk_level(1'b0, "T5B antes reset");
    check_nz(1'b1, 1'b1, "T5B confirma (1,1) em clk=0 antes do reset");
    rstn = 1'b0;
    #1;
    check_clk_level(1'b0, "T5B reset imediato");
    check_nz(1'b0, 1'b0, "T5B reset imediato em clk=0 zera (1,1)->(0,0)");
    @(posedge clk);
    #2;
    check_nz(1'b0, 1'b0, "T5B mantem (0,0) apos posedge com rstn=0");

    // 5C: Retomada de operacao normal apos reset em operacao
    @(negedge clk);
    #2;
    rstn    = 1'b1;
    cargaNZ = 1'b1;
    {n, z}  = 2'b10;
    #2;
    check_clk_level(1'b0, "T5C pre-posedge");
    check_nz(1'b0, 1'b0, "T5C pre-posedge apos liberar reset");
    @(posedge clk);
    #2;
    check_nz(1'b1, 1'b0, "T5C retoma carga normal (1,0) no posedge clk");

    // ------------------------------------------------------------------
    // Resumo final
    // ------------------------------------------------------------------
    $display("======================================================================");
    $display("Resumo tb_reg_n_z: PASS=%0d | FAIL=%0d", pass_count, fail_count);
    if (fail_count == 0) begin
      $display("STATUS: TODOS OS TESTES PASSARAM!");
    end else begin
      $display("STATUS: FALHAS DETECTADAS!");
      $fatal(1, "Testbench encerrado com %0d falha(s).", fail_count);
    end
    $display("======================================================================");
    $finish;
  end

endmodule
