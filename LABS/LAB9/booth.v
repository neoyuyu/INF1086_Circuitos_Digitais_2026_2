module booth (
    input clk,
    rst,
    start,
    q_0,
    q_minus,
    count_zero,
    output reg load,
    op_add,
    op_sub,
    op_shift,
    op_dec,
    done
);

  localparam reg [2:0] S_IDLE = 3'b000;
  localparam reg [2:0] S_INIT = 3'b001;
  localparam reg [2:0] S_CHECK = 3'b010;
  localparam reg [2:0] S_ADD = 3'b011;
  localparam reg [2:0] S_SUB = 3'b100;
  localparam reg [2:0] S_SHIFT = 3'b101;
  localparam reg [2:0] S_DEC = 3'b110;
  localparam reg [2:0] S_DONE = 3'b111;
  reg [2:0] next_state;
  reg [2:0] current_state;
  

  // 3 - Registradores de estado
  always @(posedge clk or negedge rst) begin
    if (rst == 0) current_state <= S_IDLE;  //reset assincrono
    else current_state <= next_state;
  end

  // 2 - Lógica de próximo estado
  always @(current_state, start, count_zero, q_0, q_minus) begin
    case (current_state)
      S_IDLE: next_state = start ? S_INIT : S_IDLE;
		
      S_INIT: next_state = S_CHECK;
		
		S_CHECK: next_state = count_zero ? S_DONE : 
		(~q_0 &&  q_minus) ? S_ADD :
      ( q_0 && ~q_minus) ? S_SUB : S_SHIFT;
		
	
      S_ADD: next_state = S_SHIFT;
		
      S_SUB: next_state = S_SHIFT;
		
      S_SHIFT: next_state = S_DEC;
		
      S_DEC: next_state = S_CHECK;
		
      S_DONE: next_state = start ? S_DONE : S_IDLE;
		
      default: next_state = S_IDLE;
    endcase
  end

  // 3 - Lógica de saída
  always @(current_state) begin
    // Valores padrão
    load = 1'b0;
    op_add = 1'b0;
    op_sub = 1'b0;
    op_shift = 1'b0;
    op_dec = 1'b0;
    done = 1'b0;

    case (current_state)
      S_INIT:  load = 1'b1;
      S_CHECK: ;
      S_ADD: op_add = 1'b1;
      S_SUB:  op_sub = 1'b1;
      S_SHIFT: op_shift = 1'b1;
      S_DEC:   op_dec = 1'b1;
      S_DONE:  done = 1'b1;
      default: ;
    endcase
  end
endmodule

