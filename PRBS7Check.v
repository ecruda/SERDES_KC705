`timescale 1ns / 1fs
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Datao Gong 
// 
// Create Date: Sat Jan 23 12:36:50 CST 2021
// Module Name: PRBS7Check
// Project Name: ETROC2 readout
// Description: 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created

// 
//////////////////////////////////////////////////////////////////////////////////
module PRBS7Check
(
	input                   clk,            //40MHz
	input [31:0]   din,
    output [5:0]    errorCounter           //error flag if it is not prbs7
);
    reg [6:0] r;
    always @(posedge clk) 
    begin
        r <= din[31:32-7];  //only keep the last 7 bits
    end

    wire [6:0] c [32:0]; //chain for iteration
    wire [31 : 0] prbs;
    generate
        genvar i;
        for (i = 0 ; i < 32; i = i + 1)
        begin : loop_itr
            assign prbs[i] = c[i][1]^c[i][0];            
            assign c[i+1] = {prbs[i],c[i][6:1]}; //LSB out, 
        end
    endgenerate
    assign c[0] = r;
    wire [32-1:0] errorBits;
    assign errorBits = prbs ^ din; 
    //assign error = (prbs != din);
    assign errorCounter =   {5'd0,errorBits[0]}+
                            {5'd0,errorBits[1]}+
                            {5'd0,errorBits[2]}+
                            {5'd0,errorBits[3]}+
                            {5'd0,errorBits[4]}+
                            {5'd0,errorBits[5]}+
                            {5'd0,errorBits[6]}+
                            {5'd0,errorBits[7]}+
                            {5'd0,errorBits[8]}+
                            {5'd0,errorBits[9]}+
                            {5'd0,errorBits[10]}+
                            {5'd0,errorBits[11]}+
                            {5'd0,errorBits[12]}+
                            {5'd0,errorBits[13]}+
                            {5'd0,errorBits[14]}+
                            {5'd0,errorBits[15]}+
                            {5'd0,errorBits[16]}+
                            {5'd0,errorBits[17]}+
                            {5'd0,errorBits[18]}+
                            {5'd0,errorBits[19]}+
                            {5'd0,errorBits[20]}+
                            {5'd0,errorBits[21]}+
                            {5'd0,errorBits[22]}+
                            {5'd0,errorBits[23]}+
                            {5'd0,errorBits[24]}+
                            {5'd0,errorBits[25]}+
                            {5'd0,errorBits[26]}+
                            {5'd0,errorBits[27]}+
                            {5'd0,errorBits[28]}+
                            {5'd0,errorBits[29]}+
                            {5'd0,errorBits[30]}+
                            {5'd0,errorBits[31]};
endmodule
