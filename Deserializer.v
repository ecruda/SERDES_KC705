`timescale 10ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Datao Gong 
// 
// Create Date: Fri Feb 12 12:40:40 CST 2021
// Module Name: deserializer
// Project Name: ETROC2 readout
// Description: 
// Dependencies: 
// 
// LSB first deserializer
//  for logic check only


//////////////////////////////////////////////////////////////////////////////////


module deserializer #(parameter WORDWIDTH = 32, parameter WIDTH = 6 /* WIDTH = $clog2(WORDWIDTH) */)  (
    input                   bitCK,
    input                   reset,
    input [WIDTH-1:0]       delay,
	input                   sin,         //output serial data
    output reg              wordCK,
	output [WORDWIDTH-1:0]  dout         //input data
);

    wire [WIDTH - 1 : 0] half = WORDWIDTH >> 1 ;
    reg [WIDTH - 1 : 0] counter;  
    always @(posedge bitCK) 
    begin
        if(!reset)
        begin
            counter <= {WORDWIDTH*{1'b0}};
        end
        else if(counter < WORDWIDTH-1)
        begin
            counter <= counter + 1;
        end
        else 
        begin
            counter <= {WORDWIDTH*{1'b0}};
        end
    end

    always @(posedge bitCK) 
    begin
        if(!reset)
        begin
            wordCK <= 1'b0;
        end
        else if(counter < half)
        begin
            wordCK <= 1'b0;
        end
        else 
        begin
            wordCK <= 1'b1;
        end
    end

    reg [WORDWIDTH-1:0] outBuf;
    reg [WORDWIDTH-1:0] r;          //internal registers
    reg [WORDWIDTH-1:0] delayCell;  //delay cell 
    wire delayedS;                  //delayed signal
    assign delayedS = (delay == 0) ? sin : delayCell[delay - 1];  
    always @(posedge bitCK) 
    begin
        delayCell <= {delayCell[WORDWIDTH-2:0],sin};
        r <= {delayedS, r[WORDWIDTH-1:1]};
    end

    always @(posedge wordCK) 
    begin        
        outBuf <= r;       
    end
    assign dout = outBuf;

endmodule