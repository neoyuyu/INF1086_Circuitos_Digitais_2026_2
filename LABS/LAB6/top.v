// top level LAB 6
// Gabriel Tafarel
// Sayid Safa 07/10/2026
module top(
    input  [3:0] a,     
    input  [3:0] b,        
    input  [1:0] opsel,    
    output       flagn,    
    output       flagz,  
    output       segA,
    output       segB,
    output       segC,
    output       segD,
    output       segE,
    output       segF,
    output       segG
);

    wire [3:0] res;        // fio para result da ula

    ulaest ULA1(
      .a(a),
      .b(b),
      .opsel(opsel),
      .s(res),
      .flagn(flagn),
      .flagz(flagz)
    );

    seg_a SA1(
        .A(res[3]),
        .B(res[2]),
        .C(res[1]),
        .D(res[0]),
        .Y(segA)
    );

    seg_c SC1(
        .E(res),
        .S(segC)
    );

    seg_D SD1(
        .C(res),
        .D(segD)
    );

    seg_E SE1(
        .in(res),
        .segE(segE)
    );

    seg_f SF1(
        .E(res),
        .S(segF)
    );
	 
	 seg_b SB1(
    .E(res),
    .S(segB)
);

    seg_g SG1(
        .E(res),
        .S(segG)
    );

endmodule