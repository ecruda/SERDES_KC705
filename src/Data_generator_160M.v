`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2020 08:00:25 PM
// Design Name: 
// Module Name: Data_generator_160M
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Data_generator_160M(
input clock,                // 160M clock signal
input reset,                // system reset signal
input pulse,
output Data_OUTP,
output Data_OUTN,
input Data_INP,
input Data_INN,
output [63:0] Error_bit_Count
    );
//--------------------------------------------> Counter    
reg [5:0] count;
reg clk5M;
always @(posedge clock or posedge reset)
begin
    if(reset)
    begin
        count <= 6'b000000;
        clk5M <= 1'b0;
    end
    else
    begin
        if(count == 6'd15)
        begin
            count <= 6'b000000;
            clk5M <= ~clk5M;
        end
        else
            count <= count + 1'b1;
    end
end
//--------------------------------------------> Counter

//--------------------------------------------< PRBS31Gen32b
wire [31:0] PRBS31Gen32b;
PRBS31Gen32b PRBS31Gen32b_inst(
.clk(clk5M),
.random(PRBS31Gen32b)
);

//--------------------------------------------> PRBS31Gen32b

//--------------------------------------------< SER32b
wire DataOut;
wire Clk_Out;
SER32b SER32b_inst(
.CLKBit(clock),
.RSTn(!reset),
.DataIn(PRBS31Gen32b),
.CLKWord(Clk_Out),
.DataOut(DataOut)
);
//--------------------------------------------> SER32b

//--------------------------------------------< DESER32b
wire DataIn;
wire [31:0] DESER_OUT;
DESER32b DESER32b_inst(
.CLKBit(clock),
.RSTn(!reset),
.DataIn(DataIn),
.DataOut(DESER_OUT)
);
//--------------------------------------------> DESER32b

//--------------------------------------------< Data bit checker
Tx_PRBS31_Data_Checker Tx_PRBS31_Data_Checker_inst(
.clock(clk5M),          // Data check clock
.reset(reset),
.pulse(pulse),
.DataIn(DESER_OUT),     // Deserial output data
.Error_bit_Count(Error_bit_Count)
    );
//--------------------------------------------> Data bit checker
IBUFDS #(
  .DIFF_TERM("FALSE"),       // Differential Termination
  .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
  .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
) IBUFDS_inst (
  .O(DataIn),  // Buffer output
  .I(Data_INP),  // Diff_p buffer input (connect directly to top-level port)
  .IB(Data_INN) // Diff_n buffer input (connect directly to top-level port)
);
// L1ACC single-ended to differential
OBUFDS #(
  .IOSTANDARD("LVDS18"),    // Specify the output I/O standard
  .SLEW("SLOW")             // Specify the output slew rate
) OBUFDS_L1ACC_inst(
  .O(Data_OUTP),           // Diff_p output (connect directly to top-level port)
  .OB(Data_OUTN),          // Diff_n output (connect directly to top-level port)
  .I(DataOut)                 // Buffer input 
); 
//--------------------------------------------< SER32b
endmodule
