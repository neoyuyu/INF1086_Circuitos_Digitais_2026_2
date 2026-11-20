module decoder2_4 (
    a,
    b,
    en,
    s0,
    s1,
    s2,
    s3
);
  input a, b, en;
  output s0, s1, s2, s3;

  assign s0 = ~a & ~b & ~en;
  assign s1 = ~a & b & ~en;
  assign s2 = a & ~b & ~en;
  assign s3 = a & b & ~en;

endmodule
