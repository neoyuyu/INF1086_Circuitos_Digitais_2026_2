// Structural simulation netlist mirroring schematics/neander_top.bdf 1-to-1.
`timescale 1ns / 1ps

module neander_top (
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
    output wire       led_illegal
);

    wire       clk_div;
    wire       clk;
    wire       clk_n;

    wire [7:0] out_rdm;
    wire [7:0] mux_to_rem;
    wire [7:0] out_rem;
    wire [7:0] out_ram;
    wire [7:0] ri_out;
    wire [7:0] ula_s;
    wire [2:0] ula_sel;
    wire       ula_n;
    wire       ula_z;

    wire       cargaREM;
    wire       incPC;
    wire       cargaRI;
    wire       selMUX;
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

    divisor_frequencia inst1 (
        .clk  (clk_global),
        .rstn (rstn),
        .Q    (clk_div)
    );

    run_step_mode step_mode (
        .run_debug   (sw_run_debug),
        .clk         (clk_div),
        .step_signal (btn_step),
        .clk_out     (clk)
    );

    not inst3 (clk_n, clk);

    pc_estrutural inst8 (
        .clk          (clk),
        .rstn         (rstn),
        .cargaPC      (cargaPC),
        .incrementaPC (incPC),
        .data_in      (out_rdm),
        .pc           (out_pc)
    );

    mux8bit mux_1 (
        .a   (out_pc),
        .b   (out_rdm),
        .sel (selMUX),
        .s   (mux_to_rem)
    );

    reg8bit REM (
        .sinal_carga (cargaREM),
        .clk         (clk),
        .rstn        (rstn),
        .entrada     (mux_to_rem),
        .saida       (out_rem)
    );

    ALTDPRAM #(
        .FILE           ("prog.mif"),
        .INDATA_ACLR    ("ON"),
        .INDATA_REG     ("INCLOCK"),
        .NUMWORDS       (256),
        .OUTDATA_ACLR   ("ON"),
        .OUTDATA_REG    ("UNREGISTERED"),
        .RDADDRESS_ACLR ("ON"),
        .RDADDRESS_REG  ("OUTCLOCK"),
        .RDCONTROL_ACLR ("ON"),
        .RDCONTROL_REG  ("OUTCLOCK"),
        .USE_EAB        ("ON"),
        .WIDTH          (8),
        .WIDTHAD        (8),
        .WRADDRESS_ACLR ("ON"),
        .WRADDRESS_REG  ("INCLOCK"),
        .WRCONTROL_ACLR ("ON"),
        .WRCONTROL_REG  ("INCLOCK")
    ) inst (
        .inclocken  (1'b1),
        .inclock    (clk_n),
        .rdaddress  (out_rem),
        .rden       (read),
        .wraddress  (out_rem),
        .data       (out_rdm),
        .outclock   (clk_n),
        .outclocken (1'b1),
        .wren       (write),
        .aclr       (1'b0),
        .q          (out_ram)
    );

    rdm inst7 (
        .clk      (clk),
        .rstn     (rstn),
        .cargaRDM (cargaRDM),
        .read     (read),
        .dado_mem (out_ram),
        .dado_ac  (out_acm),
        .saida    (out_rdm)
    );

    reg8bit RI (
        .sinal_carga (cargaRI),
        .clk         (clk),
        .rstn        (rstn),
        .entrada     (out_rdm),
        .saida       (ri_out)
    );

    reg8bit acumulador (
        .sinal_carga (cargaAC),
        .clk         (clk),
        .rstn        (rstn),
        .entrada     (ula_s),
        .saida       (out_acm)
    );

    codificador_neander codificador_ula (
        .ula_y   (ula_y),
        .ula_add (ula_add),
        .ula_and (ula_and),
        .ula_or  (ula_or),
        .ula_not (ula_not),
        .sel     (ula_sel)
    );

    ula ula (
        .x   (out_acm),
        .y   (out_rdm),
        .sel (ula_sel),
        .s   (ula_s),
        .n   (ula_n),
        .z   (ula_z)
    );

    reg_n_z reg_n_z (
        .clk     (clk),
        .rstn    (rstn),
        .cargaNZ (cargaNZ),
        .n       (ula_n),
        .z       (ula_z),
        .n_out   (led_n),
        .z_out   (led_z)
    );

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
        .write        (write),
        .ula_y        (ula_y),
        .ula_add      (ula_add),
        .ula_or       (ula_or),
        .ula_and      (ula_and),
        .ula_not      (ula_not),
        .cargaAC      (cargaAC),
        .cargaNZ      (cargaNZ),
        .cargaPC      (cargaPC),
        .goto_t0      (),
        .hlt          (led_hlt),
        .illegal_op   (led_illegal),
        .t            ()
    );

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
