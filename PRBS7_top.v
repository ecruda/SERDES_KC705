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
//    input   SYS_RST,
    input   SMA_MGT_REFCLK_P,
    input   SMA_MGT_REFCLK_N,
    input   RXP_IN,
    input   RXN_IN,
    output  TXP_OUT,
    input wire SYS_CLK_P,            //system clock 200MHz
    input wire SYS_CLK_N,
    input wire SGMIICLK_Q0_P,        //125MHz for GTP/GTH/GTX  for 1G Ethernet interface
    input wire SGMIICLK_Q0_N,
    //----------------------< DIPSw4Bit
    input wire [3:0] DIPSw4Bit,
    //----------------------> Gigbit eth interface (RGMII)
    output wire PHY_RESET_N,
    output wire [3:0] RGMII_TXD,
    output wire RGMII_TX_CTL,
    output wire RGMII_TXC,
    input wire [3:0] RGMII_RXD,
    input wire RGMII_RX_CTL,
    input wire RGMII_RXC,
    inout wire MDIO,
    output wire MDC,
    output  TXN_OUT,
    //---------------------< IIC interface
    inout wire SDA,
    output wire SCL
    );
    
(* mark_debug = "true" *)
 wire [63:0] gt0_rxdata_i;
(* mark_debug = "true" *)
wire [63:0] gt0_txdata_i;
wire gt0_txusrclk2_i;
(* mark_debug = "true" *)
wire gt0_rxusrclk2_i; 
wire [63:0] prbs32;    

PRBS_debug PRBS_debug_inst0(
	.clk(gt0_txusrclk2_i),
	(* mark_debug = "true" *)
    .prbs_out(gt0_txdata_i)
	);
	

PRBS7Check prbs_source_check_inst_0(
  .clk(gt0_txusrclk2_i),
  .din(gt0_txdata_i),
  .mask(mask),
  .seed(seed),
  
  .prbs(prbs_from_check_to_check_source),
  .errorCounter(errorCount_to_check_source)
    );
 (* mark_debug = "true" *)  
wire  [6:0]   errorCount_to_check_source;

(* mark_debug = "true" *)
wire [63:0]   prbs_from_check_to_check_source;

rev_map rev_map_inst(
// map map_inst(
    .clk(gt0_txusrclk2_i),
    .bypass(bypass),
    .din(gt0_txdata_i),
    .dout(map_dout)
);
 
(* mark_debug = "true" *)
wire bypass;
(* mark_debug = "true" *)
wire     [63:0]  map_dout;



//----------------- Instantiate an gtwizard_0_exdes module  -----------------
//wire gt0_txusrclk2_i;
gtwizard_0_exdes gtwizard_0_exdes_i
(
    .Q2_CLK1_GTREFCLK_PAD_N_IN(SMA_MGT_REFCLK_N), 
    .Q2_CLK1_GTREFCLK_PAD_P_IN(SMA_MGT_REFCLK_P),
    /*.DRP_CLK_IN_P(clk_60MHz),
    .DRP_CLK_IN_N(clk_60MHz),*/
    .DRPCLK_IN(clk_60MHz),
    .TRACK_DATA_OUT("open"),//(track_data_i),
    .RXN_IN(RXN_IN),
    .RXP_IN(RXP_IN),
    .TXN_OUT(TXN_OUT),
    .TXP_OUT(TXP_OUT),
    .gt0_rxdata_i(gt0_rxdata_i),    //out
    .gt0_txdata_i(map_dout),    //in
    .gt0_txusrclk2_i( gt0_txusrclk2_i), //out       
    .gt0_rxusrclk2_i( gt0_rxusrclk2_i)  //out
);

(* mark_debug = "true" *)
wire [63:0] shifter_dout;


dataExtract dataAligner
(
    //Input
    .clk(gt0_rxusrclk2_i),
    .reset(SYS_RST),
    .din(gt0_rxdata_i),
    // .din(shifter_dout),
    .bypass(bypass),
    .mask(mask),
    .seed(seed),
    .user_mode(user_mode),

    //Output
    .foundFrames(foundFrames),
    .searchedFrames(searchedFrames),
    .alignAddr(alignAddr),
    .aligned(aligned),
    .errorCounter(errorCounter),
    .tot_align_err_count(tot_align_err_count),
    .errorFlag(errorFlag),
    .prbs_from_check(prbs_from_check),
    .errorBits(errorBits),
    .userBits(userBits),
    .usererrorBits(usererrorBits),
    .userdataBits(userdataBits),
    .userData(userData),
    .usererrorCounter(usererrorCounter),
    .tot_user_err_count(tot_user_err_count),
    .dout(dout)
);

