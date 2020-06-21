
// Sample Instruction Set Architecture Design
// 1) Choose 2 operand data operations - accumulator mode
// 2) Choose Register names indexed as R<integer> valid for [0..NUM_REGISTERS-1]
module decode_instruction(
  instruction,
  reg_dest,     // Overwritten
  reg_source,   // Not overwritten
  immediate
  // opcode
  ) ;
  `include "params.v"

  input [INSTRUCTION_WIDTH-1:0] instruction ;  //[23:0]
  output [REGFILE_ADDR_BITS-1:0] reg_source ;  //[1:0]
  output [REGFILE_ADDR_BITS-1:0] reg_dest ;    //[1:0]
  output [IMMEDIATE_WIDTH-1:0] immediate ;     //[11:0]
  // output [WIDTH_OPCODE-1:0] opcode ;


  // Instruction format 1: Data computation 
  // ASSEMBLY: add R1, R2  ; R2 = R1 + R2 ;
  // opcode | reg_dest | reg_source | unused  
  //   5    |    4     |    4          16      // 29 - 13  = 16
  parameter OPCODE_LSB = INSTRUCTION_WIDTH - WIDTH_OPCODE ;  //24-5=19
  // assign opcode = instruction[INSTRUCTION_WIDTH-1:OPCODE_LSB];
  // assign opcode = instruction[28:24];
  // This gives 29-1 : 29-5 or [28:24]   28 27 26 25 24
  //
  parameter DEST_LSB = OPCODE_LSB - REGFILE_ADDR_BITS ;   //19-2=17
  assign reg_dest = instruction[18:17] ;   // [18:17]
  // assign reg_dest = instruction[23:20] ;
  // This gives 29-5-1 : 29-5-4 or [23:20]   23 22 21 20
  //
  // Add parameter here:
  assign reg_source = instruction[16:15] ;       //[16:15]
  // This gives 29-5-4-1 : 29-5-8 or [23:20]   19 18 17 16

  assign immediate = instruction[IMMEDIATE_WIDTH-1:0] ;   //[11:0]
  // Instruction format 2a: Load Register
  // ASSEMBLY: lr RDest, RSource[Immediate] : lr R2, R1[0x10] or load R1(0x10) into R2
  // opcode | reg_dest | reg_source | unused | immediate   
  //   5    |    4     |    4          4        12     // 29 - 13 - 12 = 4
  //
  // Instruction format 2b: Save Register
  // ASSEMBLY: sr RSource[Immediate], Rdest : sr R1[0x10], R2 or save R2 to R1(0x10)
  // opcode | reg_dest | reg_source | unused | immediate   
  //   5    |    4     |    4          4        12     // 29 - 13 - 12 = 4
    
  // Instruction format 3: Branch Not Equal
  // ASSEMBLY: bneq RDest, RSource, Immediate : bneq R2, R1, 0x10 or PC+4+0x10 if (R1) != (R2)
  // opcode | reg_dest | reg_source | unused | immediate   
  //   5    |    4     |    4          4        12     // 29 - 13 - 12 = 4
    
  // Instruction format 4: MOV Rdest, Rsource
  // ASSEMBLY: mov RDest, RSource : mov R2, R1 or move (R1) to (R2) 
  // opcode | reg_dest | reg_source | unused 
  //   5    |    4     |    4          16     // 29 - 13 = 16
  //
  // Instruction format 5: LI Rdest, Immediate
  // ASSEMBLY: li RDest, Immediate : li R2, 0xA or (R1) <= 10 
  // opcode | reg_dest | unused | immediate 
  //   5    |    4     |   8    |     12             // 29 - 9 - 12 = 8
  //
  // Instruction format 6: addi Rdest, Immediate
  // ASSEMBLY: addi RDest, Immediate : add R2, 0x1 or (R2) <= (R2) + 1
  // opcode | reg_dest | unused | immediate 
  //   5    |    4     |   8    |     12             // 29 - 9 - 12 = 8
   
  // Program C = A + B   A @ 0x10 B @ 0x20
  // lr R1, R0[0x10]
  // lr R2, R0[0x20]
  // add R2, R1  ; R2 <= (R1) + (R2)
  // sr R0[0x10], R2
  //
  // int sum = 0 ;
  // for( i = 0 ; i <= 10 ; i++ ){
  //   sum += i ; 
  // }
  // mov R1, R0 ;  sum <= 0
  // mov R2, R0 ;  i <= 0
  // or
  // li R1, 0x0 ; sum <= 0 
  // li R2  0x0 ; i <= 0 
  //
  // li R3, 0xA ;  test <= 10 - could count down instead - one less register
  // addi R2, 0x1 ; i += 1  
  // add R1, R2 ; sum += i  
  // bneq R2, R3, -3
    
endmodule

