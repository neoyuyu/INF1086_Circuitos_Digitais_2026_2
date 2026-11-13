module memoria ( // Modulo de memoria ROM assincrona
    input re,
    input [9:0] endereco,
    output reg [15:0] dado
);

  // memoria de 1024 linhas, cada uma com 16 bits
  reg [15:0] Memoria[0:1023];

  // Inicializa memoria a partir de um arquivo .mem
  initial $readmemh("hex_memory_file.mem", Memoria, 0, 1023);

  // Comportamento da memória
  always @(endereco, re) begin
    if (re) dado <= memoria[endereco];
    else dado <= 16'hFFFF;
  end


endmodule

// Modulo de memoria ROM síncrona
module memoria_sincrona (
    input clk,
    input re,
    input [9:0] endereco,
    output reg [15:0] dado
);

  // memoria de 1024 linhas, cada uma com 16 bits
  reg [15:0] Memoria[0:1023];

  // Inicializa memoria a partir de um arquivo .mem
  initial $readmemh("hex_memory_file.mem", Memoria, 0, 1023);

  // Comportamento da memória
  always @(posedge clk) begin
    if (re) dado <= memoria[endereco];
    else dado <= 16'hFFFF;
  end


endmodule

