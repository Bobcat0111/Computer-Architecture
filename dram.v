`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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
module data_ram(
    clk,
    address,
    write_data,
    read_data,
    read_not_write,
    cs
  );

  `include "params.v"

  input [DATA_BUS_WIDTH-1:0] address ;
  input [DATA_BUS_WIDTH-1:0] write_data ;
  output [DATA_BUS_WIDTH-1:0] read_data ;
  input read_not_write ;
  input cs ;
  input clk ;

  // NUM_ADDRESS/2 x INSTRUCTION_BUS_WIDTH bits 
  // parameter NUM_DATA_ADDRESSES = NUM_ADDRESS / 2 ;
  // Uncomment the parameter above for the real addresses.
  // Cut it down to 64 for debugging purposes.
  parameter NUM_DATA_ADDRESSES = 64 ;

  // Actual memory is Byte oriented!!! Try using Little Endian!
  wire [11:0] temaddress;
  reg [15:0] ram_memory [2047:0] ;
  reg [DATA_BUS_WIDTH-1:0] ram_private ;
  
  assign temaddress[11:0]=address[11:0];

  initial begin

  // The Data
  ram_memory[0] = 16'd0 ;
  ram_memory[1] = 16'd1 ;
  ram_memory[2] = 16'd2 ;
  ram_memory[4] = 16'd4 ;
  ram_memory[8] = 16'd8 ;
  ram_memory[16] = 16'd20 ;
  ram_memory[17] = 16'd0 ;
  ram_memory[32] = 16'd22 ;
  ram_memory[33] = 16'd0 ;
  ram_memory[48] = 16'd0;
  ram_memory[64] = 16'd0;
  end

  always @ ( posedge clk ) begin
    if ( cs )
      if ( read_not_write ) begin
	     ram_private <= ram_memory[temaddress] ;
      end else begin 
	    ram_memory[temaddress] <= write_data ;
    end else 
      ram_private <= 16'bz ;
  end
  assign read_data = ram_private ;

endmodule
