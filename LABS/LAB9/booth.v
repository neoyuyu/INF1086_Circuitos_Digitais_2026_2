module booth (
    input  clk,
    rst,
    start,
    q0,
    q_minus,
    count_zero,
    output load,
    op_add,
    op_sub,
    op_shift,
    op_dec,
    done
);

  localparam S_IDLE = 3'b000;
  localparam S_INIT = 3'b001;
  localparam S_CHECK = 3'b010;
  localparam S_ADD = 3'b011;
  localparam S_SUB = 3'b100;
  localparam S_SHIFT = 3'b101;
  localparam S_DEC = 3'b110;
  localparam S_DONE = 3'b111;
  reg next_state;
  reg current_state;

  // 3 - Registradores de estado
  always @(posedge clk or negedge rst) begin
    if (reset == 0) current_state = S_IDLE;
    else current_state <= next_state;
  end

  // 2 - Lógica de próximo estado
  always @(current_state, start, count_zero, q_0, q_minus) begin
    case (current_state)
      S_IDLE: next_state <= start ? S_INIT : S_IDLE;
      S_INIT: next_state <= S_CHECK;
      S_CHECK:
      // TODO
      ;
      S_ADD:
      // TODO
      ;
      S_SUB:
      // TODO
      ;
      S_SHIFT:
      // TODO
      ;
      S_DEC: next_state <= S_CHECK;
      S_DONE: next_state <= start ? S_DONE : S_IDLE;
      default: next_state <= S_IDLE;
    endcase
  end

  // 3 - Lógica de saíaa
  always @(current_state) begin
    case (current_state)
      S_IDLE: begin
        load <= 1'b0;
        op_add <= 1'b0;
        op_sub <= 1'b0;
        op_shift <= 1'b0;
        op_dec <= 1'b0;
        done <= 1'b0;
      end
      S_INIT: begin
        load <= 1'b1;
        op_add <= 1'b0;
        op_sub <= 1'b0;
        op_shift <= 1'b0;
        op_dec <= 1'b0;
        done <= 1'b0;
      end
      S_CHECK: ;
      S_ADD:   ;
      S_SUB:   ;
      S_SHIFT: ;
      S_DEC: begin
        load <= 1'b0;
        op_add <= 1'b0;
        op_sub <= 1'b0;
        op_shift <= 1'b0;
        op_dec <= 1'b1;
        done <= 1'b0;
      end
      S_DONE: begin
        load <= 1'b0;
        op_add <= 1'b0;
        op_sub <= 1'b0;
        op_shift <= 1'b0;
        op_dec <= 1'b0;
        done <= 1'b1;
      end
      default: begin
        load <= 1'b0;
        op_add <= 1'b0;
        op_sub <= 1'b0;
        op_shift <= 1'b0;
        op_dec <= 1'b0;
        done <= 1'b0;
      end
    endcase
  end
endmodule

