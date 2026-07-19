`timescale 1ps/1ps

module tb_4x8bit_cla_adder;
    logic [31:0] A;
    logic [31:0] B;
    logic cin;
    logic [31:0] sum;
    logic cout;

    cascade_cla_adder dut(
        .A(A),
        .B(B),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );


    initial begin

        $dumpfile("./build/4x8bit_cla_adder.vcd"); $dumpvars(0, tb_4x8bit_cla_adder);

        // Test case 1
        A = 32'b00000000000000000000000000000001;
        B = 32'b0000000000000000000000000000001;
        cin = 1'b0;
        #10;
        assert(sum == 32'b00000000000000000000000000000010 && cout == 1'b0) else $fatal(1);

        // Test case 2
        A = 32'b11111111;
        B = 32'b00000001;
        cin = 1'b0;
        #10;
        assert(sum == 32'b100000000 && cout == 1'b0) else $fatal(1);

        // Test case 3
        A = 32'b10101010;
        B = 32'b01010101;
        cin = 1'b0;
        #10;
        assert(sum == 32'b11111111 && cout == 1'b0) else $fatal(1);
    end

endmodule