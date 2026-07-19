`timescale 1ps/1ps

module tb_N_bit_adder_casecade;

    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] sum;
    logic         cout;

    cascading_adder dut (
        .A(A),
        .B(B),
        .sum(sum),
        .cout(cout)
    );

    initial begin

        $dumpfile("./build/32bit_adder_casecade.vcd"); $dumpvars(0, tb_N_bit_adder_casecade);

        // Test case 1
        A = 32'b00000001;
        B = 32'b00000001;
        #10;
        assert(sum == 32'b00000010 && cout == 1'b0) else $fatal(1);

        // Test case 2
        A = 32'b1111111111111111;
        B = 32'b00000001;
        #10;
        assert(sum == 32'b10000000000000000 && cout == 1'b0) else $fatal(1);

        // Test case 3
        A = 32'b10101010;
        B = 32'b01010101;
        #10;
        assert(sum == 32'b11111111 && cout == 1'b0) else $fatal(1);
    end

endmodule