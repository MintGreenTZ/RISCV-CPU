`include "defines.v"

module id(
	input wire					rst,
	input wire[`InstBus]		pc_i,
	input wire[`InstBus]		inst_i,

	//send request to Regfile
	output reg 					rs1e_o,
	output reg 					rs2e_o,
	output reg[`RegAddrBus]		rs1addr_o,
	output reg[`RegAddrBus]		rs2addr_o,

	//get data from Regfile
	input wire[`RegBus]			rs1data_i,
	input wire[`RegBus]			rs2data_i,

	//data get from forwarding
	input wire 					fwdex_we_i,
	input wire[`RegAddrBus]		fwdex_wd_i,
	input wire[`RegBus] 		fwdex_wdata_i,
	input wire 					fwdmem_we_i,
	input wire[`RegAddrBus]		fwdmem_wd_i,
	input wire[`RegBus] 		fwdmem_wdata_i,

	//data to send to the next stage
	output reg[`RegBus]			reg1_o,
	output reg[`RegBus]			reg2_o,
	output reg 					we_o,
	output reg[`RegAddrBus]		wd_o,
	output reg[`OpCodeBus]		opcode_o,
	output reg[`InstBus]		pc_o,
	output reg[`RegBus]			imm_o,

	//jump pulse (give to if)
	output reg 					jumpe_o,
	output reg[`InstAddrBus] 	jumpaddr_o
);

	wire[6:0] 	opcode;
	wire[2:0] 	func3;
	wire 		func7;
	wire[4:0]	rs1;
	wire[4:0]	rs2;
	wire[4:0]	rd;

	assign 	opcode 	= inst_i[6:0];
	assign 	func3 	= inst_i[14:12];
	assign 	func7 	= inst_i[30];
	assign	rs1 	= inst_i[19:15];
	assign	rs2 	= inst_i[24:20];
	assign	rd 		= inst_i[11:7];

	reg instvalid;

	//???!!! instvalid = InstInvalid?

	always @(*) begin
		pc_o = pc_i;
		if (rst == `RstEnable) begin
			instvalid	= `InstValid;
			imm_o		= 32'h0;
			rs1e_o		= `ReadDisable;
			rs2e_o		= `ReadDisable;
			rs1addr_o	= `NOPRegAddr;
			rs2addr_o	= `NOPRegAddr;
			we_o		= `WriteDisable;
			wd_o		= `NOPRegAddr;
			opcode_o 	= `OpNothing;
			jumpe_o		= `JumpDisable;
			jumpaddr_o	= `ZeroAddr;
		end
		else begin
			case(opcode)
				//R
				7'b0010011:begin
					case(func3)
						3'b000:begin//ADDI
							instvalid	= `InstValid;
							imm_o 		= {{20{inst_i[31]}}, inst_i[31:20]};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpPlus;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b010:begin//SLTI
							instvalid	= `InstValid;
							imm_o 		= {{20{inst_i[31]}}, inst_i[31:20]};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLessThanImm;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b011:begin//SLTIU
							instvalid	= `InstValid;
							imm_o 		= {{20{inst_i[31]}}, inst_i[31:20]};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLessThanImmUnsigned;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b100:begin//XORI
							instvalid	= `InstValid;
							imm_o 		= {{20{inst_i[31]}}, inst_i[31:20]};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpXor;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b110:begin//ORI
							instvalid	= `InstValid;
							imm_o 		= {{20{inst_i[31]}}, inst_i[31:20]};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpOr;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b111:begin//ANDI
							instvalid	= `InstValid;
							imm_o 		= {{20{inst_i[31]}}, inst_i[31:20]};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpAnd;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b001:begin//SLLI
							instvalid	= `InstValid;
							imm_o 		= {{27{1'b0}},rs2};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLogicLeft;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b101:begin
							case(func7)
								1'b0:begin//SRLI
									instvalid	= `InstValid;
									imm_o 		= {{27{1'b0}},rs2};
									rs1e_o		= `ReadEnable;
									rs2e_o		= `ReadDisable;
									rs1addr_o	= rs1;
									rs2addr_o	= `NOPRegAddr;
									we_o		= `WriteEnable;
									wd_o		= rd;
									opcode_o	= `OpLogicRight;
									jumpe_o		= `JumpDisable;
									jumpaddr_o	= `ZeroAddr;
								end
								1'b1:begin//SRAI
									instvalid	= `InstValid;
									imm_o 		= {{27{1'b0}},rs2};
									rs1e_o		= `ReadEnable;
									rs2e_o		= `ReadDisable;
									rs1addr_o	= rs1;
									rs2addr_o	= `NOPRegAddr;
									we_o		= `WriteEnable;
									wd_o		= rd;
									opcode_o	= `OpArithmeticRight;
									jumpe_o		= `JumpDisable;
									jumpaddr_o	= `ZeroAddr;
								end
							endcase
						end
					endcase
				end
				7'b0110011:begin
					imm_o = `ZeroWord;
					case(func3)
						3'b000:begin
							case(func7)
								1'b0:begin//ADD
									instvalid	= `InstValid;
									rs1e_o		= `ReadEnable;
									rs2e_o		= `ReadEnable;
									rs1addr_o	= rs1;
									rs2addr_o	= rs2;
									we_o		= `WriteEnable;
									wd_o		= rd;
									opcode_o	= `OpPlus;
									jumpe_o		= `JumpDisable;
									jumpaddr_o	= `ZeroAddr;
								end
								1'b1:begin//SUB
									instvalid	= `InstValid;
									rs1e_o		= `ReadEnable;
									rs2e_o		= `ReadEnable;
									rs1addr_o	= rs1;
									rs2addr_o	= rs2;
									we_o		= `WriteEnable;
									wd_o		= rd;
									opcode_o	= `OpMinus;
									jumpe_o		= `JumpDisable;
									jumpaddr_o	= `ZeroAddr;
								end
							endcase
						end
						3'b001:begin//SLL
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLogicLeft;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b010:begin//SLT
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLessThanImm;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b011:begin//SLTU
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLessThanImmUnsigned;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b100:begin//XOR
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpXor;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b101:begin
							case(func7)
								1'b0:begin//SRL
									instvalid	= `InstValid;
									rs1e_o		= `ReadEnable;
									rs2e_o		= `ReadEnable;
									rs1addr_o	= rs1;
									rs2addr_o	= rs2;
									we_o		= `WriteEnable;
									wd_o		= rd;
									opcode_o	= `OpLogicRight;
									jumpe_o		= `JumpDisable;
									jumpaddr_o	= `ZeroAddr;
								end
								1'b1:begin//SRA
									instvalid	= `InstValid;
									rs1e_o		= `ReadEnable;
									rs2e_o		= `ReadEnable;
									rs1addr_o	= rs1;
									rs2addr_o	= rs2;
									we_o		= `WriteEnable;
									wd_o		= rd;
									opcode_o	= `OpArithmeticRight;
									jumpe_o		= `JumpDisable;
									jumpaddr_o	= `ZeroAddr;
								end
							endcase
						end
						3'b110:begin//OR
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpOr;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b111:begin//AND
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpAnd;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
					endcase
				end
				//I
				7'b1100111:begin//JALR
					imm_o 		= {{20{inst_i[31]}}, inst_i[31:20]};
					instvalid	= `InstValid;
					rs1e_o		= `ReadEnable;
					rs2e_o		= `ReadDisable;
					rs1addr_o	= rs1;
					rs2addr_o	= `NOPRegAddr;
					we_o		= `WriteEnable;
					wd_o		= rd;
					opcode_o	= `OpJALR;
					jumpe_o 	= `JumpEnable;
					jumpaddr_o 	= reg1_o + {{20{inst_i[31]}}, inst_i[31:20]};
				end
				7'b0000011:begin
					imm_o =	{{20{inst_i[31]}}, inst_i[31:20]};
					case(func3)
						3'b000:begin//LB
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLoad8;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b001:begin//LH
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLoad16;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b010:begin//LW
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLoad32;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b100:begin//LBU
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLoad8Unsigned;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b101:begin//LHU
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadDisable;
							rs1addr_o	= rs1;
							rs2addr_o	= `NOPRegAddr;
							we_o		= `WriteEnable;
							wd_o		= rd;
							opcode_o	= `OpLoad16Unsigned;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
					endcase
				end
				//S
				7'b0100011:begin
					case(func3)
						3'b000:begin//SB
							instvalid	= `InstValid;
							imm_o 		= {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteDisable;
							wd_o		= `NOPRegAddr;
							opcode_o	= `OpStore8;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b001:begin//SH
							instvalid	= `InstValid;
							imm_o 		= {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteDisable;
							wd_o		= `NOPRegAddr;
							opcode_o	= `OpStore16;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
						3'b010:begin//SW
							instvalid	= `InstValid;
							imm_o 		= {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteDisable;
							wd_o		= `NOPRegAddr;
							opcode_o	= `OpStore32;
							jumpe_o		= `JumpDisable;
							jumpaddr_o	= `ZeroAddr;
						end
					endcase
				end
				//SB
				7'b1100011:begin
					imm_o =	{{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
					case(func3)
						3'b000:begin//BEQ BranchEqual
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteDisable;
							wd_o		= `NOPRegAddr;
							opcode_o	= `OpBranchEqual;
							if (rs1data_i == rs2data_i) begin
								jumpe_o		= `JumpEnable;
								jumpaddr_o	= pc_i + imm_o;
							end else begin
								jumpe_o		= `JumpDisable;
								jumpaddr_o	= `ZeroAddr;
							end
						end
						3'b001:begin//BNE BranchNotEqual
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteDisable;
							wd_o		= `NOPRegAddr;
							opcode_o	= `OpBranchNotEqual;
							if (rs1data_i != rs2data_i) begin
								jumpe_o		= `JumpEnable;
								jumpaddr_o	= pc_i + imm_o;
							end else begin
								jumpe_o		= `JumpDisable;
								jumpaddr_o	= `ZeroAddr;
							end
						end
						3'b100:begin//BLT BranchLessThan
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteDisable;
							wd_o		= `NOPRegAddr;
							opcode_o	= `OpBranchLessThan;
							if ($signed(rs1data_i) < $signed(rs2data_i)) begin
								jumpe_o		= `JumpEnable;
								jumpaddr_o	= pc_i + imm_o;
							end else begin
								jumpe_o		= `JumpDisable;
								jumpaddr_o	= `ZeroAddr;
							end
						end
						3'b101:begin//BGE BranchGreaterEqual
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteDisable;
							wd_o		= `NOPRegAddr;
							opcode_o	= `OpBranchGreaterEqual;
							if ($signed(rs1data_i) >= $signed(rs2data_i)) begin
								jumpe_o		= `JumpEnable;
								jumpaddr_o	= pc_i + imm_o;
							end else begin
								jumpe_o		= `JumpDisable;
								jumpaddr_o	= `ZeroAddr;
							end
						end
						3'b110:begin//BLTU BranchLessThanUnsigned
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteDisable;
							wd_o		= `NOPRegAddr;
							opcode_o	= `OpBranchLessThanUnsigned;
							if (rs1data_i < rs2data_i) begin
								jumpe_o		= `JumpEnable;
								jumpaddr_o	= pc_i + imm_o;
							end else begin
								jumpe_o		= `JumpDisable;
								jumpaddr_o	= `ZeroAddr;
							end
						end
						3'b111:begin//BGEU BranchGreaterEqualUnsigned
							instvalid	= `InstValid;
							rs1e_o		= `ReadEnable;
							rs2e_o		= `ReadEnable;
							rs1addr_o	= rs1;
							rs2addr_o	= rs2;
							we_o		= `WriteDisable;
							wd_o		= `NOPRegAddr;
							opcode_o	= `OpBranchGreaterEqualUnsigned;
							if (rs1data_i >= rs2data_i) begin
								jumpe_o		= `JumpEnable;
								jumpaddr_o	= pc_i + imm_o;
							end else begin
								jumpe_o		= `JumpDisable;
								jumpaddr_o	= `ZeroAddr;
							end
						end
					endcase
				end
				//U
				7'b0110111:begin//LUI
					imm_o =	{inst_i[31:12], {12{1'b0}}};
					instvalid	= `InstValid;
					rs1e_o		= `ReadDisable;
					rs2e_o		= `ReadDisable;
					rs1addr_o	= `NOPRegAddr;
					rs2addr_o	= `NOPRegAddr;
					we_o		= `WriteEnable;
					wd_o		= rd;
					opcode_o	= `OpLUI;
					jumpe_o		= `JumpDisable;
					jumpaddr_o	= `ZeroAddr;
				end
				7'b0010111:begin//AUIPC
					imm_o =  {inst_i[31:12], {12{1'b0}}};
					instvalid	= `InstValid;
					rs1e_o		= `ReadDisable;
					rs2e_o		= `ReadDisable;
					rs1addr_o	= `NOPRegAddr;
					rs2addr_o	= `NOPRegAddr;
					we_o		= `WriteEnable;
					wd_o		= rd;
					opcode_o	= `OpAUIPC;
					jumpe_o		= `JumpDisable;
					jumpaddr_o	= `ZeroAddr;
				end
				//UJ
				7'b1101111:begin//JAL
					imm_o 		= {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
					instvalid	= `InstValid;
					rs1e_o		= `ReadDisable;
					rs2e_o		= `ReadDisable;
					rs1addr_o	= `NOPRegAddr;
					rs2addr_o	= `NOPRegAddr;
					we_o		= `WriteEnable;
					wd_o		= rd;
					opcode_o	= `OpJAL;
					jumpe_o		= `JumpEnable;
					jumpaddr_o 	= pc_i + {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
				end
				default:begin
					imm_o 		= `ZeroWord;
					instvalid	= `InstInvalid;
					rs1e_o		= `ReadDisable;
					rs2e_o		= `ReadDisable;
					rs1addr_o	= `NOPRegAddr;
					rs2addr_o	= `NOPRegAddr;
					we_o		= `WriteDisable;
					wd_o		= `NOPRegAddr;
					opcode_o	= `OpNothing;
					jumpe_o		= `JumpDisable;
					jumpaddr_o	= `ZeroAddr;
				end
			endcase
		end
	end

	always @(*) begin
		if (rst == `RstEnable) begin
			reg1_o = `ZeroWord;
		end else if (rs1e_o == `ReadDisable) begin
			reg1_o = imm_o;
		end else if (fwdmem_we_i && fwdmem_wd_i == rs1addr_o) begin
			reg1_o = fwdmem_wdata_i;
		end else if (fwdex_we_i && fwdex_wd_i == rs1addr_o) begin
			reg1_o = fwdex_wdata_i;
		end else begin
			reg1_o = rs1data_i;
		end
	end
	
	always @(*) begin
		if (rst == `RstEnable) begin
			reg2_o = `ZeroWord;
		end else if (rs2e_o == `ReadDisable) begin
			reg2_o = imm_o;
		end else if (fwdmem_we_i && fwdmem_wd_i == rs2addr_o) begin
			reg2_o = fwdmem_wdata_i;
		end else if (fwdex_we_i && fwdex_wd_i == rs2addr_o) begin
			reg2_o = fwdex_wdata_i;
		end else begin
			reg2_o = rs2data_i;
		end
	end
	
endmodule
