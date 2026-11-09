module circuito (
    input a,
    b,
    sel,
    output reg y
);

  always @(a or b or sel) begin

    if (sel == 1'b0) y = a | b;
    else y = a & b;
  end

endmodule
