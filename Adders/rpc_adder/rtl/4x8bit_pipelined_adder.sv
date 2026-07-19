`timescale 1ps/1ps

module pipelined_cascading_adder (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] sum,
    output logic        cout
);


    logic [7:0] sum1_comb;
    logic       cout1_comb;

    N_bit_adder #(.N(8)) adder_1 (
        .A(A[7:0]), .B(B[7:0]), .cin(1'b0), .sum(sum1_comb), .cout(cout1_comb)
    );

    logic [7:0]  s1_reg1; 
    logic        c1_reg1;
    logic [23:0] A_stage2, B_stage2;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            s1_reg1  <= '0;
            c1_reg1  <= '0;
            A_stage2 <= '0;
            B_stage2 <= '0;
        end else begin
            s1_reg1  <= sum1_comb;
            c1_reg1  <= cout1_comb;
            A_stage2 <= A[31:8];
            B_stage2 <= B[31:8];
        end
    end


    logic [7:0] sum2_comb;
    logic       cout2_comb;

    N_bit_adder #(.N(8)) adder_2 (
        .A(A_stage2[7:0]), .B(B_stage2[7:0]), .cin(c1_reg1), .sum(sum2_comb), .cout(cout2_comb)
    );

    logic [7:0]  s1_reg2;        
    logic [7:0]  s2_reg1;       
    logic        c2_reg1;
    logic [15:0] A_stage3, B_stage3;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            s1_reg2  <= '0;
            s2_reg1  <= '0;
            c2_reg1  <= '0;
            A_stage3 <= '0;
            B_stage3 <= '0;
        end else begin
            s1_reg2  <= s1_reg1;
            s2_reg1  <= sum2_comb;
            c2_reg1  <= cout2_comb;
            A_stage3 <= A_stage2[23:8];
            B_stage3 <= B_stage2[23:8];
        end
    end


    logic [7:0] sum3_comb;
    logic       cout3_comb;

    N_bit_adder #(.N(8)) adder_3 (
        .A(A_stage3[7:0]), .B(B_stage3[7:0]), .cin(c2_reg1), .sum(sum3_comb), .cout(cout3_comb)
    );

    logic [7:0] s1_reg3;         
    logic [7:0] s2_reg2;         
    logic [7:0] s3_reg1;         
    logic       c3_reg1;
    logic [7:0] A_stage4, B_stage4;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            s1_reg3  <= '0;
            s2_reg2  <= '0;
            s3_reg1  <= '0;
            c3_reg1  <= '0;
            A_stage4 <= '0;
            B_stage4 <= '0;
        end else begin
            s1_reg3  <= s1_reg2;
            s2_reg2  <= s2_reg1;
            s3_reg1  <= sum3_comb;
            c3_reg1  <= cout3_comb;
            A_stage4 <= A_stage3[15:8];
            B_stage4 <= B_stage3[15:8];
        end
    end


    logic [7:0] sum4_comb;
    logic       cout4_comb;

    N_bit_adder #(.N(8)) adder_4 (
        .A(A_stage4), .B(B_stage4), .cin(c3_reg1), .sum(sum4_comb), .cout(cout4_comb)
    );


    assign sum  = {sum4_comb, s3_reg1, s2_reg2, s1_reg3};
    assign cout = cout4_comb;

endmodule