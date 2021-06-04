`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Elijah Cruda
// 
// Create Date: Fri Jun 4 12:36:50 CST 2021
// Module Name: diff_out
// Project Name: GBS20
// Description: input single-ended; output differential
// for PRBS7
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created

// 
//////////////////////////////////////////////////////////////////////////////////
module diff_out   #(parameter WORDWIDTH = 16) (
    input       [WORDWIDTH - 1:0]           sig_in,
    input                   clk,
    output		[WORDWIDTH - 1:0]			sig_out_p,
    output		[WORDWIDTH - 1:0]			sig_out_n        
);
reg [WORDWIDTH - 1:0] out_p;
reg [WORDWIDTH - 1:0] out_n;

    always @ (posedge clk) 
    begin        
       out_p <= sig_in;
       out_n <= ~sig_in;      
    end

assign sig_out_p = out_p ;
assign sig_out_n = out_n ;

endmodule