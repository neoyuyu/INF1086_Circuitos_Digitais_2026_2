module bit_slice (
    input  clk,
    input  enb,
    input  rst,
    input  cin,
    output q,
    output cout
);

  wire soma;
  wire in_ff;
  wire qn;

  assign soma  = q ^ cin;
  assign cout  = q & cin;

  assign in_ff = enb ? soma : q;

  ff_d FLIPSFLOPERS (
      .clk(clk),
      .rstn(rst),
      .d(in_ff),
      .q(q),
      .qn(qn)
  );

endmodule

module sync_count (
    input wire clk,
    input enb,
    input rst,
    output wire [3:0] out_4
);

  wire [4:0] c;  // declara com 5 bits pra não acessar indice invalido no loop
  assign c[0] = 1'b1;

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : gen_count_bit
      bit_slice BITERS (
          .clk(clk),
          .enb(enb),
          .rst(rst),
          .cin(c[i]),
          .q(out_4[i]),
          .cout(c[i+1])
      );
    end
  endgenerate

endmodule
