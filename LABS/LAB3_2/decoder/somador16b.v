module somador16b(A, B, S, Cout);

input [15:0] A, B;
output [15:0] S, Cout;

	assign {Cout, S} = A + B;
	
endmodule