assign seed = 7'h3F;


(* mark_debug = "true" *)
wire [7:0] userData;

(* mark_debug = "true" *)
wire [15:0] mask;

wire [6:0] seed;


(* mark_debug = "true" *)
wire  [3:0]   foundFrames;

(* mark_debug = "true" *)
wire  [8:0]   searchedFrames;

(* mark_debug = "true" *)
wire  [9:0]   alignAddr;

(* mark_debug = "true" *)        
wire          aligned;

(* mark_debug = "true" *)  
wire  [6:0]   errorCounter;

(* mark_debug = "true" *)  
wire  [23:0]    tot_align_err_count;

(* mark_debug = "true" *)
wire          errorFlag;

(* mark_debug = "true" *)
wire [63:0]   prbs_from_check;

(* mark_debug = "true" *)
wire [63:0]   errorBits;

(* mark_debug = "true" *)
wire [63:0]     usererrorBits;

(* mark_debug = "true" *)
wire [63:0]     userdataBits;

(* mark_debug = "true" *)
wire [6:0]     usererrorCounter;

(* mark_debug = "true" *)
wire [63:0]   userBits;

(* mark_debug = "true" *)
wire [23:0] tot_user_err_count;

(* mark_debug = "true" *)
wire [63:0] dout;

//---------------------------------------------------------< global_clock_reset
wire reset;
wire sys_clk;
wire clk_20MHz;
wire clk_50MHz;
wire clk_100MHz;
wire clk_160MHz;
wire clk_200MHz;
wire clk_60MHz;
global_clock_reset global_clock_reset_inst(
    .SYS_CLK_P(SYS_CLK_P),
    .SYS_CLK_N(SYS_CLK_N),
    .FORCE_RST(SYS_RST),
    // output
    .GLOBAL_RST(reset),
    .SYS_CLK(sys_clk),
    .CLK_OUT1(clk_25MHz),
    .CLK_OUT2(clk_50MHz),
    .CLK_OUT3(clk_100MHz),
    .CLK_OUT4(clk_160MHz),
    .CLK_OUT5(clk_200MHz),
    .CLK_OUT6(clk_60MHz)
  );    
//---------------------------------------------------------> global_clock_reset


