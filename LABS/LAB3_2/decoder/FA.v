module FA (
    A,
    B,
    Cin,
    S,
    Cout
);
  input A, B, Cin;
  output S, Cout;

  assign AxorB = A ^ B;
  assign S = AxorB ^ Cin;
  assign Cout = (AxorB & Cin) | (A & B);

endmodule
