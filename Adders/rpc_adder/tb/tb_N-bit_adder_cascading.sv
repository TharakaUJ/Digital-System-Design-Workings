`timescale 1ps/1ps

module tb_N_bit_adder_casecade;

    parameter N = 8;

    logic [N-1:0] A;
    logic [N-1:0] B;
    logic         cin;
    logic [N-1:0] sum;
    logic         cout;

    N_bit_adder #(
        .N(N)
    ) dut (
        .A(A),
        .B(B),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin

        $dumpfile("./build/N-bit_adder_cascading.vcd"); $dumpvars(0, tb_N_bit_adder_casecade);

        // Test case 1
        A = 8'b00000001;
        B = 8'b00000001;
        cin = 1'b0;
        #10;
        assert(sum == 8'b00000010 && cout == 1'b0) else $fatal(1);

        // Test case 2
        A = 8'b11111111;
        B = 8'b00000001;
        cin = 1'b0;
        #10;
        assert(sum == 8'b00000000 && cout == 1'b1) else $fatal(1);

        // Test case 3
        A = 8'b10101010;
        B = 8'b01010101;
        cin = 1'b0;
        #10;
        assert(sum == 8'b11111111 && cout == 1'b0) else $fatal(1);
    end

endmodule