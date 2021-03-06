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
    input           bypass,

    output  [3:0]   foundFrames,
    output  [8:0]   searchedFrames,
    output  [4:0]   alignAddr,        
    output          aligned,  
    output  [5:0]   errorCounter, 
    output  [24:0]  tot_err_count,
    output          errorFlag,
    output  [31:0]  prbs_from_check, 
    output  [31:0]  errorBits,
	output  [31:0]  dout
);

    reg [63:0] dataBuf;
    always @(posedge clk) 
//    always @(negedge clk) 

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


    reg [31:0] raw_dout;
    wire [31:0] raw_net;

    generate
        genvar i;
        for (i = 0 ; i < 32; i= i+1 )
        begin
            assign  raw_net[i] = dataBuf[alignAddr+i];
        end    
    endgenerate

    always @(posedge clk) 
    begin
        raw_dout <= raw_net;
    end

    rev_map rev_map_inst(
    .din(raw_dout),
    .clk(clk),
    .bypass(bypass),
    .dout(dout)
    );

wire bypass;

    PRBS7Check prbsCKInst
    (
        .clk(clk),
        .din(dout),
        .prbs(prbs_from_check),
        .errorCounter(errorCounter),
        .errorBits(errorBits)
    );

wire [31:0] errorBits;
//    reg [31:0] prbs_from_check;
    wire errorFlag = (errorCounter != 6'h00);

    always @(posedge clk) 
    begin
        if(reset)
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
                    if(errorCounter > 6'd0)
                    begin
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




reg [24:0] tot_err_count;

always @ (posedge clk)
    begin
        tot_err_count <= tot_err_count +errorCounter;
    end
endmodule
