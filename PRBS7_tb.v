`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Southern Methodist University
// Author: Datao Gong 
// 
// Create Date: Tue Feb  9 14:13:14 CST 2021
// Module Name: PRBS7_tb
// Project Name: ETROC2 readout
// Description: 
// Dependencies: 
// 
// LSB firs scrambling

//////////////////////////////////////////////////////////////////////////////////


module PRBS7_tb;
    reg reset;
    reg reset2;
    reg clk1024;
    reg sysclk; //clock 1280
    reg recClk; //clk640

wire clk1280;
wire [7:0] prbs;
//----------------- Instantiate an gtwizard_0_exdes module  -----------------

gtwizard_0_exdes gtwizard_0_exdes_i
(
    .Q0_CLK1_GTREFCLK_PAD_N_IN(Q0_CLK1_GTREFCLK_PAD_N_IN), 
    .Q0_CLK1_GTREFCLK_PAD_P_IN(Q0_CLK1_GTREFCLK_PAD_P_IN),
    .DRP_CLK_IN_P(DRP_CLK_IN_P),
    .DRP_CLK_IN_N(DRP_CLK_IN_N),
    .TRACK_DATA_OUT("open"),//(track_data_i),
    .RXN_IN(RXN_IN),
    .RXP_IN(RXP_IN),
    .TXN_OUT(TXN_OUT),
    .TXP_OUT(TXP_OUT)
    /*.gt0_rxdata_i(gt0_rxdata_i),
    .gt0_txdata_i(gt0_txdata_i),
    .gt0_txusrclk2_i( gt0_txusrclk2_i),
    .gt0_rxusrclk2_i( gt0_rxusrclk2_i)*/
);
wire [31:0] TXP_OUT;
wire [31:0] TXN_OUT;
diff_in   #(.WORDWIDTH(32)) diff_in_inst1
(
    .sig_in_p(TXP_OUT),
    .sig_in_n(TXN_OUT),
    .clk(TX_clk),           //needs clk from tx ip, fast
    .sig_out(word),  
    .err(err)    //error when 1, no err when 0
);
wire err;
wire [31:0] RXP_IN;
wire [31:0] RXN_IN;
diff_out   #(.WORDWIDTH(32)) diff_out_inst1
    (
        .sig_in(prbs),
        .clk(sysclk),
        .sig_out_p(RXP_IN),
        .sig_out_n(RXN_IN)        
    );
PRBS7 #(.WORDWIDTH(8)) prbs1Inst
    (
        .clk(sysclk),
        .reset(reset),
        .dis(1'b0),
        .seed(7'H7F),
        .prbs(prbs)
    ); 

// wire sout;
/*Serializer #(.WORDWIDTH(8)) serInst
(
    .reset(reset),
    .enable(1'b1),
    .bitCK(clk1024),
    .clk1280(clk1280),
    .din(prbs),
    .sout(sout)
); */
    
// wire wordCK;
wire [31:0] word;
/*deserializer #(.WORDWIDTH(32),.WIDTH(6)) desrInst
(
    .bitCK(clk1024),
    .reset(reset2),
    .delay(6'h0),
    .sin(sout),
    .wordCK(wordCK),
    .dout(word)
); */

wire aligned;
wire [5:0] errorCount;
wire [31:0] decodedData;
dataExtract dataAligner
(
    .clk(recClk),
    .reset(reset2),
    .din(word),
    .aligned(aligned),
    .errorCount(errorCount),
    .dout(decodedData)
);

    initial begin
        clk1024 = 0;
        sysclk = 0;
        recClk = 0;
        reset = 1;
        reset2 = 1;
        #25 reset = 1'b0;
        #50 reset = 1'b1;
        #75 reset2 = 1'b0;
        #100 reset2 = 1'b1;


        #500000 $stop;
    end
    always 
        #0.050 clk1024 = ~clk1024; //100 ps clock period, not exactly 10.24 GHz
    always
        #0.400 sysclk = ~sysclk;
    always 
        #1.6 recClk = ~recClk;
endmodule