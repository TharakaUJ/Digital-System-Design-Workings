`timescale 1ns/1ps

module tb_cpu;

  typedef enum logic [3:0] {
    LOAD,
    STORE,
    MOVE,
    ADD,
    SUB,
    MUL,
    JNZ
  } op_t;

  logic clk = 0, reset = 1;

  logic [7:0]  imem_addr, dmem_addr;
  logic [15:0] imem_rdata, dmem_rdata;
  logic [15:0] dmem_wdata;
  logic        dmem_wen;

  cpu dut(.*);

  memory imem(
    clk,
    imem_addr,
    '0,
    1'b0,
    imem_rdata
  );

  memory dmem(
    clk,
    dmem_addr,
    dmem_wdata,
    dmem_wen,
    dmem_rdata
  );

  initial forever #5 clk = ~clk;

  localparam [15:0] NOP = {4'hF, 4'hF, 4'hF, ADD};

  initial begin

    $dumpfile("wave.vcd");
    $dumpvars(0, tb_cpu);

    // ============================================================
    // DATA MEMORY
    // ============================================================

    dmem.mem[0] = 16'd10;
    dmem.mem[1] = 16'd20;
    dmem.mem[2] = 16'd30;
    dmem.mem[3] = 16'd40;


    // ============================================================
    // INSTRUCTION MEMORY
    // ============================================================

    // Fill IMEM with NOPs so the pipeline drains cleanly after the program
    for (int i = 0; i < 256; i++) begin
      imem.mem[i] = NOP;
    end

    // Program is packed back-to-back (no NOP padding), so every
    // dependency below relies on forwarding.

    // 0: r1 = mem[0] = 10
    imem.mem[0] = {8'h00, 4'h1, LOAD};

    // 1: r2 = mem[1] = 20
    imem.mem[1] = {8'h01, 4'h2, LOAD};

    // 2: r3 = r1                (r1 forwarded from MEM: load data)
    imem.mem[2] = {4'h1, 4'h0, 4'h3, MOVE};

    // 3: r4 = r2 + r1           (r2 from MEM: load data, r1 from WB)
    imem.mem[3] = {4'h2, 4'h1, 4'h4, ADD};

    // 4: r5 = r2 - r1           (r2 from WB)
    imem.mem[4] = {4'h2, 4'h1, 4'h5, SUB};

    // 5: r6 = r1 * r2
    imem.mem[5] = {4'h1, 4'h2, 4'h6, MUL};

    // 6: mem[2] = r6            (r6 forwarded from EX)
    imem.mem[6] = {8'h02, 4'h6, STORE};

    // 7: if r1 != 0, jump to PC 9
    imem.mem[7] = {8'd9, 4'h1, JNZ};

    // 8: should be skipped if JNZ works.  r7 = mem[3] = 40
    imem.mem[8] = {8'h03, 4'h7, LOAD};

    // 9: jump target.  r7 = mem[2] = 200 (updated by STORE)
    imem.mem[9] = {8'h02, 4'h7, LOAD};

    // ------------------------------------------------------------
    // LOAD-USE cases: consumer directly follows the LOAD, so the
    // data is not available yet and the CPU must stall one cycle.
    // ------------------------------------------------------------

    // 10: r8 = r7 + r7 = 400    (LOAD -> ALU, both operands)
    imem.mem[10] = {4'h7, 4'h7, 4'h8, ADD};

    // 11: r9 = mem[1] = 20
    imem.mem[11] = {8'h01, 4'h9, LOAD};

    // 12: mem[4] = r9 = 20      (LOAD -> STORE)
    imem.mem[12] = {8'h04, 4'h9, STORE};

    // 13: r10 = mem[0] = 10
    imem.mem[13] = {8'h00, 4'hA, LOAD};

    // 14: if r10 != 0, jump to 16   (LOAD -> JNZ)
    imem.mem[14] = {8'd16, 4'hA, JNZ};

    // 15: should be skipped.  r11 = mem[3] = 40
    imem.mem[15] = {8'h03, 4'hB, LOAD};

    // 16 onwards: NOPs


    // ============================================================
    // RELEASE RESET
    // ============================================================

    @(posedge clk);
    #1ps;
    reset = 0;

    // ============================================================
    // RUN
    // ============================================================

    repeat (30)
      @(posedge clk);

    #1ps;

    // ============================================================
    // CHECK RESULTS
    // ============================================================

    $display("");
    $display("========================================");
    $display("             CPU RESULTS");
    $display("========================================");

    $display("r1 = %04h", dut.regs[1]);
    $display("r2 = %04h", dut.regs[2]);
    $display("r3 = %04h", dut.regs[3]);
    $display("r4 = %04h", dut.regs[4]);
    $display("r5 = %04h", dut.regs[5]);
    $display("r6 = %04h", dut.regs[6]);
    $display("r7 = %04h", dut.regs[7]);
    $display("mem[2] = %04h", dmem.mem[2]);

    $display("");

    // ============================================================
    // INDIVIDUAL TESTS
    // ============================================================

    // LOAD
    assert (dut.regs[1] == 16'd10)
      $display("PASS: LOAD");
    else
      $display("FAIL: LOAD");

    // LOAD
    assert (dut.regs[2] == 16'd20)
      $display("PASS: LOAD 2");
    else
      $display("FAIL: LOAD 2");

    // MOVE
    assert (dut.regs[3] == 16'd10)
      $display("PASS: MOVE");
    else
      $display("FAIL: MOVE");

    // ADD
    assert (dut.regs[4] == 16'd30)
      $display("PASS: ADD");
    else
      $display("FAIL: ADD");

    // SUB
    assert (dut.regs[5] == 16'd10)
      $display("PASS: SUB");
    else
      $display("FAIL: SUB");

    // MUL
    assert (dut.regs[6] == 16'd200)
      $display("PASS: MUL");
    else
      $display("FAIL: MUL");

    // STORE
    assert (dmem.mem[2] == 16'd200)
      $display("PASS: STORE");
    else
      $display("FAIL: STORE");

    // JNZ
    assert (dut.regs[7] == 16'd200)
      $display("PASS: JNZ");
    else
      $display("FAIL: JNZ");

    // LOAD -> ALU
    assert (dut.regs[8] == 16'd400)
      $display("PASS: LOAD-USE ALU");
    else
      $display("FAIL: LOAD-USE ALU (r8 = %0d, expected 400)", dut.regs[8]);

    // LOAD -> STORE
    assert (dut.regs[9] == 16'd20 && dmem.mem[4] == 16'd20)
      $display("PASS: LOAD-USE STORE");
    else
      $display("FAIL: LOAD-USE STORE (mem[4] = %0d, expected 20)", dmem.mem[4]);

    // LOAD -> JNZ (r11 must stay 0 because the LOAD at 15 is skipped)
    assert (dut.regs[10] == 16'd10 && dut.regs[11] == 16'd0)
      $display("PASS: LOAD-USE JNZ");
    else
      $display("FAIL: LOAD-USE JNZ (r11 = %0d, expected 0)", dut.regs[11]);

    $display("");
    $display("========================================");
    $display("             TEST COMPLETE");
    $display("========================================");

    $finish;

  end

endmodule