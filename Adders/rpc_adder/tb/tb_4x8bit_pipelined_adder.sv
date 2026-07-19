`timescale 1ns/1ps // Changed to ns for easier-to-read delay numbers

module tb_pipelined_cascading_adder;

    // 1. Interface Signals
    logic        clk;
    logic        rst;
    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] sum;
    logic        cout;

    // 2. Instantiate the Device Under Test (DUT)
    pipelined_cascading_adder dut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .sum(sum),
        .cout(cout)
    );

    // 3. Clock Generation (50MHz -> 20ns period)
    // Posedges will happen at 10ns, 30ns, 50ns, 70ns, etc.
    always begin
        clk = 0; #10;
        clk = 1; #10;
    end

    // 4. Stimulus and Manual Checking
    initial begin
        // Initialize inputs
        A = 32'h0;
        B = 32'h0;
        rst = 1;
        
        // Hold reset for 2 full cycles, then release
        #40; 
        rst = 0;

        $display("--- Starting Simple Pipeline Tests ---");

        // --- CYCLE 1 ---
        // Apply Test 1 inputs. Result will appear 3 clock cycles later.
        A = 32'h1111_1111; B = 32'h2222_2222; 
        #20;

        // --- CYCLE 2 ---
        // Apply Test 2 inputs.
        A = 32'h0000_00FF; B = 32'h0000_0001; 
        #20;

        // --- CYCLE 3 ---
        // Apply Test 3 inputs.
        A = 32'hFFFF_FFFF; B = 32'h0000_0001; 
        #20; 

        // --- CYCLE 4 ---
        // Test 1 should now be ready at the output! Check it.
        if (sum === 32'h3333_3333 && cout === 0) 
            $display("[PASS] Test 1: Sum = %h, Cout = %b", sum, cout);
        else 
            $display("[FAIL] Test 1: Got Sum = %h, Cout = %b (Expected 33333333, 0)", sum, cout);
        
        // Apply Test 4 inputs.
        A = 32'hA5A5_5A5A; B = 32'h5A5A_A5A5;
        #20;

        // --- CYCLE 5 ---
        // Test 2 is now ready at the output.
        if (sum === 32'h0000_0100 && cout === 0) 
            $display("[PASS] Test 2: Sum = %h, Cout = %b", sum, cout);
        else 
            $display("[FAIL] Test 2: Got Sum = %h, Cout = %b (Expected 00000100, 0)", sum, cout);
        
        #20;

        // --- CYCLE 6 ---
        // Test 3 (the overflow test) is now ready at the output.
        if (sum === 32'h0000_0000 && cout === 1) 
            $display("[PASS] Test 3: Sum = %h, Cout = %b", sum, cout);
        else 
            $display("[FAIL] Test 3: Got Sum = %h, Cout = %b (Expected 00000000, 1)", sum, cout);

        #20;

        // --- CYCLE 7 ---
        // Test 4 is now ready at the output.
        if (sum === 32'hFFFF_FFFF && cout === 0) 
            $display("[PASS] Test 4: Sum = %h, Cout = %b", sum, cout);
        else 
            $display("[FAIL] Test 4: Got Sum = %h, Cout = %b (Expected FFFFFFFF, 0)", sum, cout);

        #40;
        $display("--- All Tests Completed ---");
        $finish;
    end

    // 5. Waveform Dumping
    initial begin
        $dumpfile("./build/4x8bit_pipelined_adder.vcd");
        $dumpvars(0, tb_pipelined_cascading_adder);
    end

endmodule