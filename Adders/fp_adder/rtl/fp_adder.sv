`timescale 1ps/1ps

module fp_adder # (
    parameter MANT = 23,
    parameter EXP = 8
)(
    input logic [MANT+EXP:0] A,
    input logic [MANT+EXP:0] B,
    input logic addition,
    output logic [MANT+EXP:0] sum
);

    wire wire_sign_A = A[MANT+EXP];
    wire wire_sign_B = B[MANT+EXP];
    wire [EXP-1:0] wire_exp_A  = A[MANT+EXP-1 : MANT];
    wire [EXP-1:0] wire_exp_B  = B[MANT+EXP-1 : MANT];
    wire [MANT:0]  wire_mant_A = {1'b1, A[MANT-1:0]};
    wire [MANT:0]  wire_mant_B = {1'b1, B[MANT-1:0]};

    logic sign_A, sign_B;
    logic [EXP-1:0] exp_A, exp_B;
    logic [MANT:0] mant_A, mant_B;

    logic sign_res;
    logic [EXP-1:0] exp_res;
    logic [MANT+1:0] mant_res;

    logic [EXP-1:0] shift;
    logic [MANT:0] shifted_mant;
    
    logic [MANT+1:0] norm_mant_res;
    logic is_overflow;
    
    assign is_overflow = mant_res[MANT+1]; 
    assign norm_mant_res = is_overflow ? (mant_res >> 1) : mant_res;
    assign sum = {sign_res, exp_res, norm_mant_res[MANT-1:0]};

    always_comb begin : fp_logic
        sign_A = wire_sign_A;
        sign_B = wire_sign_B;
        exp_A  = wire_exp_A;
        exp_B  = wire_exp_B;
        mant_A = wire_mant_A;
        mant_B = wire_mant_B;

        if (exp_A > exp_B) begin
            shift = exp_A - exp_B;
            shifted_mant = (shift > MANT) ? '0 : (mant_B >> shift); 
            exp_res  = exp_A;
            sign_res = sign_A;

            if (addition)
                mant_res = mant_A + shifted_mant;
            else
                mant_res = mant_A - shifted_mant;
        end 
        else begin
            shift = exp_B - exp_A;
            shifted_mant = (shift > MANT) ? '0 : (mant_A >> shift);
            exp_res  = exp_B;
            sign_res = sign_B;

            if (addition)
                mant_res = mant_B + shifted_mant;
            else
                mant_res = mant_B - shifted_mant;
        end

        if (is_overflow) begin
            exp_res  = exp_res + 1;
        end
    end

endmodule
