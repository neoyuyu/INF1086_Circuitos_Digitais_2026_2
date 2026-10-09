module shl_4bits(
    input      [3:0] a,
    input      [3:0] b,
    output reg [3:0] y
);
    integer i;

    always @(*) begin
        y = a;
        for (i = 0; i < 15; i = i + 1) begin
            if (i < b)
                y = {y[2:0], 1'b0};   // desloca 1 p/ esquerda, entra 0
        end
    end
endmodule