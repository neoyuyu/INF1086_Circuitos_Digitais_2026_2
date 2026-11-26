module booth_top (
    input clk, rst, start,
    input  [3:0] multiplicand, multiplier,
    output [7:0] product,
    output done
);
   wire load, op_add, op_sub, op_shift, op_dec, q_0, q_minus, count_zero;
	
	booth_control pc (.clk(clk), .rst(rst), .start(start), .q_0(q_0), .q_minus(q_minus),
                  .count_zero(count_zero), .load(load), .op_add(op_add), .op_sub(op_sub),
                  .op_shift(op_shift), .op_dec(op_dec), .done(done));
   booth_datapath po (.clk(clk), .rst(rst), .load(load), .op_add(op_add), .op_sub(op_sub),
              .op_shift(op_shift), .op_dec(op_dec), .multiplicand(multiplicand),
              .multiplier(multiplier), .q_0(q_0), .q_minus(q_minus),
              .count_zero(count_zero), .product(product));
				  
endmodule
 