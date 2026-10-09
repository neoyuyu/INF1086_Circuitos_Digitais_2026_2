module seg_D(
    input  wire [3:0] C,
    output wire D
);
		
    // Esse segmento foi modificado por nosso grupo para cobrir o caso 	
    assign D = ( C[2] &  C[1] &  C[0])            
             | (~C[3] & ~C[2] & ~C[1] &  C[0])     
             | (~C[3] &  C[2] & ~C[1] & ~C[0])     
             | ( C[3] & ~C[2] &  C[1] & ~C[0]);    

endmodule