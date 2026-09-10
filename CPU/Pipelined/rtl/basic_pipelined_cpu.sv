`timescale 1ns/1ps

module cpu (
  input  logic        clk, reset,
  output logic [7 :0] imem_addr,  dmem_addr,
  input  logic [15:0] imem_rdata, dmem_rdata,
  output logic [15:0] dmem_wdata,
  output logic        dmem_wen
);
  logic [7:0] pc, addr;
  enum logic [3:0] {LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ} opcode;

  typedef struct packed {
    logic valid;
    logic [7:0] pc_count;
    logic [15:0] instruction;
  } fetch_reg_t;

  typedef struct packed {
    logic valid;
    logic [7:0] pc_count;
    logic [3:0] opcode;
    logic [7:0] addr;
    logic [3:0] i_rs1, i_rs2, i_rd, i_reg;

  } decode_reg_t;

  typedef struct packed {
    logic valid;
    logic [7:0] pc_count;
    logic [3:0] opcode;
    logic [7:0] addr;
  } execute_reg_t;


  fetch_reg_t fetch_reg;
  decode_reg_t decode_reg;
  execute_reg_t execute_reg;

  always_ff @(posedge clk) begin
    if (reset) begin
      pc   <= '0;
      foreach (regs[i]) begin
        regs[i] <= '0;
      end

      fetch_reg <= '{valid: 1'b0, pc_count: '0, instruction: '0};
      decode_reg <= '{valid: 1'b0, pc_count: '0, opcode: '0, addr: '0};

    end else begin
      if (!fetch_reg.valid) begin
        fetch_reg <= '{valid: 1'b1, pc_count: pc, instruction: imem_rdata};
      end

      if (fetch_reg.valid) begin
        decode_reg <= '{valid: 1'b1, pc_count: fetch_reg.pc_count, opcode: fetch_reg.instruction[15:12], addr: fetch_reg.instruction[7:0]};
        fetch_reg.valid <= 1'b0;
      end
    end
  end

  // always_comb begin
  //   imem_addr = pc;
  //   {addr        , i_reg, opcode} = imem_rdata;
  //   {i_rs2, i_rs1, i_rd , opcode} = imem_rdata;

  //   dmem_addr  = addr;
  //   dmem_wdata = regs[i_reg];
  //   dmem_wen   = !reset && opcode == STORE;

  //   reg_1      = regs[i_rs1];
  //   reg_2      = regs[i_rs2];
  // end

  always_ff @(posedge clk)
    if (reset) begin
      pc   <= '0;
      foreach (regs[i]) begin
        regs[i] <= '0;
      end
    end else begin
      pc   <= pc + 1'b1;

      case (opcode)
        LOAD: regs[i_reg] <= dmem_rdata;
        MOVE: regs[i_rd ] <= reg_1;
        ADD : regs[i_rd ] <= reg_1 + reg_2;
        SUB : regs[i_rd ] <= reg_1 - reg_2;
        MUL : regs[i_rd ] <= reg_1 * reg_2;
        JNZ : if (regs[i_reg] != '0) pc <= addr;
        default: ;
      endcase
    end

endmodule