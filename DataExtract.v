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
    input   [63:0]  din,
    input           bypass,
    input   [15:0]  mask,
    input   [6:0]   seed,


    output  [3:0]   foundFrames,
    output  [8:0]   searchedFrames,
    // output  [5:0]   alignAddr,  
    output  [9:0]   alignAddr,    //10 bits 
    output          aligned,
    output  [6:0]   errorCounter, 
    output  [23:0]  tot_err_count,
    output          errorFlag,
    output  [63:0]  prbs_from_check, 
    output  [63:0]  errorBits,
    output  [63:0]  dout

);

    // reg [63:0] dataBuf;
//    reg [1079:0] dataBuf;
        
        reg [127:0] dataBuf;
        
    always @(posedge clk) 
//    always @(negedge clk) 

    begin
        // dataBuf[63:32]  <=  din;
//        dataBuf[1079:1015]  <=  din;
        dataBuf[127:64] <= din;

        dataBuf[63:0] <= dataBuf[127:64];
        // dataBuf[31:0] <= dataBuf[63:32];
//        dataBuf[1015:0] <= dataBuf[1079:64];
        
        
    end

    


    reg [3:0] foundFrames; //found header id in 256 data records.

    reg [8:0] searchedFrames; //if do not find a id in 256 data records, move on
    
    reg [3:0] failureTimes; //failureTimes after synched. 
    
    reg synched;            //synched status or not
    assign aligned = synched;

    reg [9:0] alignAddr;
    reg [63:0] raw_dout;
    wire [63:0] raw_net;


    generate
        genvar i;
        for (i = 0 ; i < 64; i= i+1 )
        begin
            assign  raw_net[i] = dataBuf[alignAddr+i];
        end    
    endgenerate

    always @(posedge clk) 
    begin
        raw_dout <= raw_net;
    end

  //  rev_map rev_map_inst(
    map map_inst(
    .din(raw_dout),
    .clk(clk),
    .bypass(bypass),
    .dout(dout)
    );

wire bypass;
wire [6:0] seed;
    PRBS7Check prbsCKInst
    (
        .clk(clk),
        .din(dout),
        .mask(mask),
        .reset(reset),
        .seed(seed),

        .prbs(prbs_from_check),
        .errorCounter(errorCounter),
        .errorBits(errorBits)
    );

// wire [31:0] errorBits;
wire [63:0] errorBits;

    wire errorFlag = (errorCounter != 6'h00);
    // wire errorFlag = (errorCounter != 12'h00);

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




reg [23:0] tot_err_count;
reg firstAligned;
always @ (posedge clk)
    if(reset)
    begin
        firstAligned <= 1'b0;
        tot_err_count <= 24'd0;
    end
    else 
    begin
    if(aligned == 1'b1 && firstAligned ==1'b0)
    begin
        firstAligned <= 1'b1;
    end
    if(firstAligned)
    begin
        tot_err_count <= tot_err_count +errorCounter;
    end
end 

endmodule
