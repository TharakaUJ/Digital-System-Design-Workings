`timescale 1ps/1ps

module cascade_cla_adder(
    input logic [31:0] A,
    input logic [31:0] B,
    input logic cin,
    output logic [31:0] sum,
    output logic cout
);

    logic [3:0] c_array;
    assign cout = c_array[3];

    cla_adder adder_1 (
        .A(A[7:0]),
        .B(B[7:0]),
        .cin(cin),
        .sum(sum[7:0]),
        .cout(c_array[0])
    );

    genvar i;
    generate
        for (i = 1; i < 4; i++) begin : adder_gen
            cla_adder adder_i (
                .A(A[8*i +: 8]),
                .B(B[8*i +: 8]),
                .cin(c_array[i-1]),
                .sum(sum[8*i +: 8]),
                .cout(c_array[i])
            );
        end
    endgenerate
endmodule

