// Gabriel Tafarel
// Sayid Safa
//Modulo RDM
module rdm (
    input  wire       clk,
    input  wire       rstn,
    input  wire       cargaRDM,   // RDM <- AC (STA, t6)
    input  wire       read,       // RDM <- memória (leitura)
    input  wire [7:0] dado_mem,   // q da RAM do IP
    input  wire [7:0] dado_ac,    // saída do AC
    output wire [7:0] saida
	 
	 );
	 
    //Deixar a escolha dentro do rdm ao inves do or 
    wire [7:0] entrada = cargaRDM ? dado_ac : dado_mem;   // escolhe a fonte
    wire       carga   = cargaRDM | read;                  // se deve carregar

    reg8bit reg_inst (
        .sinal_carga(carga),
        .clk        (clk),
        .rstn       (rstn),
        .entrada    (entrada),
        .saida      (saida)
    );
	 
endmodule