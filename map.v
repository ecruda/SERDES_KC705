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
input			      clk,
input                 bypass,
input	     [31:0]	  din,
output	 reg [31:0]	  dout
);

/*wire [31:0] din;
reg [31:0] dout;*/
wire [31:0] by0;
wire [31:0] by1;

generate
            genvar i;
            for (i = 0 ; i < 4; i= i+1 )
            begin: loop_itr
                assign  by0[7+i*8] = din[0+i*8];//mapping
                assign  by0[6+i*8] = din[4+i*8];
                assign  by0[5+i*8] = din[1+i*8];
                assign  by0[4+i*8] = din[5+i*8];
                assign  by0[3+i*8] = din[2+i*8];
                assign  by0[2+i*8] = din[6+i*8];
                assign  by0[1+i*8] = din[3+i*8];
                assign  by0[0+i*8] = din[7+i*8];
                
                assign  by1[7+i*8] = din[7+i*8];//bypass
                assign  by1[6+i*8] = din[6+i*8];
                assign  by1[5+i*8] = din[5+i*8];
                assign  by1[4+i*8] = din[4+i*8];
                assign  by1[3+i*8] = din[3+i*8];
                assign  by1[2+i*8] = din[2+i*8];
                assign  by1[1+i*8] = din[1+i*8];
                assign  by1[0+i*8] = din[0+i*8];         
            end
    endgenerate
always @ (posedge clk)
    begin
        if(bypass) //bypass = 1
            begin
                dout <= by1;
            end
            else begin //bypass = 0
                dout <= by0;
            end
        
    end
	

    
endmodule