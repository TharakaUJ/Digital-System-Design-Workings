`timescale 1ns/1ps

module cpu (
  input  logic        clk, reset,
  output logic [7 :0] imem_addr, dmem_addr,
  input  logic [15:0] imem_rdata, dmem_rdata,
  output logic [15:0] dmem_wdata,
  output logic        dmem_wen
);

  logic [7:0] pc;
  logic [7:0] pc_next;

  logic [15:0] regs [16];

  typedef enum logic [3:0] {
    LOAD,
    STORE,
    MOVE,
    ADD,
    SUB,
    MUL,
    JNZ
  } opcode_t;


  // ============================================================
  // Instruction formats
  // ============================================================

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


  // ============================================================
  // IF -> ID
  // ============================================================

  typedef struct packed {
    logic        valid;
    logic [7:0]  pc_count;
    logic [15:0] instruction;
  } fetch_decode_reg_t;


  // ============================================================
  // ID -> EX
  // ============================================================

  typedef struct packed {
    logic        valid;
    logic [7:0]  pc_count;

    logic [3:0]  opcode;
    logic [7:0]  addr;

    logic [3:0]  i_rs1;
    logic [3:0]  i_rs2;
    logic [3:0]  i_rd;
    logic [3:0]  i_reg;

    logic [15:0] reg_1;
    logic [15:0] reg_2;
    logic [15:0] store_data;
  } decode_exe_reg_t;


  // ============================================================
  // EX -> MEM
  // ============================================================

  typedef struct packed {
    logic        valid;
    logic [7:0]  pc_count;

    logic [3:0]  opcode;
    logic [7:0]  addr;

    logic [15:0] alu_result;
    logic [3:0]  i_rd;
    logic [15:0] store_data;
  } exe_mem_reg_t;


  // ============================================================
  // MEM -> WB
  // ============================================================

  typedef struct packed {
    logic        valid;
    logic [7:0]  pc_count;

    logic [3:0]  opcode;

    logic [15:0] alu_result;
    logic [15:0] mem_data;

    logic [3:0]  i_rd;
  } mem_wb_reg_t;


  fetch_decode_reg_t fetch_decode_reg;
  decode_exe_reg_t   decode_exe_reg;
  exe_mem_reg_t      exe_mem_reg;
  mem_wb_reg_t       mem_wb_reg;


  logic [15:0] temp_result_exec;
  logic [15:0] temp_result_wb;


  // ============================================================
  // JNZ / branch signals
  // ============================================================

  logic       branch_taken;
  logic [7:0] branch_target;


  // ============================================================
  // Pipeline registers
  // ============================================================

  always_ff @(posedge clk) begin

    if (reset) begin

      pc <= '0;

      foreach (regs[i])
        regs[i] <= '0;

      fetch_decode_reg <= '0;
      decode_exe_reg   <= '0;
      exe_mem_reg      <= '0;
      mem_wb_reg       <= '0;

    end

    else begin

      pc <= pc_next;


      // fetch -> decode
      fetch_decode_reg <= '0;

      if (!branch_taken) begin

        fetch_decode_reg.valid       <= 1'b1;
        fetch_decode_reg.pc_count    <= pc;
        fetch_decode_reg.instruction <= imem_rdata;

      end

      // decode -> execute
      decode_exe_reg <= '0;
      if (fetch_decode_reg.valid) begin

        instruction_type1_t inst1;
        instruction_type2_t inst2;

        inst1 = instruction_type1_t'(fetch_decode_reg.instruction);
        inst2 = instruction_type2_t'(fetch_decode_reg.instruction);

        decode_exe_reg.valid    <= 1'b1;
        decode_exe_reg.pc_count <= fetch_decode_reg.pc_count;

        decode_exe_reg.opcode   <= inst1.opcode;
        decode_exe_reg.addr     <= inst1.addr;

        decode_exe_reg.i_rs1    <= inst2.i_rs1;
        decode_exe_reg.i_rs2    <= inst2.i_rs2;
        decode_exe_reg.i_rd     <= inst2.i_rd;
        decode_exe_reg.i_reg    <= inst1.ireg;

        decode_exe_reg.reg_1    <= regs[inst2.i_rs1];
        decode_exe_reg.reg_2    <= regs[inst2.i_rs2];

        decode_exe_reg.store_data <= regs[inst1.ireg];

      end

      // execute -> memory
      exe_mem_reg <= '0;
      if (decode_exe_reg.valid) begin

        exe_mem_reg.valid      <= 1'b1;
        exe_mem_reg.pc_count   <= decode_exe_reg.pc_count;
        exe_mem_reg.opcode     <= decode_exe_reg.opcode;
        exe_mem_reg.addr       <= decode_exe_reg.addr;
        exe_mem_reg.alu_result <= temp_result_exec;
        exe_mem_reg.i_rd       <= decode_exe_reg.i_rd;
        exe_mem_reg.store_data <= decode_exe_reg.store_data;

      end


      mem_wb_reg <= '0;
      if (exe_mem_reg.valid) begin

        mem_wb_reg.valid      <= 1'b1;
        mem_wb_reg.pc_count   <= exe_mem_reg.pc_count;
        mem_wb_reg.opcode     <= exe_mem_reg.opcode;
        mem_wb_reg.alu_result <= exe_mem_reg.alu_result;
        mem_wb_reg.i_rd       <= exe_mem_reg.i_rd;
        mem_wb_reg.mem_data   <= dmem_rdata;

      end

      // WB
      if (mem_wb_reg.valid) begin

        case (mem_wb_reg.opcode)

          LOAD,
          MOVE,
          ADD,
          SUB,
          MUL:
            regs[mem_wb_reg.i_rd] <= temp_result_wb;

          default:
            ;

        endcase

      end
    end

  end


  // FETCH
  always_comb begin : FETCH_COMB

    imem_addr = pc;

  end


  // DECODE / NEXT PC
  always_comb begin : DECODE_COMB

    pc_next     = pc + 1'b1;

    branch_taken = 1'b0;
    branch_target = '0;


    if (fetch_decode_reg.valid) begin

      instruction_type1_t inst1;

      inst1 = instruction_type1_t'(fetch_decode_reg.instruction);


      if (inst1.opcode == JNZ) begin

        if (regs[inst1.ireg] != '0) begin

          pc_next      = inst1.addr;
          branch_taken = 1'b1;
          branch_target = inst1.addr;

        end

      end

    end

  end


  // EXECUTE
  always_comb begin : EXEC_COMB

    temp_result_exec = '0;

    case (decode_exe_reg.opcode)

      MOVE:
        temp_result_exec = decode_exe_reg.reg_1;

      ADD:
        temp_result_exec =
          decode_exe_reg.reg_1 +
          decode_exe_reg.reg_2;

      SUB:
        temp_result_exec =
          decode_exe_reg.reg_1 -
          decode_exe_reg.reg_2;

      MUL:
        temp_result_exec =
          decode_exe_reg.reg_1 *
          decode_exe_reg.reg_2;

      default:
        temp_result_exec = '0;

    endcase

  end


  // MEMORY

  always_comb begin : MEM_COMB

    dmem_addr  = '0;
    dmem_wdata = '0;
    dmem_wen   = 1'b0;


    if (exe_mem_reg.valid) begin

      case (exe_mem_reg.opcode)

        LOAD: begin

          dmem_addr = exe_mem_reg.addr;

        end


        STORE: begin

          dmem_addr  = exe_mem_reg.addr;
          dmem_wdata = exe_mem_reg.store_data;
          dmem_wen   = 1'b1;

        end


        default: begin

        end

      endcase

    end

  end


  // WRITE BACK
  always_comb begin : WB_COMB

    temp_result_wb = '0;

    case (mem_wb_reg.opcode)

      LOAD:
        temp_result_wb = mem_wb_reg.mem_data;

      MOVE,
      ADD,
      SUB,
      MUL:
        temp_result_wb = mem_wb_reg.alu_result;

      default:
        temp_result_wb = '0;

    endcase

  end

endmodule