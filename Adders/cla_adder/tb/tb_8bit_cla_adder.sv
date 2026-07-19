`timescale 1ps/1ps

module tb_cla_adder;
    logic [7:0] A;
    logic [7:0] B;
    logic cin;
    logic [7:0]sum;
    logic cout;

    cla_adder dut(
        .A(A),
        .B(B),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );


    initial begin

        $dumpfile("./build/8bit_cla_adder.vcd"); $dumpvars(0, tb_cla_adder);

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