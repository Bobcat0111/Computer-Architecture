`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:39:21 04/21/2020 
// Design Name: 
// Module Name:    control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module control(
    instruction,
    clk,
    reset,
    zero,
    ireg_write_enable,
    regfile_write_enable,
    alu_src_a,
    alu_src_b,
    alu_op,
    pc_source,
    pc_write_enable,
    mem_read,
    mem_select,
    mem_to_reg
  );
  `include "params.v"
  
  parameter ALU_SRC_A_WIDTH = 1 ;
  parameter ALU_SRC_B_WIDTH = 2 ;
  parameter NUM_STATE_BITS = 4 ;
  parameter STATE_RESET = 0 ;
  parameter STATE_IF = 1 ;
  parameter STATE_ID = 3 ;
  parameter STATE_LR_ADDR = 4 ;
  parameter STATE_SR_ADDR = 5 ;
  parameter STATE_EXEC = 6 ;
  parameter STATE_BRANCH = 7 ;
  parameter STATE_MOVE = 8 ;
  parameter STATE_ADDI = 9 ;
  parameter STATE_LI = 9 ;
  parameter STATE_MEM_READ = 11 ;
  parameter STATE_MEM_WRITEBACK = 12 ;
  parameter STATE_MEM_STORE = 13 ;
  parameter STATE_ALU_WB = 14 ;
  parameter STATE_ERROR = 15 ;
  parameter OPCODE_LSB = INSTRUCTION_WIDTH - WIDTH_OPCODE ;

	 
  input [INSTRUCTION_WIDTH-1:0] instruction ;
  input clk ;
  input reset ;
  input zero ;
  output reg ireg_write_enable ;
  output reg regfile_write_enable ;
  output reg [ALU_SRC_A_WIDTH-1:0] alu_src_a ;
  output reg [ALU_SRC_B_WIDTH-1:0] alu_src_b ;
  output reg [ALU_OP_NUM_BITS-1:0] alu_op ;
  output reg [1:0] pc_source ;
  output reg pc_write_enable ;
  output reg mem_read ;
  output reg mem_select;
  output reg mem_to_reg ;

  wire [WIDTH_OPCODE-1:0] opcode ;
  assign opcode = instruction[INSTRUCTION_WIDTH-1:OPCODE_LSB] ;
  reg [NUM_STATE_BITS-1:0] current_state ;
  reg [NUM_STATE_BITS-1:0] next_state ;


// update/reset current state
always @ (posedge clk)
begin
if( reset )
     current_state <= STATE_RESET ;
else 
     current_state <= next_state ;
end

// calculate next state and the necessary outputs for each state. 
parameter ALU_A_PC_ENABLE = 1'b0 ;
parameter ALU_A_REG_SRC = 1'b1 ;
parameter ALU_B_REG_SRC = 2'd0 ;
parameter ALU_B_PLUS_2 = 2'd1 ;
parameter ALU_B_IMM_BYTES = 2'd2 ;
parameter ALU_B_IMM_WORD = 2'd3 ;
parameter DATA_SELECT_ALU_OUT = 1'b0 ;
parameter DATA_SELECT_MEMORY = 1'b1 ;


