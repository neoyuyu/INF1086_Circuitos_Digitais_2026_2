module fsm (
    input  reset,
    clk,
    presenca,
    output q
);

  localparam FECHA = 1'b0, ABRE = 1'b1;
  reg current_state;
  reg next_state;
  // 1 - registrador de estado
  always @(posedge clk or negedge rst) begin
    if (reset == 0) current_state <= FECHA;
    else current_state <= next_state;
  end
  // 2 - lógica de próximo estado (combinacional)
  always @(current_state, presenca) begin
    case (current_state)
      FECHA:
      if (presenca) next_state <= ABRE;
      else next_state <= FECHA;
      ABRE:
      if (presenca) next_state <= ABRE;
      else next_state <= FECHA;
      default:
      if (presenca) next_state <= ABRE;
      else next_state <= FECHA;
    endcase
  end

  // 3 - lógica de saída (combinacional)
  always @(current_state) begin
    case (current_state)
      FECHA: q <= 1'b1;
      ABRE: q <= 1'b0;
      default: q <= 1'b0;
    endcase
  end
endmodule

