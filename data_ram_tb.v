`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:13:08 05/08/2020
// Design Name:   data_ram
// Module Name:   /home/eng/w/wps100020/EE4304/project/verilog/multicycle/harvard/harvard/data_ram_tb.v
// Project Name:  harvard
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: data_ram
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module data_ram_tb;

	// Inputs
	reg [11:0] address;
	reg [15:0] write_data;
	reg read_not_write;
	reg cs;
	reg clk;

	// Outputs
	wire [15:0] read_data;

	// Instantiate the Unit Under Test (UUT)
	data_ram uut (
		.address(address), 
		.write_data(write_data), 
		.read_data(read_data), 
		.read_not_write(read_not_write), 
		.cs(cs), 
		.clk(clk)
	);
   integer c ;
	initial begin
		// Initialize Inputs
		address = 0;
		write_data = 0;
		read_not_write = 1;
		cs = 1;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		for ( c = 0 ; c <= 12 ; c = c+1 ) begin
		   clk <= c ;
		   address <= 12'd16 ;
		   #100 ;
	        end

	end
      
endmodule

