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
	input                       clk,            
    input           [63:0]      din,
    input       wire    [15:0]      mask,
    input                       reset,
    input           [6:0]       seed,
    input           [1:0]       user_mode,

    output         [63:0]       prbs,
    output          [63:0]      errorBits,
    output          [63:0]      userBits,
    output          [63:0]      usererrorBits,

    output          [6:0]       usererrorCounter,           
    output                      errorFlag,
    output          [7:0]       userData,
    output          [6:0]       errorCounter           //error flag if it is not prbs7

);
    

    reg [6:0] r;
    always @(posedge clk) 
    begin

        r <= din[63:64-7];  //only keep the last 7 bits

    end
    
    wire [6:0] c [64:0]; //chain for iteration
    wire [63 : 0] prbsNet;

    generate
        genvar i;
        for (i = 0 ; i < 64; i = i + 1)
        begin : loop_itr
            assign prbsNet[i] = c[i][1]^c[i][0];            
            assign c[i+1] = {prbsNet[i],c[i][6:1]}; //LSB out, 
        end
    endgenerate
    assign c[0] = r;
    
    wire [15:0] mask;
    wire [6:0] seed;
    /*PRBS7 #(.WORDWIDTH(64)) prbs1Inst
    (
        .clk(clk),
        .reset(reset),
        .dis(1'b0),
        .seed(seed),
        .prbs(prbs)
    ); */
    
    /*PRBS_debug PRBS_debug_inst0(
	.clk(clk),
	(* mark_debug = "true" *)
	.prbs_out(prbs)
	);*/
    
    reg [63:0]    prbs;

    reg [63:0] errorBits;
    reg [63:0] userBits;
    
    reg [63:0] usererrorBits;

    reg [63:0] din1D;
    

    reg [6:0] c0 [15:0];
    reg [6:0] c1 [7:0];
    reg [6:0] c2 [3:0];
    reg [6:0] c3 [1:0];
    reg [6:0] c4;
 
    reg [6:0] a0 [15:0];
    reg [6:0] a1 [7:0];
    reg [6:0] a2 [3:0];
    reg [6:0] a3 [1:0];
    reg [6:0] a4;
    reg [63:0] preBits;
    reg [7:0] userData;
    
//    assign errorFlag = (prbs ^ din1D & {~mask, ~mask, ~mask, ~mask}) != 64'd0;
    always @(posedge clk)
    begin
        din1D <= din;
        prbs <= prbsNet;
        // errorBits <= prbs ^ din1D;
        preBits <= prbs ^ din1D;
        errorBits <= preBits & {~mask, ~mask, ~mask, ~mask};
//         errorBits <= prbs ^ din1D ;
        userBits <=  preBits & {mask, mask, mask, mask};
