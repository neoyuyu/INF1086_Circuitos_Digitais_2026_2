// Top-level estrutural do processador Neander
// Baseado em schematics/neander_top.bdf

module top_neander (
    input  wire       clk_global,
    input  wire       sw_run_debug,
    input  wire       btn_step,
    input  wire       rstn,
    output wire [7:0] out_pc,
    output wire [7:0] out_acm,
    output wire       a_1,
    output wire       b_1,
    output wire       c_1,
    output wire       d_1,
    output wire       e_1,
    output wire       f_1,
    output wire       g_1,
    output wire       a_2,
    output wire       b_2,
    output wire       c_2,
    output wire       d_2,
    output wire       e_2,
    output wire       f_2,
    output wire       g_2,
    output wire       a_3,
    output wire       b_3,
    output wire       c_3,
    output wire       d_3,
    output wire       e_3,
    output wire       f_3,
    output wire       g_3,
    output wire       a_4,
    output wire       b_4,
    output wire       c_4,
    output wire       d_4,
    output wire       e_4,
    output wire       f_4,
    output wire       g_4,
    output wire       led_n,
    output wire       led_z,
    output wire       led_hlt,
    output wire       led_illegal,
    output wire       led_goto_t0
);

    // Sinais de clock
    wire       clk_div;
    wire       clk;

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

    // Divisor de frequencia (50 MHz -> ~3 Hz)
    divisor_frequencia inst1 (
        .clk  (clk_global),
        .rstn (rstn),
        .Q    (clk_div)
    );

    // Seletor de modo run / step (debug)
    run_step_mode step_mode (
        .run_debug   (sw_run_debug),
        .clk         (clk_div),
        .step_signal (btn_step),
        .clk_out     (clk)
    );

    // Program Counter (PC)
    pc_estrutural inst8 (
        .clk          (clk),
        .rstn         (rstn),
        .cargaPC      (cargaPC),
        .incrementaPC (incPC),
        .data_in      (out_rdm),
        .pc           (out_pc)
    );

    // Multiplexador de endereco da memoria (PC ou RDM)
    mux8bit mux_1 (
        .a   (out_pc),
        .b   (out_rdm),
        .sel (selMUX),
        .s   (mux_to_rem)
    );

    // Registrador de Enderecos de Memoria (REM)
    reg8bit REM (
        .sinal_carga (cargaREM),
        .clk         (clk),
        .rstn        (rstn),
        .entrada     (mux_to_rem),
        .saida       (out_rem)
    );

    // Memoria ROM (ROM_teste.vhd)
    ROM_teste inst (
        .entrada (out_rem),
        .saida   (out_ram)
    );

    // Registrador de Dados de Memoria (RDM)
    rdm inst7 (
        .clk      (clk),
        .rstn     (rstn),
        .cargaRDM (cargaRDM),
        .read     (read),
        .dado_mem (out_ram),
        .dado_ac  (out_acm),
        .saida    (out_rdm)
    );

    // Registrador de Instrucao (RI)
    reg8bit RI (
        .sinal_carga (cargaRI),
        .clk         (clk),
        .rstn        (rstn),
        .entrada     (out_rdm),
        .saida       (ri_out)
    );

    // Acumulador (AC)
    reg8bit acumulador (
        .sinal_carga (cargaAC),
        .clk         (clk),
        .rstn        (rstn),
        .entrada     (ula_s),
        .saida       (out_acm)
    );

    // Codificador da ULA
    codificador_neander codificador_ula (
        .ula_y   (ula_y),
        .ula_add (ula_add),
        .ula_and (ula_and),
        .ula_or  (ula_or),
        .ula_not (ula_not),
        .sel     (ula_sel)
    );

    // Unidade Logica e Aritmetica (ULA)
    ula ula (
        .x   (out_acm),
        .y   (out_rdm),
        .sel (ula_sel),
        .s   (ula_s),
        .n   (ula_n),
        .z   (ula_z)
    );

    // Registrador de flags N e Z
    reg_n_z reg_n_z (
        .clk     (clk),
        .rstn    (rstn),
        .cargaNZ (cargaNZ),
        .n       (ula_n),
        .z       (ula_z),
        .n_out   (led_n),
        .z_out   (led_z)
    );

    // Unidade de Controle
    unidade_controle unidade_controle (
        .clk          (clk),
        .rstn         (rstn),
        .opcode       (ri_out[7:4]),
        .n            (led_n),
        .z            (led_z),
        .cargaREM     (cargaREM),
        .incrementaPC (incPC),
        .cargaRI      (cargaRI),
        .sel          (selMUX),
        .cargaRDM     (cargaRDM),
        .read         (read),
        .write        (),
        .ula_y        (ula_y),
        .ula_add      (ula_add),
        .ula_or       (ula_or),
        .ula_and      (ula_and),
        .ula_not      (ula_not),
        .cargaAC      (cargaAC),
        .cargaNZ      (cargaNZ),
        .cargaPC      (cargaPC),
        .goto_t0      (led_goto_t0),
        .hlt          (led_hlt),
        .illegal_op   (led_illegal),
        .t            ()
    );

    // Conversores BCD / 7 segmentos (PC: HEX2/HEX3, AC: HEX0/HEX1)
    conversor_bcd HEX2 (
        .a    (out_pc[3:0]),
        .segA (a_1),
        .segB (b_1),
        .segC (c_1),
        .segD (d_1),
        .segE (e_1),
        .segF (f_1),
        .segG (g_1)
    );

    conversor_bcd HEX3 (
        .a    (out_pc[7:4]),
        .segA (a_2),
        .segB (b_2),
        .segC (c_2),
        .segD (d_2),
        .segE (e_2),
        .segF (f_2),
        .segG (g_2)
    );

    conversor_bcd HEX0 (
        .a    (out_acm[3:0]),
        .segA (a_3),
        .segB (b_3),
        .segC (c_3),
        .segD (d_3),
        .segE (e_3),
        .segF (f_3),
        .segG (g_3)
    );

    conversor_bcd HEX1 (
        .a    (out_acm[7:4]),
        .segA (a_4),
        .segB (b_4),
        .segC (c_4),
        .segD (d_4),
        .segE (e_4),
        .segF (f_4),
        .segG (g_4)
    );

endmodule
