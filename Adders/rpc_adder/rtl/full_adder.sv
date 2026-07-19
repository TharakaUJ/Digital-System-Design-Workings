`timescale 1ps/1ps

module full_adder (
    input logic A,
    input logic B,
    input logic cin,
    output logic sum,
    output logic cout
);

    assign sum = A ^ B ^ cin;
    assign cout = (A & B) | (cin & (A^B));

endmodule