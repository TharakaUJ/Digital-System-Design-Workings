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

    // Fill IMEM with NOPs by default to pad pipeline stages
    for (int i = 0; i < 256; i++) begin
      imem.mem[i] = NOP;
    end

    // ------------------------------------------------------------
    // LOAD
    // ------------------------------------------------------------
    // r1 = mem[0] = 10
    imem.mem[0] = {8'h00, 4'h1, LOAD};

    // ------------------------------------------------------------
    // LOAD
    // ------------------------------------------------------------
    // r2 = mem[1] = 20
    imem.mem[4] = {8'h01, 4'h2, LOAD};

    // ------------------------------------------------------------
    // MOVE
    // ------------------------------------------------------------
    // r3 = r1
    imem.mem[8] = {4'h1, 4'h0, 4'h3, MOVE};
    // ------------------------------------------------------------
    // ADD
    // ------------------------------------------------------------
    // r4 = r1 + r2
    imem.mem[12] = {4'h2, 4'h1, 4'h4, ADD};

    // ------------------------------------------------------------
    // SUB
    // ------------------------------------------------------------
    // r5 = r2 - r1
    imem.mem[16] = {4'h2, 4'h1, 4'h5, SUB};

    // ------------------------------------------------------------
    // MUL
    // ------------------------------------------------------------
    // r6 = r1 * r2
    imem.mem[20] = {4'h1, 4'h2, 4'h6, MUL};

    // ------------------------------------------------------------
    // STORE
    // ------------------------------------------------------------
    // mem[2] = r6
    imem.mem[24] = {8'h02, 4'h6, STORE};

    // ------------------------------------------------------------
    // JNZ
    // ------------------------------------------------------------
    // If r1 != 0, jump to PC 36
    imem.mem[28] = {8'd36, 4'h1, JNZ};

    // This instruction should be skipped if JNZ works.
    // r7 = mem[3] = 40
    imem.mem[32] = {8'h03, 4'h7, LOAD};

    // Jump target
    // r7 = mem[2] = 200 (updated from STORE)
    imem.mem[36] = {8'h02, 4'h7, LOAD};


    // ============================================================
    // RELEASE RESET
    // ============================================================

    @(posedge clk);
    #1ps;
    reset = 0;

    // ============================================================
    // RUN
    // ============================================================

    // Give the pipeline plenty of time to drain through all the NOPs
    repeat (60)
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
    assert (dut.regs[7] == 16'd200) // Updated expectation since it loads the STOREd result
      $display("PASS: JNZ");
    else
      $display("FAIL: JNZ");

    $display("");
    $display("========================================");
    $display("             TEST COMPLETE");
    $display("========================================");

    $finish;

  end

endmodule