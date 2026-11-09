module soma (
    a,
    b,
    s
);

  input [7:0] a, b;
  output signed [8:0] s;
  assign s = {a[7], a} + {b[7], b};

endmodule

