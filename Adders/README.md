# Assignment 1

## Exercise 2
 - 32 bit adder using 4 x 8 bit adders (cascading). Estimate the total time required to add 4 pairs.
 - 32 bit adder using 4 x 8 bit adders using pipelining

My implementation of the above exercises can be found in the `rpc_adder` folder. The `rpc_adder/rtl` folder contains the following files:
    - `full_adder.sv` - 1 bit full adder
    - `N-bit_adder_cascading.sv` - N bit adder using N 1 bit full adders
    - `4x8bit_pipelined_adder.sv` - 32 bit adder using 4 x 8 bit adders with pipelining
    - `4x8bit_cascading_adder.sv` - 32 bit adder using 4 x 8 bit adders (cascading)

## Exercise 3
 - 32 bit carry lookahead adder using 4 x 8 bit CLAs.
 - Compare performance of this with the adder in Ex2 (cascade)

 My implementation of the above exercises can be found in the `cla_adder` folder. The `cla_adder/rtl` folder contains the following files:
    - `8bit_cla.sv` - 8 bit carry lookahead adder
    - `4x8bit_cla.sv` - 32 bit carry lookahead adder using 4 x 8 bit CLAs

### Comparison of performance between the 32 bit adder using 4 x 8 bit adders (cascading) and the 32 bit carry lookahead adder using 4 x 8 bit CLAs 


## Exercise 4
 - floating point adder/subtractor for IEEE 754 single precision format

 My implementation of the above exercise can be found in the `fp_adder` folder. The `fp_adder/rtl` folder contains the following files:
    - `fp_adder.sv` - floating point adder/subtractor for IEEE 754 single precision format