//        userBits <= din ^ {mask, mask, mask, mask};       
//        userData <= {|userBits[63:56], |userBits[55:48], |userBits[47:40],|userBits[39:32],|userBits[31:24],|userBits[23:16],|userBits[15:8],|userBits[7:0]};
        userData <= {userBits[63], userBits[55] ,userBits[47] , userBits[39], userBits[31], userBits[23], userBits[15], userBits[7]};


        case(user_mode)
         2'b00://loopback mode
         usererrorBits <= userBits ^ 64'h0080008000800080;   //use for userdata = 55
         
         2'b01://internal prbs mode
         usererrorBits <= userBits ^ 64'h0000000000000000; //use for userdata = 00
         
         2'b10://internal prbs w/ user data = 55
         usererrorBits <= userBits ^ 64'h0080008000800080;   //use for userdata = 55

         2'b11://internal prbs w/user data = prbs;
         usererrorBits <= userBits ^ 64'h0000000000000000; //use for userdata = 00
    

    endcase
 
      
        
           
        
        a0[0] <= {5'd0,usererrorBits[0]}+
                 {5'd0,usererrorBits[1]}+
                 {5'd0,usererrorBits[2]}+
                 {5'd0,usererrorBits[3]};
        a0[1] <= {5'd0,usererrorBits[4]}+
                 {5'd0,usererrorBits[5]}+
                 {5'd0,usererrorBits[6]}+
                 {5'd0,usererrorBits[7]};
        a0[2] <= {5'd0,usererrorBits[8]}+
                 {5'd0,usererrorBits[9]}+
                 {5'd0,usererrorBits[10]}+
                 {5'd0,usererrorBits[11]};
        a0[3] <= {5'd0,usererrorBits[12]}+
                 {5'd0,usererrorBits[13]}+
                 {5'd0,usererrorBits[14]}+
                 {5'd0,usererrorBits[15]};
        a0[4] <= {5'd0,usererrorBits[16]}+
                 {5'd0,usererrorBits[17]}+
                 {5'd0,usererrorBits[18]}+
                 {5'd0,usererrorBits[19]};
        a0[5] <= {5'd0,usererrorBits[20]}+
                 {5'd0,usererrorBits[21]}+
                 {5'd0,usererrorBits[22]}+
                 {5'd0,usererrorBits[23]};
        a0[6] <= {5'd0,usererrorBits[24]}+
                 {5'd0,usererrorBits[25]}+
                 {5'd0,usererrorBits[26]}+
                 {5'd0,usererrorBits[27]};
        a0[7] <= {5'd0,usererrorBits[28]}+
                 {5'd0,usererrorBits[29]}+
                 {5'd0,usererrorBits[30]}+
                 {5'd0,usererrorBits[31]};
        a0[8] <= {5'd0,usererrorBits[32]}+
                 {5'd0,usererrorBits[33]}+
                 {5'd0,usererrorBits[34]}+
                 {5'd0,usererrorBits[35]};
        a0[9] <= {5'd0,usererrorBits[36]}+
                 {5'd0,usererrorBits[37]}+
                 {5'd0,usererrorBits[38]}+
                 {5'd0,usererrorBits[39]};
        a0[10] <= {5'd0,usererrorBits[40]}+
                 {5'd0,usererrorBits[41]}+
                 {5'd0,usererrorBits[42]}+
                 {5'd0,usererrorBits[43]};
        a0[11] <= {5'd0,usererrorBits[44]}+
                 {5'd0,usererrorBits[45]}+
                 {5'd0,usererrorBits[46]}+
                 {5'd0,usererrorBits[47]};
        a0[12] <= {5'd0,usererrorBits[48]}+
                 {5'd0,usererrorBits[49]}+
                 {5'd0,usererrorBits[50]}+
                 {5'd0,usererrorBits[51]};
        a0[13] <= {5'd0,usererrorBits[52]}+
                 {5'd0,usererrorBits[53]}+
                 {5'd0,usererrorBits[54]}+
                 {5'd0,usererrorBits[55]};
        a0[14] <= {5'd0,usererrorBits[56]}+
                 {5'd0,usererrorBits[57]}+
                 {5'd0,usererrorBits[58]}+
                 {5'd0,usererrorBits[59]};
        a0[15] <= {5'd0,usererrorBits[60]}+
                 {5'd0,usererrorBits[61]}+
                 {5'd0,usererrorBits[62]}+
                 {5'd0,usererrorBits[63]};
         a1[0] <= a0[0] + a0[1];
         a1[1] <= a0[2] + a0[3];
         a1[2] <= a0[4] + a0[5];
         a1[3] <= a0[6] + a0[7];       
         a1[4] <= a0[8] + a0[9];
         a1[5] <= a0[10] + a0[11];
         a1[6] <= a0[12] + a0[13];
         a1[7] <= a0[14] + a0[15]; 


         a2[0] <= a1[0] + a1[1];
         a2[1] <= a1[2] + a1[3];
         a2[2] <= a1[4] + a1[5];
         a2[3] <= a1[6] + a1[7];

         a3[0] <= a2[0] + a2[1];
         a3[1] <= a2[2] + a2[3];            

         a4 <= a3[0] + a3[1];
//----------------------------------------------------------------
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
    assign usererrorCounter = a4;
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

    wire [1:0] user_mode;
    
    
    
    
endmodule
