`timescale 1ps/1ps

module tb_fp_adder;

    parameter MANT = 23;
    parameter EXP = 8;

    logic [31:0] A;
    logic [31:0] B;
    logic addition;
    logic [31:0] sum;

    fp_adder #(
        .MANT(MANT),
        .EXP(EXP)
    ) dut (
        .A(A),
        .B(B),
        .addition(addition),
        .sum(sum)
    );

    initial begin
        // Test case 1: Simple addition
        A = 32'h3F800000; // 1.0
        B = 32'h40000000; // 2.0
        addition = 1'b1;
        #10;
        $display("Test case 1: A = %h, B = %h, sum = %h", A, B, sum);

        // Test case 2: Simple subtraction
        A = 32'h40000000; // 2.0
        B = 32'h3F800000; // 1.0
        addition = 1'b0;
        #10;
        $display("Test case 2: A = %h, B = %h, sum = %h", A, B, sum);

        // Add more test cases as needed

        $finish;
    end

endmodule