`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Datao Gong 
// 
// Create Date: Sat Jan 23 12:36:50 CST 2021
// Module Name: PRBS7
// Project Name: ETROC2 readout
// Description: 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created

// 
//////////////////////////////////////////////////////////////////////////////////
module PRBS7 #(parameter WORDWIDTH = 16)
(
	input           clk,            //40MHz
	input           reset,         //
	input           dis,          //
    input [6:0]     seed,   
	output [WORDWIDTH-1:0]    prbs
);

    wire [6:0] c [WORDWIDTH:0]; //chain for iteration
    reg [6:0] r;
    always @(posedge clk) 
    begin
        if(!dis)
        begin
            if(!reset)
            begin
                r <= seed;
            end
            else 
            begin
                r <= c[WORDWIDTH];
            end            
        end
    end

    assign c[0] = r;
    generate
        genvar i;
        for (i = 0 ; i < WORDWIDTH; i = i + 1)
        begin : loop_itr
            assign prbs[i] = c[i][1]^c[i][0];
            assign c[i+1] = {prbs[i],c[i][6:1]}; //LSB out, same as serializer
        end
    endgenerate

endmodule
