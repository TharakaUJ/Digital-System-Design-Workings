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

    logic sign_A, sign_B;
    logic [EXP-1:0] exp_A, exp_B;
    logic [MANT:0] mant_A, mant_B;

    logic sign_res;
    logic [EXP-1:0] exp_res;
    logic [MANT+1:0] mant_res;

    logic [EXP-1:0] shift;
    logic [MANT:0] shifted_mant;

    always_comb begin : fp_logic
        sign_A = A[MANT+EXP];
        sign_B = B[MANT+EXP];
        exp_A  = A[MANT+EXP-1 : MANT];
        exp_B  = B[MANT+EXP-1 : MANT];

        mant_A = {1'b1, A[MANT-1:0]};
        mant_B = {1'b1, B[MANT-1:0]};

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

        if (mant_res[MANT+1]) begin
            mant_res = mant_res >> 1;
            exp_res  = exp_res + 1;
        end

        sum = {sign_res, exp_res, mant_res[MANT-1:0]};
    end

endmodule