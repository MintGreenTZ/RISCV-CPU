`include "defines.v"

module mem_wb(
	input wire					clk,
	input wire 					rst,
	input wire[`StallBus] 		stall,

	input wire 					mem_we,
	input wire[`RegAddrBus]		mem_wd,
	input wire[`RegBus]			mem_wdata,

	output reg 					wb_we,
	output reg[`RegAddrBus]		wb_wd,
	output reg[`RegBus]			wb_wdata
);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			wb_we		<= `WriteDisable;
			wb_wd		<= `ZeroWord;
			wb_wdata	<= `ZeroWord;
		end else if (stall[4] == `Stop && stall[5] == `NoStop) begin
			wb_we		<= `WriteDisable;
			wb_wd		<= `ZeroWord;
			wb_wdata	<= `ZeroWord;
		end else if (stall[4] == `NoStop) begin
			wb_we		<= mem_we;
			wb_wd		<= mem_wd;
			wb_wdata	<= mem_wdata;
		end
	end

endmodule