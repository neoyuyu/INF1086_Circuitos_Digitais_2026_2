`timescale 1ns/1ps
module testbench;

  // nomes dos estados (os mesmos do módulo booth)
  localparam [2:0] S_IDLE  = 3'b000,
                   S_INIT  = 3'b001,
                   S_CHECK = 3'b010,
                   S_ADD   = 3'b011,
                   S_SUB   = 3'b100,
                   S_SHIFT = 3'b101,
                   S_DEC   = 3'b110,
                   S_DONE  = 3'b111;

  reg  clk, rst, start, q_0, q_minus, count_zero;
  wire load, op_add, op_sub, op_shift, op_dec, done;

  // circuito que será testado
  booth dut (.clk(clk), .rst(rst), .start(start), .q_0(q_0), .q_minus(q_minus),
             .count_zero(count_zero), .load(load), .op_add(op_add), .op_sub(op_sub),
             .op_shift(op_shift), .op_dec(op_dec), .done(done));
				 
  //verifica clock na descida 
  // 10 ns: sobe em 5, 15, 25... e desce em 10, 20, 30...
  initial clk = 0;
  always #5 clk = ~clk;
  
  initial begin

    // 1) rst: o estado inicial é S_IDLE
    rst = 0; start = 0; q_0 = 0; q_minus = 0; count_zero = 0;
    #10 rst = 1;
    #10;
    if (dut.current_state === S_IDLE) $display("OK   : rst leva a S_IDLE");
    else                              $display("ERRO : rst nao levou a S_IDLE");

    // 2) start = 1: IDLE -> INIT -> CHECK
    start = 1;
    #10;
    if (dut.current_state === S_INIT && load === 1) $display("OK   : IDLE -> INIT (load = 1)");
    else                                            $display("ERRO : IDLE -> INIT (load = 1)");
    start = 0;
    #10;
    if (dut.current_state === S_CHECK) $display("OK   : INIT -> CHECK");
    else                               $display("ERRO : INIT -> CHECK");

    // 3) e 4) as quatro combinações de {Q0,Q-1}

    q_0 = 0; q_minus = 0;      // 00 -> SHIFT, sem add e sem sub
    #10;
    if (dut.current_state === S_SHIFT && op_add === 0 && op_sub === 0) $display("OK   : 00 -> SHIFT, op_add = 0, op_sub = 0");
    else                                                               $display("ERRO : 00 -> SHIFT, op_add = 0, op_sub = 0");
    #20;                       // SHIFT -> DEC -> CHECK

    q_0 = 0; q_minus = 1;      // 01 -> ADD, só op_add
    #10;
    if (dut.current_state === S_ADD && op_add === 1 && op_sub === 0)   $display("OK   : 01 -> ADD, op_add = 1, op_sub = 0");
    else                                                               $display("ERRO : 01 -> ADD, op_add = 1, op_sub = 0");
    #30;                       // ADD -> SHIFT -> DEC -> CHECK

    q_0 = 1; q_minus = 0;      // 10 -> SUB, só op_sub
    #10;
    if (dut.current_state === S_SUB && op_add === 0 && op_sub === 1)   $display("OK   : 10 -> SUB, op_add = 0, op_sub = 1");
    else                                                               $display("ERRO : 10 -> SUB, op_add = 0, op_sub = 1");
    #30;                       // SUB -> SHIFT -> DEC -> CHECK

    q_0 = 1; q_minus = 1;      // 11 -> SHIFT, sem add e sem sub
    #10;
    if (dut.current_state === S_SHIFT && op_add === 0 && op_sub === 0) $display("OK   : 11 -> SHIFT, op_add = 0, op_sub = 0");
    else                                                               $display("ERRO : 11 -> SHIFT, op_add = 0, op_sub = 0");
    #20;                       // SHIFT -> DEC -> CHECK

    // 5) count_zero = 1: CHECK -> DONE (start = 1 para o próximo teste)
    count_zero = 1; start = 1;
    #10;
    if (dut.current_state === S_DONE && done === 1) $display("OK   : count_zero = 1 leva a DONE (done = 1)");
    else                                            $display("ERRO : count_zero = 1 leva a DONE (done = 1)");

    // 6) com start = 1 continua em DONE; com start = 0 volta a IDLE
    #10;
    if (dut.current_state === S_DONE && done === 1) $display("OK   : start = 1: continua em DONE (done = 1)");
    else                                            $display("ERRO : start = 1: continua em DONE (done = 1)");
    start = 0;
    #10;
    if (dut.current_state === S_IDLE && done === 0) $display("OK   : start = 0: DONE -> IDLE (done = 0)");
    else                                            $display("ERRO : start = 0: DONE -> IDLE (done = 0)");

    $stop;
  end
endmodule