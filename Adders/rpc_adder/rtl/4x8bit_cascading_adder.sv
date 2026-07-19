`timescale 1ps/1ps

module cascading_adder (
    input logic [31:0] A,
    input logic [31:0] B,
    output logic [31:0] sum,
    output logic cout
);

    logic [3:0] c_array;
    assign cout = c_array[3];

    N_bit_adder #(
        .N(8)
    ) adder_1 (
        .A(A[7:0]),
        .B(B[7:0]),
        .cin(1'b0),
        .sum(sum[7:0]),
        .cout(c_array[0])
    );

    genvar i;
    generate
        for (i = 1; i < 4; i++) begin
        N_bit_adder #(
            .N(8)
        ) adder_i (
            .A(A[(8*i)+7:(8*i)]),
            .B(B[(8*i)+7:(8*i)]),
            .cin(c_array[i-1]),
            .sum(sum[(8*i)+7:(8*i)]),
            .cout(c_array[i])
        );
        end
    endgenerate




endmodule