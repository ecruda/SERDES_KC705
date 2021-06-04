`timescale 10ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Datao Gong 
// 
// Create Date: Thu Feb 11 12:58:07 CST 2021
// Module Name: serializerBlock
// Project Name: GBS20
// Description: 
// Dependencies: 
// 
// LSB first serializer



//////////////////////////////////////////////////////////////////////////////////


module Serializer #(parameter WORDWIDTH = 8) 
(
    input                   reset,
    input                   enable,
    input                   bitCK,       //10.24 GHz clock
    output                  clk1280,     //output clock
	input [WORDWIDTH-1:0]   din,         //input data
	output                  sout         //output serial data
);
// tmrg default do_not_triplicate

    reg [4:0] counter;
    reg clk1280reg;
    always @(posedge bitCK) 
    begin
        if(!reset)
        begin
            counter <= 5'd0;
        end
        else
        begin
            counter <= counter + 1;
        end
        clk1280reg <= clk1280;
    end
    assign clk1280 = counter[2];
    wire load = ~clk1280reg&clk1280; 

    reg[WORDWIDTH-1:0] r;        //internal registers
    always @(posedge bitCK) 
    begin
        if(load)
        begin
            r <= din;     
        end
        else if(enable) 
        begin
            r <= {r[WORDWIDTH-1],r[WORDWIDTH-1:1]};
        end
    end
    assign sout = r[0];

endmodule