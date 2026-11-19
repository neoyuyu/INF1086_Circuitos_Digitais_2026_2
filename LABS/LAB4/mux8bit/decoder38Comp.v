/**module decoder 3:8 comportamental(

**/
module decoder38Comp(
    input a0, a1,a2,
    output reg d0,d1,d2,d3,d4,d5,d6,d7
);
	

	always@(*)
	begin
		{d0,d1,d2,d3,d4,d5,d6,d7} = 8'b0;  //Importante para evitar latch? 
	
		case ({a2, a1, a0})
			3'b000: d0 = 1;
         3'b001: d1 = 1;
         3'b010: d2 = 1;
         3'b011: d3 = 1;
         3'b100: d4 = 1;
         3'b101: d5 = 1;
         3'b110: d6 = 1;
         3'b111: d7 = 1;
      endcase
	end
	
endmodule