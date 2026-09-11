`timescale 1ns/1ps

module cpu (
  input  logic        clk, reset,
  output logic [7 :0] imem_addr,  dmem_addr,
  input  logic [15:0] imem_rdata, dmem_rdata,
  output logic [15:0] dmem_wdata,
  output logic        dmem_wen
);
  logic [7:0] pc, addr;
  logic [15:0] regs [16];
  enum logic [3:0] {LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ} opcode;

  typedef struct packed {
    logic [7:0] addr;
    logic [3:0] ireg;
    logic [3:0] opcode;
  } instruction_type1_t;

  typedef struct packed {
    logic [3:0] i_rs1;
    logic [3:0] i_rs2;
    logic [3:0] i_rd;
    logic [3:0] opcode;
  } instruction_type2_t;

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
    logic [15:0] reg_1, reg_2;
  } decode_reg_t;

typedef struct packed {
    logic       valid;
    logic [7:0] pc_count;
    logic [3:0] opcode;
    logic [7:0] addr;
    logic [15:0] alu_result;
    logic [3:0]  i_rd;
  } execute_reg_t;

typedef struct packed {
    logic        valid;
    logic [7:0]  pc_count;
    logic [15:0] data;
    logic [3:0]  i_rd;
  } memory_reg_t;


  fetch_reg_t fetch_reg;
  decode_reg_t decode_reg;
  execute_reg_t execute_reg;
  memory_reg_t memory_reg;

  always_ff @(posedge clk) begin
    if (reset) begin
      pc   <= '0;
      foreach (regs[i]) begin
        regs[i] <= '0;
      end

      fetch_reg <= '{valid: 1'b0, pc_count: '0, instruction: '0};
      decode_reg <= '{valid: 1'b0, pc_count: '0, opcode: '0, addr: '0};
      execute_reg <= '{valid: 1'b0, pc_count: '0, opcode: '0, addr: '0, alu_result: '0};
      memory_reg <= '{valid: 1'b0, pc_count: '0, data: '0};

    end else begin
      if (!fetch_reg.valid) begin
        fetch_reg <= '{valid: 1'b1, pc_count: pc, instruction: imem_rdata};
        fetch_reg.valid <= 1'b1;
        pc <= pc + 1;
      end

      if (fetch_reg.valid) begin

        instruction_type1_t inst1;
        instruction_type2_t inst2;

        inst1 = instruction_type1_t'(fetch_reg.instruction);
        inst2 = instruction_type2_t'(fetch_reg.instruction);

        decode_reg <= '{valid: 1'b1, pc_count: fetch_reg.pc_count, opcode: inst1.opcode, addr: inst1.addr, i_rs1: inst2.i_rs1, i_rs2: inst2.i_rs2, i_rd: inst2.i_rd,
                          i_reg: inst1.ireg, reg_1: regs[inst2.i_rs1], reg_2: regs[inst2.i_rs2]};
        decode_reg.valid <= 1'b1;
        fetch_reg.valid <= 1'b0;
      end

      if (decode_reg.valid) begin
        logic [15:0] temp_result;
        case (decode_reg.opcode)
          LOAD: begin
            // set adress 
            temp_result <= dmem_rdata;
          end

          MOVE: temp_result <= decode_reg.reg_1;
          ADD : temp_result <= decode_reg.reg_1 + decode_reg.reg_2;
          SUB : temp_result <= decode_reg.reg_1 - decode_reg.reg_2;
          MUL : temp_result <= decode_reg.reg_1 * decode_reg.reg_2;
          JNZ : if (regs[decode_reg.i_reg] != '0) begin
                  pc <= decode_reg.addr;
                  decode_reg.valid <= 1'b0;
                  fetch_reg.valid <= 1'b0;
                end
          default: ;
        endcase

        execute_reg <= '{valid: 1'b1, pc_count: decode_reg.pc_count, opcode: decode_reg.opcode, addr: decode_reg.addr, alu_result: temp_result, i_rd: decode_reg.i_rd};
        execute_reg.valid <= 1'b1;
        decode_reg.valid <= 1'b0;
      end

      if (execute_reg.valid) begin
        if (execute_reg.opcode == ADD) begin // include other operations as well
          regs[execute_reg.i_rd] <= execute_reg.alu_result;
        end

        memory_reg <= '{valid: 1'b1, pc_count: execute_reg.pc_count, data: execute_reg.alu_result, i_rd: execute_reg.i_rd};
        memory_reg.valid <= 1'b1;
        execute_reg.valid <= 1'b0;
      end

      if (memory_reg.valid) begin
        regs[memory_reg.i_rd] <= memory_reg.data;
        memory_reg.valid <= 1'b0;
      end
    end
  end

  always_comb begin
    imem_addr = pc;

    dmem_addr  = addr;
    dmem_wdata = regs[i_reg];
    dmem_wen   = !reset && opcode == STORE;
  end
  
endmodule