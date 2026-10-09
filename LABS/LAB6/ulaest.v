// ULA 4 bits, complemento de 2 - versao estrutural
// Gabriel Tafarel
// Sayid Safa 07/10/2026
module ulaest(
    input  [3:0] a,
    input  [3:0] b,
    input  [1:0] opsel,
    output [3:0] s,
    output       flagn,
    output       flagz
);

    wire [3:0] out_rca, out_cla, out_shl, out_shra, out_op;
    wire       cout_rca, cout_cla;
    wire [3:0] mux1, mux2;

    // Somador RCA (modulo rca4b, em ha.v)
    rca4b RCA(
        .a(a),
        .b(b),
        .s(out_rca),
        .cout(cout_rca)
    );

    // Somador CLA (cla_4bits.v), Cin = 0
    cla_4bits CLA(
        .A(a),
        .B(b),
        .Cin(1'b0),
        .S(out_cla),
        .Cout(cout_cla)
    );

    // Shiftleft
    shl_4bits SHL(
        .a(a),
        .b(b),
        .y(out_shl)
    );
	 
	 // Shift right aritmetico
    shra_4bits SHRA(
        .a(a),
        .b(b),
        .y(out_shra)
    );

    // MUX1 (sel = opsel[0]): RCA / CLA
    assign mux1 = opsel[0] ? out_cla : out_rca;

    // MUX2 (sel = opsel[0]): << / >>
    assign mux2 = opsel[0] ? out_shra : out_shl;

    // MUX3 (sel = opsel[1]): soma / shift  -> resultado final da ULA
    assign out_op = opsel[1] ? mux2 : mux1;
    assign s = out_op;
	 
    flag_n_4bits FN(
        .S(out_op),
        .flag_n(flagn)
    );

    flag_z_4bits FZ(
        .S(out_op),
        .flag_z(flagz)
    );

endmodule