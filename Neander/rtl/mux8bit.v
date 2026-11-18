module mux8bit (
    input  [7:0] a,
    input  [7:0] b,
    input        sel,
    output [7:0] s
);

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_bloco_mux
      mux m_inst (
          .a (a[i]),
          .b (b[i]),
          .s0(sel),
          .z (s[i])
      );
    end
  endgenerate
endmodule

