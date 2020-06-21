`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Grey Cat
// 
// Create Date:    10:02:55 04/02/2020 
// Design Name: 
// Module Name:    ram 
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
// Instructure RAM is read-only in Harvard architecture but we will add ability
// to write to it.  

module iram(
    address,
    data,
    read_not_write,
    clk
  );

  `include "params.v"  
input [11:0] address ;
  output [23:0] data ;
  input read_not_write ;
  input clk ;

 reg [23:0] ram_memory [511:0] ;
  reg [23:0] ram_private ;

  initial begin

  // Load the program at the halfway point which is the reset address
  // lr R1, R0[0x10]
  // lr R2, R0[0x20]
  // add R2, R1  ; R2 <= (R1) + (R2)
  // sr R0[0x30], R2
  // bneq R1, R0, -5 ;  go back to loop.

  // ASSEMBLY: lr RDest, RSource[Immediate] : lr R1, R0[0x10] or load R0(0x10) into R1
  //  opcode | reg_dest | reg_source         | unused | immediate   
  //    5         |    2           |    2                             3       12   
  //INSTR_LR |    1     |    0               |   0    |   0x10 
  //  00010      |  01     |  00                  000       0x10
  // 0 0010          01       00                  000     0x010
  // Here you see the advantage of a Harvard Architecture
  ram_memory[0] = 24'h120010 ;

  // ASSEMBLY: lr RDest, RSource[Immediate] : lr R2, R0[0x20] or load R0(0x20) into R2
  //    5    |    2     |    2                   3        12   
  //INSTR_LR |    2     |    0               |   0    |   0x20 
  // 00010       |   10   |  00                  000     0x20
  // 0 0010          10      00                  000      0x020
  ram_memory[4] = 24'h140020 ;

  // add R2, R1  ; R2 <= (R1) + (R2)
  //  opcode  | reg_dest | reg_source | unused  
  //   5           |    2           |    2          15      // 24 - 9  = 15
  //INSTR_ADD|  10    |  01      | 0x000
  // 0 0001           10   |  01       | 000 0x000
  ram_memory[8] = 24'h0C8000 ;

  // sr R0[0x30], R2
  // Instruction format 2b: Save Register
  // ASSEMBLY: sr RSource[Immediate], Rdest : sr R1[0x30], R2 or save R2 to R1(0x30)
  // opcode | reg_dest | reg_source | unused | immediate   
  //   5         |        2      |    2                      3        12  
  // 00011  |         2            0                  000     0x30
  // 00011  |        10           00                000     0x030
  ram_memory[12] = 24'h1C0030 ;





/// Second program
  // Instruction format 5: LI Rdest, Immediate
  // opcode | reg_dest | reg_source | unused | immediate 
  //     5       |    2          |    2              |  3          |     12        
  //  00000   |  10         |   01             |  000      |  0x000




 // opcode | reg_dest | reg_source | unused | immediate 
  //     5       |    2          |    2              |  3          |     12        
  //  00110   |  01         |   00             |  000      |  0x000
  // li R1, 0x0 ; sum <= 0 
  ram_memory[16] = 24'h320000 ;

// opcode | reg_dest | reg_source | unused | immediate 
  //     5       |    2          |    2              |  3          |     12        
  //  00110   |  10         |   00             |  000      |  0x000
  // li R2  0x0 ; i <= 0 
  ram_memory[20] = 24'h340000 ;





// opcode | reg_dest | reg_source | unused | immediate 
  //     5       |    2          |    2              |  3          |     12        
  //  00110   |  11         |   00             |  000      |  0x00A
  // li R3, 0xA ;  test <= 10 - could count down instead - one less register
  ram_memory[24] = 24'h36000A;

  // addi R2, R2, 0x1 ; i += 1  
  // Instruction format 6: addi Rdest, Immediate
  // ASSEMBLY: addi RDest, Immediate : add R2, 0x1 or (R2) <= (R2) + 1
  // opcode | reg_dest | reg_source | unused | immediate 
  //     5       |    2          |    2              |  3          |     12        
  //  00111   |  10         |   10             |  000      |  0x001
  ram_memory[28] = 24'h3D0001 ;

  // add R1, R2 ; sum += i  
  // add R1, R2  ; R1 <= (R2) + (R1)
  // opcode | reg_dest | reg_source | unused | immediate 
  //     5       |    2          |    2              |  3          |     12        
  //  00001    |  01          |   10             |  000      |  0x000
   ram_memory[32] =24'h0B0000 ;

  // bneq R2, R3, -3
  // Instruction format 3: Branch Not Equal
  // ASSEMBLY: bneq RDest, RSource, Immediate : bneq R2, R1, 0x10 or PC+4+0x10 if (R1) != (R2)
 // opcode | reg_dest | reg_source | unused | immediate 
  //     5       |    2          |    2              |  3          |     12        
  //  00100  |   10         |   11             |  000      |  0xFFD
  ram_memory[36] = 24'h258FFD ;

// sr R0[0x40], R1
  // Instruction format 2b: Save Register
  // ASSEMBLY: sr RSource[Immediate], Rdest : sr R1[0x30], R2 or save R2 to R1(0x30)
  // opcode | reg_dest | reg_source | unused | immediate   
  //   5         |        2      |    2                      3        12  
  // 00011   |       01           00                000     0x040
  ram_memory[40] = 24'h1A0040 ;

  end

  always @ ( posedge clk ) begin
    if ( read_not_write )
      ram_private <= ram_memory[address] ;
    else 
      ram_memory[address] <= data ;
  end
  assign data = ram_private ;

endmodule
