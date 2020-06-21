`timescale 1ns / 1ps
module data_register( 
    clk, 
    in_data, 
    out_data,
    en
  ) ;

  `include "params.v"

  input clk ;
  input [DATA_BUS_WIDTH-1:0] in_data ;
  output reg [DATA_BUS_WIDTH-1:0] out_data ;
  input en ;

  always @ (posedge clk) begin
    if ( en )
      out_data <= in_data ;
  end

endmodule

module addr_register( 
    clk, 
    in_data, 
    out_data,
    en
  ) ;

  `include "params.v"

  input clk ;
  input [ADDRESS_BUS_WIDTH-1:0] in_data ;
  output reg [ADDRESS_BUS_WIDTH-1:0] out_data ;
  input en ;

  always @ (posedge clk) begin
    if ( en )
      out_data <= in_data ;
  end

endmodule


module inst_register( 
    clk, 
    in_data, 
    instruction,
    en
  ) ;

  `include "params.v"

  input clk ;
  input [INSTRUCTION_WIDTH-1:0] in_data ;
  output reg [INSTRUCTION_WIDTH-1:0] instruction ;
  input en ;

  always @ (posedge clk) begin
    if ( en )
      instruction <= in_data ;
  end

endmodule

