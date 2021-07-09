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
	// input [31:0]   din,
    input [63:0]   din,

    // output  reg [31:0]  prbs,
    output  reg [63:0]  prbs,
    
    // output  [31:0]  errorBits,
    output  [63:0]  errorBits,
    
    // output [5:0]    errorCounter           //error flag if it is not prbs7
    output [6:0]    errorCounter           //error flag if it is not prbs7

);
    reg [6:0] r;
    always @(posedge clk) 
    begin
        // r <= din[31:32-7];  //only keep the last 7 bits
        r <= din[63:64-7];  //only keep the last 7 bits

    end

    // wire [6:0] c [32:0]; //chain for iteration
    wire [6:0] c [64:0]; //chain for iteration

    // wire [31 : 0] prbsNet;
    wire [63 : 0] prbsNet;

    generate
        genvar i;
        // for (i = 0 ; i < 32; i = i + 1)
        for (i = 0 ; i < 64; i = i + 1)
        begin : loop_itr
            assign prbsNet[i] = c[i][1]^c[i][0];            
            assign c[i+1] = {prbsNet[i],c[i][6:1]}; //LSB out, 
        end
    endgenerate
    assign c[0] = r;

    // reg [31:0] errorBits;
    reg [63:0] errorBits;

    // reg [31:0] din1D;
    reg [63:0] din1D;
    
    reg [6:0] c0 [15:0];
    reg [6:0] c1 [7:0];
    reg [6:0] c2 [3:0];
    reg [6:0] c3 [1:0];
    reg [6:0] c4;
 
    always @(posedge clk)
    begin
        din1D <= din;
        prbs <= prbsNet;
        errorBits <= prbs ^ din1D;
        c0[0] <= {5'd0,errorBits[0]}+
                 {5'd0,errorBits[1]}+
                 {5'd0,errorBits[2]}+
                 {5'd0,errorBits[3]};
        c0[1] <= {5'd0,errorBits[4]}+
                 {5'd0,errorBits[5]}+
                 {5'd0,errorBits[6]}+
                 {5'd0,errorBits[7]};
        c0[2] <= {5'd0,errorBits[8]}+
                 {5'd0,errorBits[9]}+
                 {5'd0,errorBits[10]}+
                 {5'd0,errorBits[11]};
        c0[3] <= {5'd0,errorBits[12]}+
                 {5'd0,errorBits[13]}+
                 {5'd0,errorBits[14]}+
                 {5'd0,errorBits[15]};
        c0[4] <= {5'd0,errorBits[16]}+
                 {5'd0,errorBits[17]}+
                 {5'd0,errorBits[18]}+
                 {5'd0,errorBits[19]};
        c0[5] <= {5'd0,errorBits[20]}+
                 {5'd0,errorBits[21]}+
                 {5'd0,errorBits[22]}+
                 {5'd0,errorBits[23]};
        c0[6] <= {5'd0,errorBits[24]}+
                 {5'd0,errorBits[25]}+
                 {5'd0,errorBits[26]}+
                 {5'd0,errorBits[27]};
        c0[7] <= {5'd0,errorBits[28]}+
                 {5'd0,errorBits[29]}+
                 {5'd0,errorBits[30]}+
                 {5'd0,errorBits[31]};
        c0[8] <= {5'd0,errorBits[32]}+
                 {5'd0,errorBits[33]}+
                 {5'd0,errorBits[34]}+
                 {5'd0,errorBits[35]};
        c0[9] <= {5'd0,errorBits[36]}+
                 {5'd0,errorBits[37]}+
                 {5'd0,errorBits[38]}+
                 {5'd0,errorBits[39]};
        c0[10] <= {5'd0,errorBits[40]}+
                 {5'd0,errorBits[41]}+
                 {5'd0,errorBits[42]}+
                 {5'd0,errorBits[43]};
        c0[11] <= {5'd0,errorBits[44]}+
                 {5'd0,errorBits[45]}+
                 {5'd0,errorBits[46]}+
                 {5'd0,errorBits[47]};
        c0[12] <= {5'd0,errorBits[48]}+
                 {5'd0,errorBits[49]}+
                 {5'd0,errorBits[50]}+
                 {5'd0,errorBits[51]};
        c0[13] <= {5'd0,errorBits[52]}+
                 {5'd0,errorBits[53]}+
                 {5'd0,errorBits[54]}+
                 {5'd0,errorBits[55]};
        c0[14] <= {5'd0,errorBits[56]}+
                 {5'd0,errorBits[57]}+
                 {5'd0,errorBits[58]}+
                 {5'd0,errorBits[59]};
        c0[15] <= {5'd0,errorBits[60]}+
                 {5'd0,errorBits[61]}+
                 {5'd0,errorBits[62]}+
                 {5'd0,errorBits[63]};

         c1[0] <= c0[0] + c0[1];
         c1[1] <= c0[2] + c0[3];
         c1[2] <= c0[4] + c0[5];
         c1[3] <= c0[6] + c0[7];       
         c1[4] <= c0[8] + c0[9];
         c1[5] <= c0[10] + c0[11];
         c1[6] <= c0[12] + c0[13];
         c1[7] <= c0[14] + c0[15]; 


         c2[0] <= c1[0] + c1[1];
         c2[1] <= c1[2] + c1[3];
         c2[2] <= c1[4] + c1[5];
         c2[3] <= c1[6] + c1[7];

         c3[0] <= c2[0] + c2[1];
         c3[1] <= c2[2] + c2[3];            

         c4 <= c3[0] + c3[1];

    end
    //assign errorBits = prbs ^ din; 
    //assign error = (prbs != din);
    assign errorCounter = c4;
/*    assign errorCounter =   {5'd0,errorBits[0]}+
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
*/
endmodule
