`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Elijah Cruda 
// 
// Create Date: Wed Jul	1 14:13:14 CST 2021
// Module Name: map
// Project Name: SERDES_KC705
// Description: 
// Dependencies: 
// 
// 

//////////////////////////////////////////////////////////////////////////////////


module map(
//input			clk,
input	[31:0]	din,
output	[31:0]	dout
);

//reg [31:0] din;
//wire [31:0] dout;

// always @(posedge clk) 
// 	begin
//    		din <= din;
// 	end
	
// assign dout = dout;

	
 generate
        genvar i;
        for (i = 0 ; i < 4; i= i+1 )
        begin: loop_itr
            assign  dout[0+i*8] = din[7+i*8];
            assign  dout[4+i*8] = din[6+i*8];
            assign  dout[1+i*8] = din[5+i*8];
            assign  dout[5+i*8] = din[4+i*8];
            assign  dout[2+i*8] = din[3+i*8];
            assign  dout[6+i*8] = din[2+i*8];
            assign  dout[3+i*8] = din[1+i*8];
            assign  dout[7+i*8] = din[0+i*8];         
        end
endgenerate
    
    
endmodule