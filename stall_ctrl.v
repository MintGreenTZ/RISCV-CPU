`include "defines.v"

module stall_ctrl(
	input wire				rst,
	input wire 				stall_from_if,
	input wire 				stall_from_mem,

	output reg[`StallBus]	stall
);

	always @(*) begin
		if (rst) begin
			stall 	= 6'b000000;
		end else if (stall_from_mem) begin
			stall 	= 6'b111111;
		end else if (stall_from_if) begin
			stall 	= 6'b000011;
		end else begin
			stall 	= 6'b000000;
		end
	end

endmodule