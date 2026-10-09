module shra_4bits(
    input      [3:0] a,
    input      [3:0] b,
    output reg [3:0] y
);
    integer i;

    always @(*) begin
        y = a;
        for (i = 0; i < 15; i = i + 1) begin
            if (i < b)
                y = {y[3], y[3:1]};   // desloca 1 p/ direita, repete o sinal
        end
    end
endmodule