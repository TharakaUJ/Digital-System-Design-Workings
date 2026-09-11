`timescale 1ns/1ps

module cpu (
  input  logic        clk, reset,
  output logic [7 :0] imem_addr,  dmem_addr,
  input  logic [15:0] imem_rdata, dmem_rdata,
  output logic [15:0] dmem_wdata,
  output logic        dmem_wen
);
  logic [7:0] pc, addr, pc_temp;
  logic [15:0] regs [16];
  enum logic [3:0] {LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ} opcode;
  logic [15:0] temp_result_exec, temp_dmem_wdata_mem, temp_result_wb;

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
  } fetch_decode_reg_t;

  typedef struct packed {
    logic valid;
    logic [7:0] pc_count;
    logic [3:0] opcode;
    logic [7:0] addr;
    logic [3:0] i_rs1, i_rs2, i_rd, i_reg;
    logic [15:0] reg_1, reg_2;
  } decode_exe_reg_t;

typedef struct packed {
    logic       valid;
    logic [7:0] pc_count;
    logic [3:0] opcode;
    logic [7:0] addr;
    logic [15:0] alu_result;
    logic [3:0]  i_rd;
  } exe_mem_reg_t;

typedef struct packed {
    logic        valid;
    logic [7:0]  opcode;
    logic [7:0]  pc_count;
    logic [15:0] alu_result;
    logic [15:0] mem_data;
    logic [3:0]  i_rd;
  } mem_wb_reg_t;

  fetch_decode_reg_t fetch_decode_reg;
  decode_exe_reg_t decode_exe_reg;
  exe_mem_reg_t exe_mem_reg;
  mem_wb_reg_t mem_wb_reg;

  always_ff @(posedge clk) begin
    if (reset) begin
      pc   <= '0;
      foreach (regs[i]) begin
        regs[i] <= '0;
      end

      fetch_decode_reg <= '{valid: 1'b0, pc_count: '0, instruction: '0};
      decode_exe_reg <= '{valid: 1'b0, pc_count: '0, opcode: '0, addr: '0};
      exe_mem_reg <= '{valid: 1'b0, pc_count: '0, opcode: '0, addr: '0, alu_result: '0};
      mem_wb_reg <= '{valid: 1'b0, pc_count: '0, alu_result: '0, mem_data: '0, i_rd: '0, opcode: '0};

    end else begin

      // fetch stage
      fetch_decode_reg <= '{valid: 1'b1, pc_count: pc, instruction: imem_rdata};
      fetch_decode_reg.valid <= 1'b1;
      pc <= pc_temp;


      // decode stage
      if (fetch_decode_reg.valid) begin

        instruction_type1_t inst1;
        instruction_type2_t inst2;

        inst1 = instruction_type1_t'(fetch_decode_reg.instruction);
        inst2 = instruction_type2_t'(fetch_decode_reg.instruction);

        decode_exe_reg <= '{valid: 1'b1, pc_count: fetch_decode_reg.pc_count, opcode: inst1.opcode, addr: inst1.addr, i_rs1: inst2.i_rs1, i_rs2: inst2.i_rs2, i_rd: inst2.i_rd,
                          i_reg: inst1.ireg, reg_1: regs[inst2.i_rs1], reg_2: regs[inst2.i_rs2]};
        decode_exe_reg.valid <= 1'b1;
        fetch_decode_reg.valid <= 1'b0;
      end

      // EXE: Execute stage
      if (decode_exe_reg.valid) begin    
        temp_result_exec = '0;
        case (decode_exe_reg.opcode)
          MOVE: temp_result_exec = decode_exe_reg.reg_1;
          ADD : temp_result_exec = decode_exe_reg.reg_1 + decode_exe_reg.reg_2;
          SUB : temp_result_exec = decode_exe_reg.reg_1 - decode_exe_reg.reg_2;
          MUL : temp_result_exec = decode_exe_reg.reg_1 * decode_exe_reg.reg_2;
          default: ;
        endcase
        exe_mem_reg <= '{valid: 1'b1, pc_count: decode_exe_reg.pc_count, opcode: decode_exe_reg.opcode, addr: decode_exe_reg.addr, alu_result: temp_result_exec, i_rd: decode_exe_reg.i_rd};
        exe_mem_reg.valid <= 1'b1;
        decode_exe_reg.valid <= 1'b0;
      end

      // MEM:
      if (exe_mem_reg.valid) begin

        // load or store
        dmem_wdata <= temp_dmem_wdata_mem;

        mem_wb_reg <= '{valid: 1'b1, pc_count: exe_mem_reg.pc_count, opcode: exe_mem_reg.opcode, alu_result: exe_mem_reg.alu_result, i_rd: exe_mem_reg.i_rd, mem_data: dmem_rdata};
        mem_wb_reg.valid <= 1'b1;
        exe_mem_reg.valid <= 1'b0;
      end

      // WB :
      if (mem_wb_reg.valid) begin
        // write back to register file
        regs[mem_wb_reg.i_rd] <= temp_result_wb;
        mem_wb_reg.valid <= 1'b0;
      end
    end
  end

  // Fetch:
  always_comb begin : FETCH_COMB
    imem_addr = pc;
  end

  // Decode:
  always_comb begin : DECODE_COMB
    pc_temp = pc + 1'b1;

    if(fetch_decode_reg.opcode == JNZ) begin
      instruction_type1_t inst1;
      inst1 = instruction_type1_t'(fetch_decode_reg.instruction);
      if (regs[inst1.ireg] != '0) begin
        pc_temp = inst1.addr;
      end
    end
  end


  //Exec:
  always_comb begin EXEC_COMB
    case (decode_exe_reg.opcode)
      MOVE: temp_result_exec = decode_exe_reg.reg_1;
      ADD : temp_result_exec = decode_exe_reg.reg_1 + decode_exe_reg.reg_2;
      SUB : temp_result_exec = decode_exe_reg.reg_1 - decode_exe_reg.reg_2;
      MUL : temp_result_exec = decode_exe_reg.reg_1 * decode_exe_reg.reg_2;
      default: ;
    endcase
  end


  // MEM: 
  always_comb begin MEM_COMB
    dmem_addr = '0;
    dmem_wen   = 1'b0;
    temp_dmem_wdata_mem = '0;
    if (exe_mem_reg.opcode == LOAD) begin
      dmem_addr = exe_mem_reg.addr;
    end else if (exe_mem_reg.opcode == STORE) begin
      dmem_addr = exe_mem_reg.addr;
      dmem_wen   = 1'b1;
      temp_dmem_wdata_mem = regs[exe_mem_reg.i_rd];
    end
  end

  // WB:
  always_comb begin WB_COMB
    temp_result_wb = '0;
    case (mem_wb_reg.opcode)
      LOAD: temp_result_wb = mem_wb_reg.mem_data;
      MOVE: temp_result_wb = mem_wb_reg.alu_result;
      ADD : temp_result_wb = mem_wb_reg.alu_result;
      SUB : temp_result_wb = mem_wb_reg.alu_result;
      MUL : temp_result_wb = mem_wb_reg.alu_result;
      default: ;
    endcase
  end
  
    
  
endmodule