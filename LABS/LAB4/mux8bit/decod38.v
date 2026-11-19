module decod38(
    input a0, a1, a2,
    output d0,d1,d2,d3,d4,d5,d6,d7
);
	wire not_a2;
	assign not_a2 = ~a2;
	
	decod2_4 decoder_low(
		.a2(not_a2),
		.a0(a0),
		.a1(a1),
		.d0(d0),
		.d1(d1),
		.d2(d2),
		.d3(d3)
	);
	
	decod2_4 decoder_high(
		.a2(a2),
		.a0(a0),
		.a1(a1),
		.d0(d4),
		.d1(d5),
		.d2(d6),
		.d3(d7)
	);
	
    /*
	 wire not_a0, not_a1, not_a2;

    not (not_a0, a0);
    not (not_a1, a1);
    not (not_a2, a2);

    and (d0, not_a0, not_a1, not_a2);
    and (d1, a0, not_a1, not_a2);
    and (d2, not_a0, a1, not_a2);
    and (d3, a0, a1, not_a2);
    and (d4, not_a0, not_a1, a2);
    and (d5, a0, not_a1, a2);
    and (d6, not_a0, a1, a2);
    and (d7, a0, a1, a2);
	 */

endmodule

module decod2_4( input a0, a1, a2, output d0, d1, d2, d3); // a2 funciona como enable

	assign d0 = a2 & ~a0 & ~a1;
	assign d1 = a2 & a0 & ~a1;
	assign d2 = a2 & ~a0 & a1;
	assign d3 = a2 & a0 & a1;
	
endmodule
