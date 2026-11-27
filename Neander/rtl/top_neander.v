// Top-level estrutural do processador Neander
// Baseado em schematics/neander_top.bdf

module top_neander (
    input  wire       clk,
    input  wire       sw_run_debug,
    input  wire       btn_step,
    input  wire       rstn,
    output wire [7:0] out_pc,
    output wire [7:0] out_acm,
    output wire [6:0] hex3,
    output wire [6:0] hex2,
    output wire [6:0] hex1,
    output wire [6:0] hex0,
    output wire       led_n,
    output wire       led_z,
    output wire       led_hlt,
    output wire       led_illegal,
    output wire       led_goto_t0
);

  // Sinal de clock efetivo (run / step)
  wire       clk_eff;

  // Barramentos internos de dados e enderecos
  wire [7:0] out_rdm;
  wire [7:0] mux_to_rem;
  wire [7:0] out_rem;
  wire [7:0] out_ram;
  wire [7:0] ri_out;
  wire [7:0] ula_s;
  wire [2:0] ula_sel;
  wire       ula_n;
  wire       ula_z;

  // Sinais de controle
  wire       cargaREM;
  wire       incPC;
  wire       cargaRI;
  wire       selMUX;
  wire       cargaRDM;
  wire       read;
  wire       ula_y;
  wire       ula_add;
  wire       ula_or;
  wire       ula_and;
  wire       ula_not;
  wire       cargaAC;
  wire       cargaNZ;
  wire       cargaPC;

  // Seletor de modo run / step (debug)
  run_step_mode step_mode (
      .run_debug  (sw_run_debug),
      .clk        (clk),
      .step_signal(btn_step),
      .clk_out    (clk_eff)
  );

  // Program Counter (PC)
  pc_estrutural inst8 (
      .clk         (clk_eff),
      .rstn        (rstn),
      .cargaPC     (cargaPC),
      .incrementaPC(incPC),
      .data_in     (out_rdm),
      .pc          (out_pc)
  );

  // Multiplexador de endereco da memoria (PC ou RDM)
  mux8bit mux_1 (
      .a  (out_pc),
      .b  (out_rdm),
      .sel(selMUX),
      .s  (mux_to_rem)
  );

  // Registrador de Enderecos de Memoria (REM)
  reg8bit REM (
      .sinal_carga(cargaREM),
      .clk        (clk_eff),
      .rstn       (rstn),
      .entrada    (mux_to_rem),
      .saida      (out_rem)
  );

  // Memoria ROM (ROM_teste.vhd)
  ROM_teste inst (
      .entrada(out_rem),
      .saida  (out_ram)
  );

  // Registrador de Dados de Memoria (RDM)
  rdm inst7 (
      .clk     (clk_eff),
      .rstn    (rstn),
      .cargaRDM(cargaRDM),
      .read    (read),
      .dado_mem(out_ram),
      .dado_ac (out_acm),
      .saida   (out_rdm)
  );

  // Registrador de Instrucao (RI)
  reg8bit RI (
      .sinal_carga(cargaRI),
      .clk        (clk_eff),
      .rstn       (rstn),
      .entrada    (out_rdm),
      .saida      (ri_out)
  );

  // Acumulador (AC)
  reg8bit acumulador (
      .sinal_carga(cargaAC),
      .clk        (clk_eff),
      .rstn       (rstn),
      .entrada    (ula_s),
      .saida      (out_acm)
  );

  // Codificador da ULA
  codificador_neander codificador_ula (
      .ula_y  (ula_y),
      .ula_add(ula_add),
      .ula_and(ula_and),
      .ula_or (ula_or),
      .ula_not(ula_not),
      .sel    (ula_sel)
  );

  // Unidade Logica e Aritmetica (ULA)
  ula ula (
      .x  (out_acm),
      .y  (out_rdm),
      .sel(ula_sel),
      .s  (ula_s),
      .n  (ula_n),
      .z  (ula_z)
  );

  // Registrador de flags N e Z
  reg_n_z reg_n_z (
      .clk    (clk_eff),
      .rstn   (rstn),
      .cargaNZ(cargaNZ),
      .n      (ula_n),
      .z      (ula_z),
      .n_out  (led_n),
      .z_out  (led_z)
  );

  // Unidade de Controle
  unidade_controle unidade_controle (
      .clk         (clk_eff),
      .rstn        (rstn),
      .opcode      (ri_out[7:4]),
      .n           (led_n),
      .z           (led_z),
      .cargaREM    (cargaREM),
      .incrementaPC(incPC),
      .cargaRI     (cargaRI),
      .sel         (selMUX),
      .cargaRDM    (cargaRDM),
      .read        (read),
      .write       (),
      .ula_y       (ula_y),
      .ula_add     (ula_add),
      .ula_or      (ula_or),
      .ula_and     (ula_and),
      .ula_not     (ula_not),
      .cargaAC     (cargaAC),
      .cargaNZ     (cargaNZ),
      .cargaPC     (cargaPC),
      .goto_t0     (led_goto_t0),
      .hlt         (led_hlt),
      .illegal_op  (led_illegal),
      .t           ()
  );

  // Conversores BCD / 7 segmentos (PC: HEX3/HEX2, AC: HEX1/HEX0)
  // Bit [0]=segA .. [6]=segG, ativo em nivel baixo (padrao DE0 / qihu)
  conversor_bcd HEX2 (
      .a   (out_pc[3:0]),
      .segA(hex2[0]),
      .segB(hex2[1]),
      .segC(hex2[2]),
      .segD(hex2[3]),
      .segE(hex2[4]),
      .segF(hex2[5]),
      .segG(hex2[6])
  );

  conversor_bcd HEX3 (
      .a   (out_pc[7:4]),
      .segA(hex3[0]),
      .segB(hex3[1]),
      .segC(hex3[2]),
      .segD(hex3[3]),
      .segE(hex3[4]),
      .segF(hex3[5]),
      .segG(hex3[6])
  );

  conversor_bcd HEX0 (
      .a   (out_acm[3:0]),
      .segA(hex0[0]),
      .segB(hex0[1]),
      .segC(hex0[2]),
      .segD(hex0[3]),
      .segE(hex0[4]),
      .segF(hex0[5]),
      .segG(hex0[6])
  );

  conversor_bcd HEX1 (
      .a   (out_acm[7:4]),
      .segA(hex1[0]),
      .segB(hex1[1]),
      .segC(hex1[2]),
      .segD(hex1[3]),
      .segE(hex1[4]),
      .segF(hex1[5]),
      .segG(hex1[6])
  );

endmodule
