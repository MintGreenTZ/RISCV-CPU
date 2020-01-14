`include "defines.v"

module pc_reg(
	input wire					clk,
	input wire					rst,
	input wire[`StallBus] 		stall,
	output reg[7:0] 			count,

	//jump order from id
	input wire					jumpe_i,
	input wire[`InstAddrBus]	jumpaddr_i,

	//interaction with mem_ctrl
	output reg 					ife,
	output reg[`InstAddrBus]	pc,
	output reg 					reorder_jump,
	input wire 					ifready_i,
	input wire[`DataBus] 		ifdata_i,

	//stall request
	output reg 					stall_from_if
);

	always @(posedge clk) begin
		if (rst) begin
			count			= 8'b00000000;
		end else if (ifready_i) begin
			count			= count + {{7{1'b0}}, ifdata_i[6] ^ 1'b1};
		end else begin
			count 			= count + 8'b00000000;
		end

		if (jumpe_i) begin
			reorder_jump	= `Reorder;
		end else begin
			reorder_jump 	= `NoReorder;
		end

		if (ifready_i) begin
			stall_from_if 	= `NoStop;
			ife 			= `MemoryDisable;
		end	

		if (rst) begin
			ife 			= `MemoryEnable;
			pc 				= 32'h00000000;
			stall_from_if 	= `Stop;
		end else if (jumpe_i) begin
			ife 			= `MemoryEnable;
			pc 				= jumpaddr_i;
			stall_from_if 	= `Stop;
		end else if (stall[0] == `NoStop) begin
			ife 			= `MemoryEnable;
			pc 				= pc + `FourWord;
			stall_from_if 	= `Stop;
		end else begin
			pc 				= pc + `ZeroWord;
		end
	end

endmodule