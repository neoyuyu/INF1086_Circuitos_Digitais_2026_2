module mux (
    input  a,
    b,
    s0,
    output z
);
  wire not_s0, and_a, and_b;

  not (not_s0, s0);  // not_s0 = NOT(s0)
  and (and_a, a, not_s0);  // and_a = A · s̄0
  and (and_b, b, s0);  // and_b = B · s0
  or (z, and_a, and_b);  // z = and_a + and_b

endmodule
