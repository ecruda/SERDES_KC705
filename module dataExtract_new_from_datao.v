module dataExtract
(
input clk, 
input reset,
input [31:0] din,
input bypass,
input [15:0] mask, //masked bits are user data, the unmasked bits are used for data aligmnment.
output [3:0] foundFrames,
output [8:0] searchedFrames,
output [9:0] alignAddr, //10 bits 
output aligned, 
output [5:0] errorCounter, 
output [24:0] tot_err_count,
output errorFlag,
output [31:0] prbs_from_check, 
output [31:0] errorBits,
output [31:0] dout
);

// reg [63:0] dataBuf;
reg [1023+32:0] dataBuf;

always @(posedge clk) 
// always @(negedge clk) 


begin
dataBuf[63:32] <= din; 
dataBuf[31:0] <= dataBuf[63:32];
end

reg [3:0] foundFrames; //found header id in 256 data records.
reg [8:0] searchedFrames; //if do not find a id in 256 data records, move on
reg [3:0] failureTimes; //failureTimes after synched. 
reg synched; //synched status or not
assign aligned = synched;

reg [9:0] alignAddr;


reg [31:0] raw_dout;
wire [31:0] raw_net;

generate
genvar i;
for (i = 0 ; i < 32; i= i+1 )
begin
assign raw_net[i] = dataBuf[alignAddr+i];
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
// reg [31:0] prbs_from_check;
wire errorFlag = (errorCounter != 6'h00);

always @(posedge clk) 
begin
if(reset)
begin
foundFrames <= 4'h0;
failureTimes <= 4'h0;
synched <= 1'b0;
alignAddr <= 5'h00;
searchedFrames <= 9'h000;
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
failureTimes <= 4'h0;
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


module PRBS7Check
(
input clk, //40MHz
input [31:0] din,
input [15:0] mask,
input reset,
input [6:0] seed,
output reg [31:0] prbs,
output [31:0] errorBits,
output [5:0] errorCounter //error flag if it is not prbs7
);

/*
reg [6:0] r;
always @(posedge clk) 
begin
r <= din[31:32-7]; //only keep the last 7 bits
end

wire [6:0] c [32:0]; //chain for iteration
wire [31 : 0] prbsNet;
generate
genvar i;
for (i = 0 ; i < 32; i = i + 1)
begin : loop_itr
assign prbsNet[i] = c[i][1]^c[i][0]; 
assign c[i+1] = {prbsNet[i],c[i][6:1]}; //LSB out, 
end
endgenerate
assign c[0] = r;
*/
PRBS7 #(.WORDWIDTH(32)) prbs1Inst
(
.clk(clk),
.reset(reset),
.dis(1'b0),
.seed(seed),
.prbs(prbs)
); 


reg [32-1:0] errorBits;
reg [31:0] din1D;


reg [5:0] c1 [7:0];
reg [5:0] c2 [3:0];
reg [5:0] c3 [1:0];
reg [5:0] c4;
always @(posedge clk)
begin
din1D <= din;
prbs <= prbsNet;
// errorBits <= prbs ^ din1D;
errorBits <= (prbs ^ din1D) & {~mask,~mask};

c1[0] <= {5'd0,errorBits[0]}+
{5'd0,errorBits[1]}+
{5'd0,errorBits[2]}+
{5'd0,errorBits[3]};
c1[1] <= {5'd0,errorBits[4]}+
{5'd0,errorBits[5]}+
{5'd0,errorBits[6]}+
{5'd0,errorBits[7]};
c1[2] <= {5'd0,errorBits[8]}+
{5'd0,errorBits[9]}+
{5'd0,errorBits[10]}+
{5'd0,errorBits[11]};
c1[3] <= {5'd0,errorBits[12]}+
{5'd0,errorBits[13]}+
{5'd0,errorBits[14]}+
{5'd0,errorBits[15]};
c1[4] <= {5'd0,errorBits[16]}+
{5'd0,errorBits[17]}+
{5'd0,errorBits[18]}+
{5'd0,errorBits[19]};
c1[5] <= {5'd0,errorBits[20]}+
{5'd0,errorBits[21]}+
{5'd0,errorBits[22]}+
{5'd0,errorBits[23]};
c1[6] <= {5'd0,errorBits[24]}+
{5'd0,errorBits[25]}+
{5'd0,errorBits[26]}+
{5'd0,errorBits[27]};
c1[7] <= {5'd0,errorBits[28]}+
{5'd0,errorBits[29]}+
{5'd0,errorBits[30]}+
{5'd0,errorBits[31]};

c2[0] <= c1[0] + c1[1];
c2[1] <= c1[2] + c1[3];
c2[2] <= c1[4] + c1[5];
c2[3] <= c1[6] + c1[7];

c3[0] <= c2[0] + c2[1];
c3[1] <= c2[2] + c2[3]; 

c4 <= c3[0] + c3[1];

end
//assign errorBits = prbs ^ din; 
//assign error = (prbs != din);
assign errorCounter = c4;
/* assign errorCounter = {5'd0,errorBits[0]}+
{5'd0,errorBits[1]}+
{5'd0,errorBits[2]}+
{5'd0,errorBits[3]}+
{5'd0,errorBits[4]}+
{5'd0,errorBits[5]}+
{5'd0,errorBits[6]}+
{5'd0,errorBits[7]}+
{5'd0,errorBits[8]}+
{5'd0,errorBits[9]}+
{5'd0,errorBits[10]}+
{5'd0,errorBits[11]}+
{5'd0,errorBits[12]}+
{5'd0,errorBits[13]}+
{5'd0,errorBits[14]}+
{5'd0,errorBits[15]}+
{5'd0,errorBits[16]}+
{5'd0,errorBits[17]}+
{5'd0,errorBits[18]}+
{5'd0,errorBits[19]}+
{5'd0,errorBits[20]}+
{5'd0,errorBits[21]}+
{5'd0,errorBits[22]}+
{5'd0,errorBits[23]}+
{5'd0,errorBits[24]}+
{5'd0,errorBits[25]}+
{5'd0,errorBits[26]}+
{5'd0,errorBits[27]}+
{5'd0,errorBits[28]}+
{5'd0,errorBits[29]}+
{5'd0,errorBits[30]}+
{5'd0,errorBits[31]};
*/
endmodule