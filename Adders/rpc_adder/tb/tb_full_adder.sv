`timescale 1ps/1ps

module tb_full_adder;


    logic A;
    logic B;
    logic cin;
    logic sum;
    logic cout;

    full_adder #(
    ) dut (
        .A(A),
        .B(B),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        // Test case 1
        A = 1'b1;
        B = 1'b1;
        cin = 1'b0;
        #10;
        assert(sum == 1'b0 && cout == 1'b1) else $fatal(1);

        // Test case 2
        A = 1'b1;
        B = 1'b1;
        cin = 1'b1;
        #10;
        assert(sum == 1'b1 && cout == 1'b1) else $fatal(1);

        // Test case 3
        A = 1'b0;
        B = 1'b1;
        cin = 1'b1;
        #10;
        assert(sum == 1'b0 && cout == 1'b1) else $fatal(1);
    end

endmodule