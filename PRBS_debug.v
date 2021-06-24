`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Elijah Cruda 
// 
// Create Date: Wed Jun  23 14:13:14 CST 2021
// Module Name: PRBS_debug
// Project Name: SERDES_KC705
// Description: 
// Dependencies: 
// 
// 

//////////////////////////////////////////////////////////////////////////////////


module PRBS_debug(
	input clk,
	output reg [31:0] prbs_out
	);

reg [126:0] prbs71=127'b0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010;

reg [31:0] dframe;

always @(posedge clk) begin
	
		prbs71[126:0] <= { prbs71[31:0],prbs71[126:32]};
		dframe[31:0] <= prbs71[31:0];
		prbs_out[31:0] <= dframe[31:0];
end

endmodule