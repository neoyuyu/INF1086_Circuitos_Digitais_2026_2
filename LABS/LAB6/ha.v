module ha(a, b, s, cout);

	input a, b;
	output s, cout;
	
		assign s = a ^ b;
		assign cout = a & b;
	
endmodule

module fa(a, b, cin, s, cout);

	input a, b, cin;
	output s, cout;
	
	assign s = (a ^ b ^ cin);
	assign cout = (a & b) | ((a ^ b) & cin);
	
endmodule
		
module rca4b(a, b, s, cout);

    input [3:0] a, b;
    output [3:0] s;
    output cout;

    wire [3:0] c;

    ha HA(
        .a(a[0]),
        .b(b[0]),
        .s(s[0]),
        .cout(c[0])
    );

    generate
        genvar i;
        for (i = 1; i < 4; i = i + 1) begin : FA_gen
            fa FA(
                .a(a[i]),
                .b(b[i]),
                .cin(c[i-1]),
                .s(s[i]),
                .cout(c[i])
            );
        end
    endgenerate

    assign cout = c[3];

endmodule