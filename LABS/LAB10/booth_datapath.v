// Registradores: M (4), AQ = {A(5), Q(4), Q-1(1)} (10), cnt (contador up/down do Lab 09, 8 bits)
module booth_datapath (
    input        clk,
    input        rst,                 // ativo em 0
    input        load, op_add, op_sub, op_shift, op_dec,   
    input  [3:0] multiplicand,        // M (B da placa)
    input  [3:0] multiplier,          // Q (A da placa
    output       q_0, q_minus, count_zero,                 // status para a PC
    output [7:0] product
);
   //Variaveis para os registradores
    wire [3:0] M,  M_next;
    wire [9:0] AQ, AQ_next;           // {A[4:0], Q[3:0], Q-1}
    wire [7:0] cnt;

    // Somar ou subtrair o A 
	
    wire [4:0] M_ext   = {M[3], M};                 // extensao de sinal de M (5 bits)
    wire [4:0] A       = AQ[9:5];
	 //Somar ou subtrair e colocar resposta
    wire [4:0] add_res = A + M_ext;
    wire [4:0] sub_res = A - M_ext;
	 
    wire [4:0] A_new   = op_add ? add_res :
                         op_sub ? sub_res : A;      // sem op: A mantem

    //Faz ASHIFTR quando necessario
    wire [9:0] AQ_shift = {AQ[9], AQ[9:1]};

   // Cada registrador: se load -> valor inicial; senao, a operacao da vez; senao, mantem.

	// M: so muda no load
	assign M_next = load ? multiplicand : M;

	// AQ: candidatos, um por situacao
	wire [9:0] AQ_init   = {5'b00000, multiplier, 1'b0};  // A=0, Q=multiplicador, Q-1=0
	wire [9:0] AQ_addsub = {A_new, AQ[4:0]};              // so o campo A muda (add, sub ou nada)
	// (AQ_shift ja foi definido acima)

	assign AQ_next = load     ? AQ_init   :   // 1o: carga
						  op_shift ? AQ_shift  :   // 2o: desloca tudo
										 AQ_addsub;    // senao: soma/sub em A (ou mantem)

	// contador: o proprio modulo contador faz carga, mantem e decremento
	wire [7:0] cnt_init = 8'd4;               // 8N 
	// sel: 00 = carga, 01 = mantem, 11 = decremento
	wire [1:0] cnt_sel  = load   ? 2'b00 :
	                      op_dec ? 2'b11 :    
	                               2'b01;     

    // Registadores 
    genvar i;
    generate
        for (i = 0; i < 4;  i = i + 1) begin : g_M
            ff_d f (.d(M_next[i]),   .clk(clk), .rstn(rst), .q(M[i]),   .qn());
        end
        for (i = 0; i < 10; i = i + 1) begin : g_AQ
            ff_d f (.d(AQ_next[i]),  .clk(clk), .rstn(rst), .q(AQ[i]),  .qn());
        end
    endgenerate
	 
	  //Contador eh quem sabe quantas iterações faltam
    contador CNT (.d(cnt_init), .sel(cnt_sel), .clk(clk), .rstn(rst), .q(cnt));
	 
    //fios de status e resultados
    assign q_0        = AQ[1];
    assign q_minus    = AQ[0];
    assign count_zero = ~|cnt;   //Carga para verificar se o contador chegou a zero, terminando a op
    assign product    = AQ[8:1];
endmodule