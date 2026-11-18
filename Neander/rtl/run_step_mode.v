// Gabriel Tafarel
// Sayid Safa
module run_step_mode(
    input  run_debug, //entrada modo run ou debug: 1 debug(step), 0 run. 
	 input  clk,		 //clock dividido  =~ 2hz 
	 input step_signal, //sinal para dar um step quando no modo debug (0 apertado, 1 solto)
    output clk_out
);

	 wire clk_step;	// para retratar o botao invertido

    assign clk_step = ~step_signal;                
    assign clk_out  = run_debug ? clk_step : clk;  //se no modo run_debug manda o pulso, se nao continua no clock de 2hz
 
endmodule