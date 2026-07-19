`timescale 1ps / 1ps

module N_bit_adder #(
    parameter N = 8
)(
    input  logic [N-1:0] A,
    input  logic [N-1:0] B,
    input  logic        cin,
    output logic [N-1:0] sum,
    output logic         cout
);

    logic [N-1:0] carry;

    assign cout = carry[N-1];

    full_adder full_adder_1 (
        .A(A[0]),
        .B(B[0]),
        .cin(cin),
        .sum(sum[0]),
        .cout(carry[0])
    );

    genvar i;
    generate
        for (i = 1; i < N; i++) begin : gen_full_adder
            full_adder full_adder_i (
                .A(A[i]),
                .B(B[i]),
                .cin(carry[i-1]),
                .sum(sum[i]),
                .cout(carry[i])
            );
        end
    endgenerate

endmodule