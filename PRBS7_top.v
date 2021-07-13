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
//    input   reset2,
    input   SMA_MGT_REFCLK_P,
    input   SMA_MGT_REFCLK_N,
    input   DRP_CLK_IN_P,
    input   DRP_CLK_IN_N,
    input   RXP_IN,
    input   RXN_IN,
    output  TXP_OUT,
    output  TXN_OUT
    );
    
(* mark_debug = "true" *)
 wire [63:0] gt0_rxdata_i;
// wire [31:0] gt0_rxdata_i;
(* mark_debug = "true" *)
wire [63:0] gt0_txdata_i;
// wire [31:0] gt0_txdata_i;
wire gt0_txusrclk2_i;
(* mark_debug = "true" *)
wire gt0_rxusrclk2_i;

// reg [29:0]cnt=30'b0;
// reg [29:0] In_reg;
// wire [29:0] DataScrambled;


/*PRBS7 #(.WORDWIDTH(32)) prbs1Inst
    (
        //in
        .clk(gt0_txusrclk2_i),
        .reset(reset),
        .dis(1'b0),
        .seed(7'H7F),
        (* mark_debug = "true" *)
        
        //out
        .prbs(gt0_txdata_i)
    ); */

// wire [31:0] prbs32;   
wire [63:0] prbs32;    

PRBS_debug PRBS_debug_inst0(
	.clk(gt0_txusrclk2_i),
	(* mark_debug = "true" *)
	.prbs_out(gt0_txdata_i)
	);

PRBS7Check prbs_source_check_inst_0(
  .clk(gt0_txusrclk2_i),
  .din(gt0_txdata_i),
  .prbs(prbs_from_check_to_check_source),
  .errorCounter(errorCount_to_check_source)
    );
 (* mark_debug = "true" *)  
wire  [6:0]   errorCount_to_check_source;
// wire  [11:0]   errorCount_to_check_source;

(* mark_debug = "true" *)
// wire [31:0]   prbs_from_check_to_check_source;
wire [63:0]   prbs_from_check_to_check_source;

rev_map rev_map_inst(
// map map_inst(
    .clk(gt0_txusrclk2_i),
    .bypass(bypass),
    .din(gt0_txdata_i),
    .dout(map_dout)
);
assign bypass = 1'b0;   
(* mark_debug = "true" *)
wire bypass;
(* mark_debug = "true" *)
// wire     [31:0]  map_dout;
wire     [63:0]  map_dout;

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
    .Q2_CLK1_GTREFCLK_PAD_N_IN(SMA_MGT_REFCLK_N), 
    .Q2_CLK1_GTREFCLK_PAD_P_IN(SMA_MGT_REFCLK_P),
    .DRP_CLK_IN_P(DRP_CLK_IN_P),
    .DRP_CLK_IN_N(DRP_CLK_IN_N),
    .TRACK_DATA_OUT("open"),//(track_data_i),
    .RXN_IN(RXN_IN),
    .RXP_IN(RXP_IN),
    .TXN_OUT(TXN_OUT),
    .TXP_OUT(TXP_OUT),
//    (* mark_debug = "true" *)
    .gt0_rxdata_i(gt0_rxdata_i),    //out
//    (* mark_debug = "true" *)
    .gt0_txdata_i(map_dout),    //in
    .gt0_txusrclk2_i( gt0_txusrclk2_i), //out       
    .gt0_rxusrclk2_i( gt0_rxusrclk2_i)  //out
);

//wire gt0_rxusrclk2_i;


shifter shifter_inst(
    .clk(gt0_txusrclk2_i),
    .bypass(bypass),
    .din(map_dout),
    .dout(shifter_dout)
    );

(* mark_debug = "true" *)
wire [63:0] shifter_dout;
// wire [31:0] shifter_dout;

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

/*rev_map rev_map_inst(
    .clk(gt0_rxusrclk2_i),
    .din(gt0_rxdata_i),
    .dout(rev_map_dout)
);
(* mark_debug = "true" *)
wire     [31:0]     gt0_rxdata_i;
*/

dataExtract dataAligner
(
    //Input
    .clk(gt0_rxusrclk2_i),
    .reset(reset),
    .din(gt0_rxdata_i),
    // .din(shifter_dout),
    .bypass(bypass),

    //Output
    .foundFrames(foundFrames),
    .searchedFrames(searchedFrames),
    .alignAddr(alignAddr),
    .aligned(aligned),
    .errorCounter(errorCounter),
    .tot_err_count(tot_err_count),
    .errorFlag(errorFlag),
    .prbs_from_check(prbs_from_check),
    .errorBits(errorBits),
    .dout(dout)
);
(* mark_debug = "true" *)
// wire  [7:0]   foundFrames;
wire  [3:0]   foundFrames;

(* mark_debug = "true" *)
// wire  [17:0]   searchedFrames;
wire  [8:0]   searchedFrames;

(* mark_debug = "true" *)
wire  [5:0]   alignAddr;
// wire  [4:0]   alignAddr;

(* mark_debug = "true" *)        
wire          aligned;

(* mark_debug = "true" *)  
// wire  [11:0]   errorCounter;
wire  [6:0]   errorCounter;

(* mark_debug = "true" *)  
// wire  [49:0]    tot_err_count;
wire  [24:0]    tot_err_count;

(* mark_debug = "true" *)
wire          errorFlag;

(* mark_debug = "true" *)
wire [63:0]   prbs_from_check;
// wire [31:0]   prbs_from_check;

(* mark_debug = "true" *)
wire [63:0]   errorBits;
// wire [31:0]   errorBits;

(* mark_debug = "true" *)
wire [63:0] dout;
// wire [31:0] dout;

/*wire [160:0] TRIG0;
ila_0 ila (
.clk(gt0_rxusrclk2_i),
.probe0(TRIG0)
);
assign TRIG0[31:0] = gt0_txdata_i;
assign TRIG0[63:32] = gt0_rxdata_i;
assign TRIG0[95:64] = errorCount;
assign TRIG0[160:96] = 64'b0;*/


/*ila_0 ila ( 
.clk(gt0_rxusrclk2_i),
.probe0(probe0),
.probe1(probe1),
.probe2(probe2)
);*/

endmodule