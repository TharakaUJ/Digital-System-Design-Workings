`timescale 1ps/1ps

module cla_adder (
    input logic [7:0] A,
    input logic [7:0] B,
    input logic cin,
    output logic [7:0] sum,
    output logic cout
);

    logic [7:0] P;
    logic [7:0] G;
    logic [8:0] C;

    assign P = A ^ B; // Propagate
    assign G = A & B; // Generate

    assign C[0] = cin;
    assign cout = C[8];
 

    genvar i;
    generate
        for (i = 1; i<9; i++) begin
            assign C[i] = G[i-1] | (P[i-1] & C[i-1]);
            assign sum[i-1] = P[i-1] ^ C[i-1];
        end
    endgenerate

endmodule