always @ (current_state or opcode or zero ) begin
  // First set the default so we don't create a latch
  ireg_write_enable <= 1'b0 ;
  regfile_write_enable <= 1'b0 ;
  alu_src_a <= 1'b0 ;
  alu_src_b <= 2'b0;
  alu_op <= ALU_OP_ADD ;
  pc_source <= PC_SELECT_RESET ;
  pc_write_enable <= 1'b0 ; 
  mem_read <= 1'b0 ;
  mem_select <= 1'b0 ;
  mem_to_reg <= DATA_SELECT_ALU_OUT ;

  case ( current_state )
    STATE_RESET:begin
      next_state <= STATE_IF ;
      // set all of the outputs
      ireg_write_enable <= 1'b0 ;
      regfile_write_enable <= 1'b0 ;
      alu_src_a <= 1'b0 ;
      alu_src_b <= 2'b0;
      alu_op <= ALU_OP_ADD ;
      pc_source <= PC_SELECT_RESET ;
      pc_write_enable <= 1'b1 ; // turn it on;
      mem_read <= 1'b1 ;
      mem_select <= 1'b0 ;
      mem_to_reg <= DATA_SELECT_ALU_OUT ;
    end 
    STATE_IF:begin
      next_state <= STATE_ID ;
      // set the control outputs
      // PC = PC + 4 ;
      regfile_write_enable <= 1'b0 ;
      alu_src_a <= ALU_A_PC_ENABLE ;
      alu_src_b <= ALU_B_PLUS_2 ;
      alu_op <= ALU_OP_ADD ;
      pc_source <= PC_SELECT_ALU ;
      pc_write_enable <= 1'b1 ;
      // IR <= (PC) 
      mem_read <= 1'b0 ;
      mem_select <= 1'b0 ;
      ireg_write_enable <= 1'b1 ;
    end 
 
   STATE_ID: begin
      pc_write_enable <= 1'b0 ;
      ireg_write_enable <= 1'b0 ;
      // calc the next state
      case( opcode )
	INSTR_NOP: 
	  next_state <= STATE_IF ;
	INSTR_ADD:
	  next_state <= STATE_EXEC ;
	INSTR_LR:
	  next_state <= STATE_LR_ADDR ;
	INSTR_SR:
	  next_state <= STATE_SR_ADDR ;
	INSTR_BNEQ:
	  next_state <= STATE_BRANCH ;
	INSTR_MOV:
	  next_state <= STATE_MOVE ;
	INSTR_LI:
	  next_state <= STATE_ADDI ;
	INSTR_ADDI:
	  next_state <= STATE_ADDI ;
	default:
	  next_state <= STATE_ERROR ;
      endcase
      // Speculate on the branch by calculating BTA
      alu_src_a <= ALU_A_PC_ENABLE ;
      alu_src_b <= ALU_B_IMM_WORD ;
      alu_op <= ALU_OP_ADD ;
    end

   STATE_LR_ADDR: begin
      // calc the next state
      next_state <= STATE_MEM_READ ;
      alu_src_a <= ALU_A_REG_SRC ;
      alu_src_b <= ALU_B_IMM_BYTES ;
      alu_op <= ALU_OP_ADD ;
    end

   STATE_SR_ADDR: begin
      // calc the next state
      next_state <= STATE_MEM_STORE ;
      alu_src_a <= ALU_A_REG_SRC ;
      alu_src_b <= ALU_B_IMM_BYTES ;
      alu_op <= ALU_OP_ADD ;
    end

   STATE_MEM_READ: begin
      // calc the next state
      next_state <= STATE_MEM_WRITEBACK ;
      mem_read <= 1'b1 ;
      mem_select <= 1'b1 ;
    end

   STATE_MEM_WRITEBACK: begin
      // calc the next state
      next_state <= STATE_IF ;
      mem_select <= 1'b1 ;
      regfile_write_enable <= 1'b1 ;
      mem_to_reg <= DATA_SELECT_MEMORY ;
    end

   STATE_MEM_STORE: begin
      next_state <= STATE_IF ;
      mem_read <= 1'b0 ; // write
      mem_select <= 1'b1 ; // This signal turns on chip select on the data memory
   end

   STATE_EXEC: begin
      // calc the next state
      next_state <= STATE_ALU_WB ;
      alu_src_a <= ALU_A_REG_SRC ;
      alu_src_b <= ALU_B_REG_SRC ;
      case( opcode )
	INSTR_NOP: 
	  alu_op <= ALU_OP_ADD ;
	INSTR_ADD:
	  alu_op <= ALU_OP_ADD ;
	INSTR_ADDI:
	  alu_op <= ALU_OP_ADD ;
	default:
	  next_state <= ALU_OP_ADD ;
      endcase
    end

   STATE_ALU_WB: begin
      // calc the next state
      next_state <= STATE_IF ;
      mem_to_reg <= DATA_SELECT_ALU_OUT ;
      regfile_write_enable <= 1'b1 ;
    end
 
   STATE_BRANCH: begin
      // calc the next state
      next_state <= STATE_IF ;
      alu_src_a <= ALU_A_REG_SRC ;
      alu_src_b <= ALU_B_REG_SRC ;
      alu_op <= ALU_OP_SUB ;
      if (zero )  
	     pc_write_enable <= 1'b0 ;
      else begin
	     pc_source <= PC_SELECT_ALU_BUF ;
	     pc_write_enable <= 1'b1 ;
      end
    end

   STATE_ADDI: begin
      // calc the next state
      next_state <= STATE_ALU_WB ;
      alu_src_a <= ALU_A_REG_SRC ;
      alu_src_b <= ALU_B_IMM_BYTES ;
      alu_op <= ALU_OP_ADD ;
    end
	 
	 default : begin
	   next_state <= STATE_RESET ;
	    ireg_write_enable <= 1'b0 ;
	    regfile_write_enable <= 1'b0 ;
	    alu_src_a <= 1'b0 ;
	    alu_src_b <= 2'b0;
	    alu_op <= ALU_OP_ADD ;
	    pc_source <= PC_SELECT_RESET ;
	    pc_write_enable <= 1'b1 ; // turn it on;
	    mem_read <= 1'b1 ;
	    mem_select <= 1'b0 ;
	    mem_to_reg <= DATA_SELECT_ALU_OUT ;
    end
	 
   endcase 
	
end 
endmodule
