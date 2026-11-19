module muxComp(
    input  [7:0] a, b,
    input        s0,
    output reg [7:0] z
);

    always @(*)
    begin
        if (s0 == 0)
            z = a;
        else
            z = b;
    end

endmodule