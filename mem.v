`include "defines.v"

module mem(
	input wire 					rst,

	//data from ex
	input wire 					we_i,
	input wire[`RegAddrBus]		wd_i,
	input wire[`RegBus]			wdata_i,

	input wire 					meme_i,
	input wire 					memrw_i,
	input wire 					memsigned_i,
	input wire[`DataBusLog]		memwide_i,
	input wire[`RegBus] 		memaddr_i,
	input wire[`DataBus]		memdata_i,

	//data to send to the next stage
	output reg 					we_o,
	output reg[`RegAddrBus]		wd_o,
	output reg[`RegBus]			wdata_o,

	//interaction with mem_ctrl
	output reg 					meme_o,
	output reg 					memrw_o,
	output reg 					memsigned_o,
	output reg[`DataBusLog] 	memwide_o,
	output reg[`RegBus] 		memaddr_o,
	output reg[`DataBus] 		memdata_o,
	input wire 					memready_i,
	input wire[`DataBus] 		memresult_i,

	//forwarding
	output reg 					fwd_we_o,
	output reg[`RegAddrBus]		fwd_wd_o,
	output reg[`RegBus] 		fwd_wdata_o,

	//stall request
	output reg 					stall_from_mem
);

	always @(*) begin
		if (rst) begin
			meme_o 			<= `MemoryDisable;
			memrw_o			<= `MemoryRead;
			memsigned_o 	<= `MemoryNoSignedExtend;
			memwide_o 		<= `Memory0bits;
			memaddr_o		<= `ZeroWord;
			memdata_o		<= `ZeroWord;
			stall_from_mem 	<= `NoStop;
		end else if (meme_i) begin
			meme_o 			<= meme_i;
			memrw_o			<= memrw_i;
			memsigned_o		<= memsigned_i;
			memwide_o		<= memwide_i;
			memaddr_o		<= memaddr_i;
			memdata_o 		<= memdata_i;
			stall_from_mem 	<= `Stop;
		end else begin
			meme_o 			<= `MemoryDisable;
			memrw_o			<= `MemoryRead;
			memsigned_o 	<= `MemoryNoSignedExtend;
			memwide_o 		<= `Memory0bits;
			memaddr_o		<= `ZeroWord;
			memdata_o		<= `ZeroWord;
			stall_from_mem 	<= `NoStop;
		end

		if (memready_i)
			stall_from_mem 	<= `NoStop;

		if (rst) begin
			we_o 		<= `WriteDisable;
			wd_o 		<= `ZeroWord;
			wdata_o 	<= `ZeroWord;
			fwd_we_o 	<= `WriteDisable;
			fwd_wd_o 	<= `ZeroWord;
			fwd_wdata_o <= `ZeroWord;
		end else if (memready_i && memrw_i == `MemoryRead) begin
			we_o 		<= meme_i;
			wd_o 		<= wd_i;
			wdata_o 	<= memresult_i;
			fwd_we_o 	<= meme_i;
			fwd_wd_o 	<= wd_i;
			fwd_wdata_o <= memresult_i;
		end else begin
			we_o 		<= we_i;
			wd_o 		<= wd_i;
			wdata_o 	<= wdata_i;
			fwd_we_o 	<= `WriteDisable;
			fwd_wd_o 	<= `ZeroWord;
			fwd_wdata_o <= `ZeroWord;
		end
	end

endmodule