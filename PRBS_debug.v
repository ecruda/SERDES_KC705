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
	// output reg [31:0] prbs_out
	output reg [63:0] prbs_out

	);

// reg [126:0] prbs71=127'b0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010;

// prbs71 below is from Cyclone 10GX project
reg [126:0] prbs71=127'b1111111010101001100111011101001011000110111101101011011001001000111000010111110010101110011010001001111000101000011000001000000;// PRBS created from right to left, b0^b1==b7


// reg [31:0] dframe;
reg [63:0] dframe;

always @(posedge clk) begin
	
		
		prbs71[126:0] <= { prbs71[63:0],prbs71[126:64]};

		
		dframe[63:0] <= prbs71[63:0];
		
		
//		prbs_out[63:0] <= dframe[63:0];
        prbs_out[63:0] <= {1'b1^dframe[63], dframe[62:56], 1'b0^dframe[55], dframe[54:48]
                                , 1'b1^dframe[47], dframe[46:40], 1'b0^dframe[39], dframe[38:32]
                                         , 1'b1^dframe[31], dframe[30:24], 1'b0^dframe[23], dframe[22:16]
                                                , 1'b1^dframe[15], dframe[14:8] , 1'b0^dframe[7], dframe[6:0]};
//        prbs_out[63:0] <= {1'b1, dframe[62:48], 1'b0, dframe[46:32], 1'b1, dframe[30:16], 1'b0, dframe[14:0]};		

end


endmodule