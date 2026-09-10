`timescale 1ps/1ps

module behave_adder (
    parameter DATA_W = 32
) # (
    logic input [DATA_W-1: 0] A,
    logic input [DATA_W-1: 0] B,
    logic output [DATA_W-1: 0] sum
);

sum = A + B;
    
endmodule