// ============================================================================================
// Coding Challenge - Implementation of the RISC-V ISA Extensions for Control-Flow Integrity

// Implement a 3-state FSM in SystemVerilog that accepts a 32-bit packet every cycle:
// bits [31:24] represent a command (SET=0x01, JUMP=0x02, LPAD=0x03); bits [23:0] are data.
// If the FSM is in IDLE state, on SET, store data into the internal “label” register.
// On JUMP, move to the CHECK state. Otherwise, stay IDLE.
// If the FSM is in CHECK state, LPAD is received, and the data matches “label”, return to IDLE.
// Otherwise, move to ERROR. If the FSM reaches the ERROR state, it stays there forever.
// =============================================================================================


`timescale 1ps/1ps

module riscv_cfi_fsm (
    input logic clk,
    input logic rst_n,
    input logic [31:0] packet,
    output logic error
);

    typedef enum logic [1:0] { 
        IDLE = 2'b00,
        CHECK = 2'b01,
        ERROR = 2'b10
    } state_t;

    typedef enum logic [7:0] {
        SET = 8'h01,
        JUMP = 8'h02,
        LPAD = 8'h03
    } cmd_t;

    state_t current_state;
    state_t next_state;
    logic [23:0] label;
    logic [23:0] data;
    cmd_t cmd;

    assign data = packet[23:0];
    assign cmd   = cmd_t'(packet[31:24]);


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            label <= 24'b0;
        end else begin
            current_state <= next_state;

            if ((current_state == IDLE) & (cmd == SET)) begin
                label <= data;
            end
        end

        if (current_state == ERROR) begin
            error = 1'b1;
        end else begin
            error = 1'b0;
        end
    end

    always_comb begin
        case (current_state)
            IDLE:begin
                if (cmd  == SET) begin
                    next_state = IDLE;
                end else if (cmd == JUMP) begin
                    next_state = CHECK;
                end
            end

            CHECK:begin
                if(cmd == LPAD) begin
                    if (data == label) begin
                        next_state = IDLE;
                    end else begin
                        next_state = ERROR;
                    end
                end else begin
                    next_state = ERROR;
                end
            end

            ERROR:begin
                next_state = ERROR;
            end

            default: next_state = current_state;
        endcase
    end
endmodule