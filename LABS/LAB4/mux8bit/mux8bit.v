module mux8bit(
        input  [7:0] a,
        input  [7:0] b,
        input        sel,
        output [7:0] s
    );

        genvar i;
        generate
            for (i = 0; i < 8; i = i + 1) begin : bloco_mux
                mux m_inst (
                    .a(a[i]),
                    .b(b[i]),
                    .s0(sel),
                    .z(s[i])
                );
            end
        endgenerate
    endmodule

module mux(
        input a, b, s0,
        output z
    );
        wire not_s0, and_a, and_b;

        not (not_s0, s0);
        and (and_a, a, not_s0);
        and (and_b, b, s0);
        or  (z, and_a, and_b);
    endmodule