`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Grey Cat
// 
// Create Date:    Mon Apr 27 10:31:58 CDT 2020
// Design Name: 
// Module Name:    Multi_Cycle_Computer 
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
module Multi_Cycle_Computer(
         clock,
	 reset,
	 program_out
  ) ;
  `include "params.v"

  input clock ;
  input reset ;
  output [DATA_BUS_WIDTH-1:0] program_out ;

  supply1 VDD;

  wire clock_delayed ;	  // Delay clock to get timing right for RAM

  //instruction wires
  wire [ADDRESS_BUS_WIDTH-1:0] pc_addr ;
  wire [ADDRESS_BUS_WIDTH-1:0] next_pc_addr ;
  wire [INSTRUCTION_WIDTH-1:0] instruction;
  wire [INSTRUCTION_WIDTH-1:0] imem_data ;	// fetch one instruction at a time

  // data address wires
  wire [ADDRESS_BUS_WIDTH-1:0] reset_address ;
  wire [ADDRESS_BUS_WIDTH-1:0] jump_address ;

  wire [DATA_BUS_WIDTH-1:0] mem_data ;		// user or data memory 
  wire [DATA_BUS_WIDTH-1:0] user_data ;		// data in user space 
  wire [DATA_BUS_WIDTH-1:0] regfile_data ;

  // register file wires
  wire [REGFILE_ADDR_BITS-1:0] dest_reg ;
  wire [REGFILE_ADDR_BITS-1:0] source_reg ;
  
  // ALU input connections
  wire [DATA_BUS_WIDTH-1:0] alu_A ;		// state of regfile read
  wire [DATA_BUS_WIDTH-1:0] alu_B ;		// state of regfile read
  
  // immediate width
  wire [IMMEDIATE_WIDTH-1:0] immediate ;
  wire [DATA_BUS_WIDTH-1:0] imm4 ;
  wire [DATA_BUS_WIDTH-1:0] sign_extended ;
  
  wire [ALU_OP_NUM_BITS-1:0] alu_op ;

  // Data registers
  wire [DATA_BUS_WIDTH-1:0] rf_A ;		// state of regfile read
  wire [DATA_BUS_WIDTH-1:0] rf_B ;		// state of regfile read
  wire [DATA_BUS_WIDTH-1:0] rf_A_saved ;	// save state of regfile read
  wire [DATA_BUS_WIDTH-1:0] rf_B_saved ;	
  wire [DATA_BUS_WIDTH-1:0] alu_out ;		// alu output
  wire [DATA_BUS_WIDTH-1:0] alu_out_buf ;	// alu output

  wire [0:0] alu_A_src ;
  wire [1:0] alu_B_src ;
  wire [1:0] pc_control ;
  
  assign reset_address = 12'd0 ;
  assign jump_address = 12'd0 ; // for now
  assign program_out = mem_data ;

  //program counter
  addr_register program_counter( .clk(clock), .in_data(next_pc_addr), .out_data(pc_addr), .en(pc_write) ) ;

  // combined instruction and data memory - this memory has a control that can
  // only either read or write.
  assign #30 clock_delayed = clock ;
  iram imem(.address(pc_addr), .clk(clock_delayed), .data(imem_data), 
                    .read_not_write(VDD)); // always read in Harvard

  data_ram dmem(.address(alu_out_buf[DATA_BUS_WIDTH-1:0]), 
		    .read_data(mem_data), 
		    .clk(clock), 
		    .write_data(rf_B_saved),
		    .cs(mem_select),
                    .read_not_write(mem_read)); 

  // Where we store instructions fetched from memory
  inst_register iregister( .clk(clock), .in_data(imem_data), .instruction(instruction), 
                           .en(ireg_enable) ) ;

  // Where we store data fetched from memory
  data_register mregister( .clk(clock_delayed), .in_data(mem_data), .out_data(user_data), .en(mem_select) ) ;

  // How to decode the instruction
  decode_instruction decoder( .instruction(instruction), .reg_dest(dest_reg), .reg_source(source_reg),
                              .immediate(immediate) ) ;

  //register file
  regfile regfile( .clk(clock), .read_addr1(source_reg), .read_addr2(dest_reg),
                   .write_addr(dest_reg),
                   .read_data1(rf_A), .read_data2(rf_B), .write_data(regfile_data), 
		   .write_enable(regfile_write_enable) ) ;

  // Registers to hold contents 
  data_register regA( .clk(clock), .in_data(rf_A), .out_data(rf_A_saved), .en(VDD) ) ;
  data_register regB( .clk(clock), .in_data(rf_B), .out_data(rf_B_saved), .en(VDD) ) ;

  // mux to select where data comes from
  data_mux2 regfile_data_select(.data_0(alu_out_buf), .data_1(user_data), .select(mem_or_alu), 
                                .data_out(regfile_data) );

  // mux to select ALU src 1 input
  data_mux2 alu_src1_select(.data_0({4'b0,pc_addr}), .data_1(rf_A_saved), .select(alu_A_src), 
                            .data_out(alu_A) );
									 
  sign_extender se ( .src(immediate), .out1(sign_extended) ) ;
  left_shift2 ls ( .shift_in(sign_extended), .shift_out(imm4) ) ;

  // mux to select ALU src 2 input
  data_mux4 alu_src2_select(.data_0(rf_B_saved), .data_1(16'h4), .data_2(sign_extended), .data_3(imm4), .select(alu_B_src), 
                            .data_out(alu_B) );

  alu alu_1 ( .A(alu_A), .B(alu_B), .result(alu_out), .Alu_Op(alu_op), .Z(equal_zero), .C(carry_out),
              .N(negative) ) ;

  // Data register to hold the value of the ALU
  data_register ALU_out( .clk(clock), .in_data(alu_out), .out_data(alu_out_buf), .en(VDD) ) ;

  addr_mux4 pc_select(.data_0(alu_out[ADDRESS_BUS_WIDTH-1:0]), .data_1(alu_out_buf[ADDRESS_BUS_WIDTH-1:0]), .data_2(jump_address),
                      .data_3(reset_address), .select(pc_control), .data_out(next_pc_addr)) ;
  
  
  control CPUcontrol ( .clk(clock), .reset(reset), .instruction(instruction), .zero(equal_zero), .pc_write_enable(pc_write),
                       .pc_source(pc_control),
                       .ireg_write_enable(ireg_enable),
		       .regfile_write_enable(regfile_write_enable),
		       .alu_src_a(alu_A_src), .alu_src_b(alu_B_src),
                       .alu_op(alu_op), 
		       .mem_read(mem_read), 
		       .mem_select(mem_select), .mem_to_reg(mem_or_alu) ) ;							      

endmodule