//---------------------------------------------------------< generate sgmii_i clock
wire clk_sgmii_i;
wire clk_sgmii;
wire clk_125MHz;
IBUFDS_GTE2 #(
   .CLKCM_CFG("TRUE"),          // Refer to Transceiver User Guide
   .CLKRCV_TRST("TRUE"),        // Refer to Transceiver User Guide
   .CLKSWING_CFG(2'b11)         // Refer to Transceiver User Guide
)
IBUFDS_GTE2_inst (
   .O(clk_sgmii_i),             // 1-bit output: Refer to Transceiver User Guide
   .ODIV2("open"),              // 1-bit output: Refer to Transceiver User Guide
   .CEB(1'b0),                  // 1-bit input: Refer to Transceiver User Guide
   .I(SGMIICLK_Q0_P),           // 1-bit input: Refer to Transceiver User Guide
   .IB(SGMIICLK_Q0_N)           // 1-bit input: Refer to Transceiver User Guide
);

BUFG BUFG_inst (
   .O(clk_sgmii),               // 1-bit output: Clock output
   .I(clk_sgmii_i)              // 1-bit input: Clock input
);
assign clk_125MHz = clk_sgmii;
//---------------------------------------------------------> generate sgmii_i clock

//---------------------------------------------------------< control_interface
wire control_clk;
wire [35:0]control_fifo_q;
wire control_fifo_empty;
wire control_fifo_rdreq;
wire control_fifo_rdclk;

wire [35:0]cmd_fifo_q;
wire cmd_fifo_empty;
wire cmd_fifo_rdreq;

(* mark_debug = "true" *)
wire [511:0]config_reg;
wire [15:0]pulse_reg;
(* mark_debug = "true" *)
wire [175:0]status_reg;

wire control_mem_we;
wire [31:0]control_mem_addr;
wire [31:0]control_mem_din;

wire idata_data_fifo_rdclk;
wire idata_data_fifo_empty;
wire idata_data_fifo_rden;
wire [31:0]idata_data_fifo_dout;
assign control_clk = clk_100MHz;
control_interface  control_interface_inst(
   .RESET(reset),
   .CLK(control_clk),
  // From FPGA to PC
   .FIFO_Q(control_fifo_q),
   .FIFO_EMPTY(control_fifo_empty),
   .FIFO_RDREQ(control_fifo_rdreq),
   .FIFO_RDCLK(control_fifo_rdclk),
  // From PC to FPGA, FWFT
   .CMD_FIFO_Q(cmd_fifo_q),
   .CMD_FIFO_EMPTY(cmd_fifo_empty),
   .CMD_FIFO_RDREQ(cmd_fifo_rdreq),
  // Digital I/O
   .CONFIG_REG(config_reg),
   .PULSE_REG(pulse_reg),
   .STATUS_REG(status_reg),
  // Memory interface
   .MEM_WE(control_mem_we),
   .MEM_ADDR(control_mem_addr),
   .MEM_DIN(control_mem_din),
   .MEM_DOUT(),
  // Data FIFO interface, FWFT
   .DATA_FIFO_Q(idata_data_fifo_dout),
   .DATA_FIFO_EMPTY(idata_data_fifo_empty),
   .DATA_FIFO_RDREQ(idata_data_fifo_rden),
   .DATA_FIFO_RDCLK(idata_data_fifo_rdclk)
);
assign cmd_fifo_q = gig_eth_rx_fifo_q;
assign cmd_fifo_empty = gig_eth_rx_fifo_empty;
assign gig_eth_rx_fifo_rden = cmd_fifo_rdreq;

assign gig_eth_tx_fifo_wrclk = clk_125MHz;
assign control_fifo_rdclk = gig_eth_tx_fifo_wrclk;
assign gig_eth_tx_fifo_q = control_fifo_q[31:0];
assign gig_eth_tx_fifo_wren = ~control_fifo_empty;
assign control_fifo_rdreq = ~gig_eth_tx_fifo_full;
//---------------------------------------------------------> control_interface

wire [47:0]gig_eth_mac_addr;
wire [31:0]gig_eth_ipv4_addr;
wire [31:0]gig_eth_subnet_mask;
wire [31:0]gig_eth_gateway_ip_addr; 
wire [7:0]gig_eth_tx_tdata;
wire gig_eth_tx_tvalid;
wire gig_eth_tx_tready;
wire [7:0]gig_eth_rx_tdata;
wire gig_eth_rx_tvalid;
wire gig_eth_rx_tready;
wire gig_eth_tcp_use_fifo;
wire gig_eth_tx_fifo_wrclk;
wire [31:0]gig_eth_tx_fifo_q;
wire gig_eth_tx_fifo_wren;
wire gig_eth_tx_fifo_full;
wire gig_eth_rx_fifo_rdclk;
wire [31:0]gig_eth_rx_fifo_q;
wire gig_eth_rx_fifo_rden;
wire gig_eth_rx_fifo_empty;

assign gig_eth_mac_addr = {44'h000a3502a75,DIPSw4Bit[3:0]};
assign gig_eth_ipv4_addr = {28'hc0a8020,DIPSw4Bit[3:0]};
assign gig_eth_subnet_mask = 32'hffffff00;
assign gig_eth_gateway_ip_addr = 32'hc0a80201;
//assign gpio_high = 2'b11;
gig_eth gig_eth_inst
(
// asynchronous reset
   .GLBL_RST(reset),
// clocks
   .GTX_CLK(clk_125MHz),
   .REF_CLK(sys_clk),                           // 200MHz for IODELAY
// PHY interface
   .PHY_RESETN(PHY_RESET_N),
//         -- RGMII Interface
   .RGMII_TXD(RGMII_TXD),
   .RGMII_TX_CTL(RGMII_TX_CTL),
   .RGMII_TXC(RGMII_TXC),
   .RGMII_RXD(RGMII_RXD),
   .RGMII_RX_CTL(RGMII_RX_CTL),
   .RGMII_RXC(RGMII_RXC),
// MDIO Interface
   .MDIO(MDIO),
   .MDC(MDC),
// TCP
   .MAC_ADDR(gig_eth_mac_addr),
   .IPv4_ADDR(gig_eth_ipv4_addr),
   .IPv6_ADDR(128'h0),
   .SUBNET_MASK(gig_eth_subnet_mask),
   .GATEWAY_IP_ADDR(gig_eth_gateway_ip_addr),
   .TCP_CONNECTION_RESET(1'b0),
   .TX_TDATA(gig_eth_tx_tdata),
   .TX_TVALID(gig_eth_tx_tvalid),
   .TX_TREADY(gig_eth_tx_tready),
   .RX_TDATA(gig_eth_rx_tdata),
   .RX_TVALID(gig_eth_rx_tvalid),
   .RX_TREADY(gig_eth_rx_tready),
//fifo8to32 and fifo32to8
   .TCP_USE_FIFO(gig_eth_tcp_use_fifo),
   .TX_FIFO_WRCLK(gig_eth_tx_fifo_wrclk),
   .TX_FIFO_Q(gig_eth_tx_fifo_q),
   .TX_FIFO_WREN(gig_eth_tx_fifo_wren),
   .TX_FIFO_FULL(gig_eth_tx_fifo_full),
   .RX_FIFO_RDCLK(gig_eth_rx_fifo_rdclk),
   .RX_FIFO_Q(gig_eth_rx_fifo_q),
   .RX_FIFO_RDEN(gig_eth_rx_fifo_rden),
   .RX_FIFO_EMPTY(gig_eth_rx_fifo_empty)
);
assign gig_eth_tcp_use_fifo = 1'b1;
assign gig_eth_rx_fifo_rdclk = control_clk;
//---------------------------------------------------------> gig_eth

//---------------------------------------------------------< IIC
wire START;
wire [1:0]MODE;
wire SL_WR;
wire [6:0]SL_ADDR;
wire [7:0]WR_ADDR;
wire [7:0]WR_DATA0;
wire [7:0]WR_DATA1;
wire [7:0]RD_DATA0;
wire [7:0]RD_DATA1;
wire SDA_OUT;
wire SDA_IN;
wire SDA_T;

assign START = pulse_reg[0];
assign MODE = config_reg[2*32+25:2*32+24];
assign SL_ADDR = config_reg[2*32+23:2*32+17];
assign SL_WR = config_reg[2*32+16];
assign WR_ADDR = config_reg[2*32+15:2*32+8];
assign WR_DATA0 = config_reg[2*32+7:2*32+0];
assign status_reg[15:0] = {RD_DATA1,RD_DATA0};
i2c_wr_bytes i2c_wr_bytes_inst(
.CLK(clk_50MHz),                       //system clock 50Mhz
.RESET(reset),                          //active high reset
.START(START),                          //the rising edge trigger a start, generate by config_reg
.MODE(MODE),                            //'0' is 1 bytes read or write, '1' is 2 bytes read or write,
                                        //'2' is 3 bytes write only , don't set to '3'
.SL_WR(SL_WR),                          //'0' is write, '1' is read
.SL_ADDR(SL_ADDR),                      //slave addr
.WR_ADDR(WR_ADDR),                      //chip internal addr for read and write
.WR_DATA0(WR_DATA0),                    //first byte data for write
.WR_DATA1(WR_DATA1),                    //second byte data for write
.RD_DATA0(RD_DATA0),                    //first byte readout
.RD_DATA1(RD_DATA1),                    //second byte readout
.BUSY("open"),                          //indicates transaction in progress
.SDA_in(SDA),                           //serial data input of i2c bus
.SDA_out(SDA_OUT),                      //serial data output of i2c bus
.SDA_T(SDA_T),                          //serial data direction of i2c bus
.SCL(SCL)                               //serial clock output of i2c bus
);
assign SDA = SDA_T ? 1'bz : SDA_OUT;
//---------------------------------------------------------> IIC

//IIC uses config_reg[89:64]

//---------------------------------------------------------> Rx Bit_error readout
//wire [2:0]channel_select;
//wire [7:0] Rx0_Error_bit_Init = config_reg[6*16+7:6*16];
//wire [7:0] Rx1_Error_bit_Init = config_reg[6*16+15:6*16+8];
//wire [7:0] Rx2_Error_bit_Init = config_reg[7*16+7:7*16];
//wire [7:0] Rx3_Error_bit_Init = config_reg[7*16+15:7*16+8];
//wire [7:0] Rx4_Error_bit_Init = config_reg[8*16+7:8*16];
//wire [7:0] Rx5_Error_bit_Init = config_reg[8*16+15:8*16+8];
//wire [7:0] Rx6_Error_bit_Init = config_reg[9*16+7:9*16];
//wire [7:0] Tx0_Error_bit_Init = config_reg[9*16+15:9*16+8];

//error bit init uses config reg[159:96]

wire [7:0] tot_align_err_count_Init = config_reg[6*16+7:6*16];
reg [23:0] eth_tot_align_err_count;
reg [23:0] eth_tot_user_err_count;
reg [6:0] eth_err_count;
reg eth_aligned;
reg [7:0] eth_userData;
//////////////////TEST///////////////////////////////////////////
always @ (clk_60MHz)
begin
    tot_align_err_count_test <= tot_align_err_count_test + 1;
end
reg [23:0] tot_align_err_count_test;
/////////////////TEST///////////////////////////////////////////

always @ (channel_select)
begin
    eth_err_count = errorCounter;
    eth_tot_align_err_count = tot_align_err_count;
    eth_tot_user_err_count = tot_user_err_count;
    eth_aligned = aligned;
    eth_userData= userData;
//    Channel_Bit_Error_Output_reg = tot_align_err_count_test;

end
//assign status_reg[79:16] = Channel_Bit_Error_Output_reg;

//total registers is 11, starts from reg(0), but i2c is over reg(0), do not use it

assign status_reg[47:16] = eth_tot_align_err_count;  //on eth python program: reg 1&2
assign status_reg[79:48] = eth_tot_user_err_count;   //on eth python program: reg 3&4
assign status_reg[95:80] = eth_err_count;   //on eth python program: reg 5
assign status_reg[111:96] = eth_aligned;   //on eth python program: reg 6
assign status_reg[127:112] = eth_userData;   //on eth python program: reg 7



assign channel_select = config_reg[2:0];
//always @(channel_select)
//begin
//    case(channel_select)
//        3'b000 : Channel_Bit_Error_Output_reg = Rx0_Error_bit_Count + Rx0_Error_bit_Init;
//        3'b001 : Channel_Bit_Error_Output_reg = Rx1_Error_bit_Count + Rx1_Error_bit_Init;
//        3'b010 : Channel_Bit_Error_Output_reg = Rx2_Error_bit_Count + Rx2_Error_bit_Init;
//        3'b011 : Channel_Bit_Error_Output_reg = Rx3_Error_bit_Count + Rx3_Error_bit_Init;
//        3'b100 : Channel_Bit_Error_Output_reg = Rx4_Error_bit_Count + Rx4_Error_bit_Init;
//        3'b101 : Channel_Bit_Error_Output_reg = Rx5_Error_bit_Count + Rx5_Error_bit_Init;
//        3'b110 : Channel_Bit_Error_Output_reg = Rx6_Error_bit_Count + Rx6_Error_bit_Init;
//        3'b111 : Channel_Bit_Error_Output_reg = Tx0_Error_bit_Count + Tx0_Error_bit_Init;
//        default: Channel_Bit_Error_Output_reg = Rx0_Error_bit_Count;
//    endcase
//end
//Channel_Bit_Error_Output_reg = tot_align_err_count + Rx0_Error_bit_Init;

//---------------------------------------------------------> Rx Bit_error readout
//---------------------------------------------------------< VIO 

vio_0 vio_0_inst (
  .clk(clk_60MHz),                // input wire clk
  .probe_out0(mask),  
  .probe_out1(bypass),
  .probe_out2(SYS_RST),
  .probe_out3(user_mode)
);

(* mark_debug = "true" *)
wire SYS_RST;

(* mark_debug = "true" *)
wire [1:0] user_mode;

//assign mask = 16'h8000;
//---------------------------------------------------------> VIO 
endmodule