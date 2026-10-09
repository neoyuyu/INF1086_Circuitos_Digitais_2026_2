// Gabriel Tafarel
// Sayid Safa
// Conversor BCD - Resulta no output de UM!!! segmento
module conversor_bcd(
    input  [3:0] a,
    output       segA,
    output       segB,
    output       segC,
    output       segD,
    output       segE,
    output       segF,
    output       segG
);

	//POS E SOP de cada segmento utilizada do lab6(Usado IA para normalizar entradas) 

    assign segA = (~a[3] & ~a[2] & ~a[1] &  a[0])
                | (~a[3] &  a[2] & ~a[1] & ~a[0])
                | ( a[3] & ~a[2] &  a[1] &  a[0])
                | ( a[3] &  a[2] & ~a[1] &  a[0]);

    assign segB = ( a[3] &  a[2] &  a[1])
                | ( a[3] &  a[2] & ~a[0])
                | (~a[3] &  a[2] & ~a[1] &  a[0])
                | (~a[3] &  a[2] &  a[1] & ~a[0])
                | ( a[3] & ~a[2] &  a[1] &  a[0]);

    assign segC = (~a[3] & ~a[2] &  a[1] & ~a[0])
                | ( a[3] &  a[2] & ~a[1] & ~a[0])
                | ( a[3] &  a[2] &  a[1] & ~a[0])
                | ( a[3] &  a[2] &  a[1] &  a[0]);
					 
    assign segD = ( a[2] &  a[1] &  a[0])
                | (~a[3] & ~a[2] & ~a[1] &  a[0])
                | (~a[3] &  a[2] & ~a[1] & ~a[0])
                | ( a[3] & ~a[2] &  a[1] & ~a[0]);

    assign segE = (~a[3] &  a[0])
                | (~a[3] &  a[2] & ~a[1])
                | (~a[2] & ~a[1] &  a[0]);

    assign segF = ( a[3] &  a[2] & ~a[1] &  a[0])
                | (~a[3] & ~a[2] &  a[0])
                | (~a[3] &  a[1] &  a[0])
                | (~a[3] & ~a[2] &  a[1]);

    assign segG = (~a[3] & ~a[2] & ~a[1])
                | (~a[3] &  a[2] &  a[1] &  a[0])
                | ( a[3] &  a[2] & ~a[1] & ~a[0]);

endmodule