module booth_top (
    input clk,
    rst,
    start,
    input [3:0] multiplicand,
    multiplier,
    output [7:0] product,
    output done,
    output [6:0] hex0,
    output [6:0] hex1,
    output [6:0] hex2,
    output [6:0] hex3
);
  wire load, op_add, op_sub, op_shift, op_dec, q_0, q_minus, count_zero;

  booth_control pc (
      .clk(clk),
      .rst(rst),
      .start(start),
      .q_0(q_0),
      .q_minus(q_minus),
      .count_zero(count_zero),
      .load(load),
      .op_add(op_add),
      .op_sub(op_sub),
      .op_shift(op_shift),
      .op_dec(op_dec),
      .done(done)
  );
  booth_datapath po (
      .clk(clk),
      .rst(rst),
      .load(load),
      .op_add(op_add),
      .op_sub(op_sub),
      .op_shift(op_shift),
      .op_dec(op_dec),
      .multiplicand(multiplicand),
      .multiplier(multiplier),
      .q_0(q_0),
      .q_minus(q_minus),
      .count_zero(count_zero),
      .product(product)
  );

  // Conversao do produto (complemento de 2, 8 bits) para BCD com sinal
  wire is_neg = product[7];
  wire [7:0] abs_product = is_neg ? (~product + 8'd1) : product;
  wire [3:0] unidades = abs_product % 8'd10;
  wire [3:0] dezenas  = (abs_product / 8'd10) % 8'd10;

  conversor_bcd bcd_unid (
      .a(unidades),
      .segA(hex0[0]),
      .segB(hex0[1]),
      .segC(hex0[2]),
      .segD(hex0[3]),
      .segE(hex0[4]),
      .segF(hex0[5]),
      .segG(hex0[6])
  );

  conversor_bcd bcd_dez (
      .a(dezenas),
      .segA(hex1[0]),
      .segB(hex1[1]),
      .segC(hex1[2]),
      .segD(hex1[3]),
      .segE(hex1[4]),
      .segF(hex1[5]),
      .segG(hex1[6])
  );

  // Sinal negativo no HEX2 (ativo em 0: apenas segG aceso) e HEX3 apagado
  assign hex2 = is_neg ? 7'b0111111 : 7'b1111111;
  assign hex3 = 7'b1111111;

endmodule

