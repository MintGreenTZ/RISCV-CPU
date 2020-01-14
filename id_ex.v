`include "defines.v"

module id_ex(
	input wire					clk,
	input wire 					rst,
	input wire[`StallBus] 		stall,

	input wire[`RegBus]			id_reg1,
	input wire[`RegBus]			id_reg2,
	input wire 					id_we,
	input wire[`RegAddrBus]		id_wd,
	input wire[`OpCodeBus]		id_opcode,
	input wire[`InstBus]		id_pc,
	input wire[`RegBus] 		id_imm,

	output reg[`RegBus]			ex_reg1,
	output reg[`RegBus]			ex_reg2,
	output reg 					ex_we,
	output reg[`RegAddrBus]		ex_wd,
	output reg[`OpCodeBus]		ex_opcode,
	output reg[`InstBus]		ex_pc,
	output reg[`RegBus] 		ex_imm
);
	
	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			ex_reg1		<= `ZeroWord;
			ex_reg2		<= `ZeroWord;
			ex_we		<= `WriteDisable;
			ex_wd		<= `NOPRegAddr;
			ex_opcode	<= `OpNothing;
			ex_pc		<= `ZeroWord;
			ex_imm 		<= `ZeroWord;
		end else if (stall[2] == `Stop && stall[3] == `NoStop) begin
			ex_reg1		<= `ZeroWord;
			ex_reg2		<= `ZeroWord;
			ex_we		<= `WriteDisable;
			ex_wd		<= `NOPRegAddr;
			ex_opcode	<= `OpNothing;
			ex_pc		<= `ZeroWord;
			ex_imm 		<= `ZeroWord;
		end else if (stall[2] == `NoStop) begin
			ex_reg1		<= id_reg1;
			ex_reg2		<= id_reg2;
			ex_we		<= id_we;
			ex_wd		<= id_wd;
			ex_opcode	<= id_opcode;
			ex_pc		<= id_pc;
			ex_imm 		<= id_imm;
		end
	end

endmodule