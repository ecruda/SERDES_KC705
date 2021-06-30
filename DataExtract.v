`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Datao Gong 
// 
// Create Date: Sat Jan 23 12:36:50 CST 2021
// Module Name: dataExtract
// Project Name: GBS20
// Description: 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created

// 
//////////////////////////////////////////////////////////////////////////////////
module dataExtract
(
	input           clk,            
    input           reset,
    input   [31:0]  din,

    output  [3:0]   foundFrames,
    output  [8:0]   searchedFrames,
    output  [4:0]   alignAddr,        
    output          aligned,  
    output  [5:0]   errorCount, 
	output  [31:0]  dout
);

    reg [63:0] dataBuf;
    always @(posedge clk) 
    begin
        dataBuf[63:32]  <=  din;
        dataBuf[31:0] <= dataBuf[63:32];
    end

    reg [3:0] foundFrames; //found header id in 256 data records.
    reg [8:0] searchedFrames; //if do not find a id in 256 data records, move on
    reg [3:0] failureTimes; //failureTimes after synched. 
    reg synched;            //synched status or not
    assign aligned = synched;

    reg [4:0] alignAddr;

    generate
        genvar i;
        for (i = 0 ; i < 32; i= i+1 )
        begin
            assign  dout[i] = dataBuf[alignAddr+i];
        end    
    endgenerate

    PRBS7Check prbsCKInst
    (
        .clk(clk),
        .din(dout),
        .errorCounter(errorCount)
    );

    wire errorFlag = (errorCount != 6'h00);

    always @(posedge clk) 
    begin
        if(!reset)
        begin
            foundFrames     <= 4'h0;
            failureTimes    <= 4'h0;
            synched         <= 1'b0;
            alignAddr       <= 5'h00;
            searchedFrames  <= 9'h000;
        end
        else
        begin
            if(synched == 1'b0)
            begin
                if(errorFlag == 1'b0) //found one
                begin
                    foundFrames <= foundFrames + 1;
                    searchedFrames <= 9'h000; //for next search
                    if(foundFrames > 10)
                    begin
                        synched <= 1'b1;
                        failureTimes  <= 4'h0;
                    end   
                end
                else
                begin
                    searchedFrames <= searchedFrames + 1;
                    if(searchedFrames > 9'd127)
                    begin
                        searchedFrames <= 9'h000;
                        foundFrames <= 4'h0;
                        alignAddr <= alignAddr + 1;
                    end
                end
            end
            else
            begin
                if(errorFlag == 1'b0) //found one
                begin
                    searchedFrames <= 9'h000;
                end
                else 
                begin
                    if(errorCount > 6'd6)begin
                        searchedFrames <= searchedFrames + 1;
                    end
                    if(searchedFrames > 9'd127 )
                    begin
                        searchedFrames <= 9'h000;
                        failureTimes <= failureTimes + 1;
                        if(failureTimes > 2)
                        begin
                            synched <= 1'b0;
                            foundFrames <= 4'h0;
                        end
                    end                   
                end
            end
        end
    end
endmodule
