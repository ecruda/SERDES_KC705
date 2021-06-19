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


module PRBS7_top(
    input   reset,
    input   reset2,
    input   SMA_MGT_REFCLK_P,
    input   SMA_MGT_REFCLK_N,
    input   DRP_CLK_IN_P,
    input   DRP_CLK_IN_N,
    input   RXP_IN,
    input   RXN_IN,
    output  TXP_OUT,
    output  TXN_OUT
    );

PRBS7 #(.WORDWIDTH(32)) prbs1Inst
    (
        .clk(gt0_txusrclk2_i),
        .reset(reset),
        .dis(1'b0),
        .seed(7'H7F),
        (* mark_debug = "true" *)
        .prbs(prbs)
    ); 


/*diff_out   #(.WORDWIDTH(32)) diff_out_inst1
    (
        .sig_in(prbs),
        .clk(gt0_txusrclk2_i),
        .sig_out_p(RXP_IN),
        .sig_out_n(RXN_IN)        
    );*/
// ---------------- Instantiate clock module -------------------------------

/*clk_wiz_0 clk_wiz_0_inst_1
(
    .clk_out1(clk_wiz_out),     //160 MHz
    .locked(locked),
    .reset(reset),
    .clk_in1_p(USER_SMA_CLOCK_P),
    .clk_in1_n(USER_SMA_CLOCK_N)
);*/

//----------------- Instantiate an gtwizard_0_exdes module  -----------------
//wire gt0_txusrclk2_i;
gtwizard_0_exdes gtwizard_0_exdes_i
(
    .Q0_CLK1_GTREFCLK_PAD_N_IN(SMA_MGT_REFCLK_N), 
    .Q0_CLK1_GTREFCLK_PAD_P_IN(SMA_MGT_REFCLK_P),
    .DRP_CLK_IN_P(DRP_CLK_IN_P),
    .DRP_CLK_IN_N(DRP_CLK_IN_N),
    .TRACK_DATA_OUT("open"),//(track_data_i),
    .RXN_IN(RXN_IN),
    .RXP_IN(RXP_IN),
    .TXN_OUT(TXN_OUT),
    .TXP_OUT(TXP_OUT),
    .gt0_rxdata_i(word),
    .gt0_txdata_i(prbs),
    .gt0_txusrclk2_i( gt0_txusrclk2_i),
    .gt0_rxusrclk2_i( gt0_rxusrclk2_i)
);

//wire gt0_rxusrclk2_i;



/*diff_in   #(.WORDWIDTH(32)) diff_in_inst1
(
    .sig_in_p(TXP_OUT),
    .sig_in_n(TXN_OUT),
    .clk(gt0_rxusrclk2_i),           //needs clk from tx ip, fast
    .sig_out(word), 
    (* mark_debug = "true" *) 
    .err(err)    //error when 1, no err when 0
);*/




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
    .clk(gt0_rxusrclk2_i),
    .reset(reset2),
    .din(word),
    .aligned(aligned),

    (* mark_debug = "true" *)
    .errorCount(errorCount),
    .dout(decodedData)
);


ila_0 ila (
.clk(gt0_rxusrclk2_i),
.probe0(probe0),
.probe1(probe1),
.probe2(probe2)
);

endmodule