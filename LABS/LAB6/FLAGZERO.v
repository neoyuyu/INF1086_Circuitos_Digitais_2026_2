module FLAGZERO(
    input S[3:0],
	 output flag_Z
);
    assign flag_Z = ~(s[0] | s[1]^ s[2]^ s[3]);
	 
endmodule