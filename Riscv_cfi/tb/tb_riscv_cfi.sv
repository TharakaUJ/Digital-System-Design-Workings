`timescale 1ns/1ps

module tb_riscv_cfi_fsm;

    logic        clk;
    logic        rst_n;
    logic [31:0] packet;
    logic        error;

    riscv_cfi_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .packet(packet),
        .error(error)
    );

    // 100MHz Clock Generation
    always #5 clk = ~clk;

    task send_packet(input logic [7:0] cmd, input logic [23:0] data);
        packet = {cmd, data};
        @(posedge clk);
    endtask

    initial begin
        $dumpfile("./build/dump.vcd");
        $dumpvars(0, tb_riscv_cfi_fsm);

        // Initialize
        clk    = 0;
        rst_n  = 0;
        packet = 0;

        #15 rst_n = 1;
        $display("[%0t ns] --- Starting CFI FSM Test ---", $time);

        $display("[%0t ns] TEST 1: Valid Control Flow", $time);
        send_packet(8'h01, 24'hABCDEF); // SET label = 0xABCDEF
        send_packet(8'h02, 24'h000000); // JUMP
        send_packet(8'h03, 24'hABCDEF); // LPAD (matching label)

        #1;
        if (!error) $display("SUCCESS: Valid sequence passed without error.");
        else        $error("FAIL: False error flag on valid sequence!");


        $display("[%0t ns] TEST 2: Label Mismatch", $time);
        send_packet(8'h01, 24'h123456); // SET label = 0x123456
        send_packet(8'h02, 24'h000000); // JUMP
        send_packet(8'h03, 24'h999999); // LPAD (WRONG label!)

        #1;
        if (error)  $display("SUCCESS: Error correctly flagged on label mismatch.");
        else        $error("FAIL: Error NOT flagged on label mismatch!");

        $display("[%0t ns] TEST 3: Recovery via Reset & Missing LPAD", $time);
        rst_n = 0; #10; rst_n = 1; @(posedge clk); // Clear error state

        send_packet(8'h01, 24'h555555); // SET label = 0x555555
        send_packet(8'h02, 24'h000000); // JUMP
        send_packet(8'h01, 24'h000000); // SET sent instead of LPAD!

        #1;
        if (error)  $display("SUCCESS: Error correctly flagged on illegal instruction after JUMP.");
        else        $error("FAIL: Error NOT flagged when LPAD was omitted!");

        $display("[%0t ns] --- Test Bench Completed ---", $time);
        $finish;
    end

endmodule