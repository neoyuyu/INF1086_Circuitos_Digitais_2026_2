module ff (
    input wire clk,
    enb,
    d,
    output q
);

  always @(posedge clk) begin
    if (rst) begin
      q <= 1'b0;
    end else begin
      q <= d;
    end
  end
endmodule

module bit_slice (
    input  clk,
    rst,
    cin,
    output q,
    cout
);

  wire soma;
  wire in_ff;

  assign soma  = q ^ cin;

  assign in_ff = enb ? soma : q;

  ff FLIPSFLOPERS (
      .clk(clk),
      .enb(rst),
      .d  (in_ff),
      .q  (q)
  );

endmodule

module sync_count (
    input wire clk,
    enb,
    output wire [3:0] out_4
);

  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : gen_count_bit
      bit_slice BITERS (
          .clk(clk),
          .rst(enb),
          .cin((i == 0) ? 1'b1 : c[i-1]),
          .q(out_4[i]),
          .cout(c[i])
      );
    end
  endgenerate

endmodule
