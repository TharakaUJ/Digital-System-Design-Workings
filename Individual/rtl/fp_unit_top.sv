module fp_unit_top (
    input  logic        clk,
    input  logic        rst,

    input  logic        start,
    input  logic [1:0]  operation,

    input  logic [31:0] a,
    input  logic [31:0] b,

    output logic [31:0] result,
    output logic        valid,
    output logic        busy
);

endmodule