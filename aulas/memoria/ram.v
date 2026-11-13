module ram (
    input clk,
    rst,
    input [9:0] endereco,
    input re,
    we,
    output reg [15:0] dado
);

  reg [15:0] memoria[0:1023];
  integer i;

  initial $readmemh("hex_memory_file.mem", memoria);

  always @(posedge clk or negedge rst) begin
    if (rst == 0) begin
      for (i = 0; i < 1023; i = i + 1) memoria[i] <= 0;
    end else begin
      if (re == 1) begin

        dado <= memoria[endereco];

      end
      memoria[endereco] <= dado;
    end
  end
endmodule

