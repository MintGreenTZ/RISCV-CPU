`include "defines.v"

module ex_mem(
	input wire					clk,
	input wire 					rst,
	input wire[`StallBus] 		stall,

	input wire 					ex_we,
	input wire[`RegAddrBus]		ex_wd,
	input wire[`RegBus]			ex_wdata,

	input wire 					ex_meme,
	input wire 					ex_memrw,
	input wire 					ex_memsigned,
	input wire[`DataBusLog]		ex_memwide,
	input wire[`RegBus] 		ex_memaddr,
	input wire[`DataBus] 		ex_memdata,

	output reg 					mem_we,
	output reg[`RegAddrBus]		mem_wd,
	output reg[`RegBus]			mem_wdata,

	output reg 					mem_meme,
	output reg 					mem_memrw,
	output reg 					mem_memsigned,
	output reg[`DataBusLog]		mem_memwide,
	output reg[`RegBus] 		mem_memaddr,
	output reg[`DataBus] 		mem_memdata
);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			mem_we			<= `WriteDisable;
			mem_wd			<= `ZeroWord;
			mem_wdata		<= `ZeroWord;
			mem_meme		<= `MemoryDisable;
			mem_memrw		<= `MemoryRead;
			mem_memsigned	<= `MemoryNoSignedExtend;
			mem_memwide		<= `Memory0bits;
			mem_memaddr		<= `ZeroWord;
			mem_memdata 	<= `ZeroWord;
		end else if (stall[3] == `Stop && stall[4] == `NoStop) begin
			mem_we			<= `WriteDisable;
			mem_wd			<= `ZeroWord;
			mem_wdata		<= `ZeroWord;
			mem_meme		<= `MemoryDisable;
			mem_memrw		<= `MemoryRead;
			mem_memsigned	<= `MemoryNoSignedExtend;
			mem_memwide		<= `Memory0bits;
			mem_memaddr		<= `ZeroWord;
			mem_memdata 	<= `ZeroWord;
		end else if (stall[3] == `NoStop) begin
			mem_we			<= ex_we;
			mem_wd			<= ex_wd;
			mem_wdata		<= ex_wdata;
			mem_meme		<= ex_meme;
			mem_memrw		<= ex_memrw;
			mem_memsigned	<= ex_memsigned;
			mem_memwide		<= ex_memwide;
			mem_memaddr		<= ex_memaddr;
			mem_memdata 	<= ex_memdata;
		end
	end

endmodule