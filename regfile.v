//32-bit common integer register with read-operation of 2 Reg & write-operation of 1 Reg

`include "defines.v"

module regfile(
	input wire				clk,
	input wire				rst,

	//from wb
	input wire				we,
	input wire[`RegAddrBus]	wd,
	input wire[`RegBus]		wdata,

	//from id
	input wire				rs1e_i,
	input wire[`RegAddrBus]	rs1addr_i,
	output reg[`RegBus]		rs1data_o,
	
	input wire				rs2e_i,
	input wire[`RegAddrBus]	rs2addr_i,
	output reg[`RegBus]		rs2data_o
);

reg[`RegBus] regs[0:`RegNum-1];

	always @(posedge clk) begin
		if (rst == `RstDisable) begin
			if ((we == `WriteEnable) && (wd != `RegNumLog2'h0)) begin //0-Reg cannot be written
				regs[wd] <= wdata;
			end
			
		end
	end

	always @(*) begin
		if ((rst == `RstEnable) || (rs1addr_i == `RegNumLog2'h0)) begin
			rs1data_o = `ZeroWord;
		end else if ((we == `WriteEnable) && (rs1e_i == `ReadEnable) && (rs1addr_i == wd)) begin
			rs1data_o = wdata; //To assure data is up-to-date
		end else if (rs1e_i == `ReadEnable) begin
			rs1data_o = regs[rs1addr_i];
		end else begin
			rs1data_o = `ZeroWord;
		end
	end

	always @(*) begin
		if ((rst == `RstEnable) || (rs2addr_i == `RegNumLog2'h0)) begin
			rs2data_o = `ZeroWord;
		end else if ((we == `WriteEnable) && (rs2e_i == `ReadEnable) && (rs2addr_i == wd)) begin
			rs2data_o = wdata; //To assure data is up-to-date
		end else if (rs2e_i == `ReadEnable) begin
			rs2data_o = regs[rs2addr_i];
		end else begin
			rs2data_o = `ZeroWord;
		end
	end

integer i;

	always @(*) begin
		if (rst) begin
			for (i = 0; i < 32; i = i + 1)
				regs[i] = `ZeroWord;
		end else if ((we == `WriteEnable) && (wd != `RegNumLog2'h0)) begin
			regs[wd] = wdata;
		end
	end
endmodule