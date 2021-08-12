`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Elijah Cruda
// 
// Create Date: Fri Jun 4 12:36:50 CST 2021
// Module Name: diff_out
// Project Name: GBS20
// Description: input differential; output single-ended
// for PRBS7
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created

// 
//////////////////////////////////////////////////////////////////////////////////
module diff_in   #(parameter WORDWIDTH = 32) (
    input       [WORDWIDTH - 1:0]           sig_in_p,
    input       [WORDWIDTH - 1:0]           sig_in_n,
    input                   clk,
    output		[WORDWIDTH - 1:0]			sig_out,  
    output					err    //error when 1, no err when 0
);
reg [WORDWIDTH - 1:0] in_p;
reg [WORDWIDTH - 1:0] in_n;
reg [WORDWIDTH - 1:0] out_p;
reg sig_err;


    always @ (posedge clk) 
    begin        
       out_p <= in_p;
       sig_err <= ~(in_p ^ in_n);     
    end

assign sig_out = out_p ;
assign err = sig_err;

endmodule