module FLAGZEROEST(
    input [3:0]S,
	 output flag_z
);
    assign flag_z = ~(S[0] | S[1] | S[2] | S[3]);
	 
endmodule