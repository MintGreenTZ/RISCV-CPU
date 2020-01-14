`include "defines.v"

module ex(
	input wire 					rst,

	//data from id
	input wire[`RegBus]			reg1_i,
	input wire[`RegBus]			reg2_i,
	input wire 					we_i,
	input wire[`RegAddrBus]		wd_i,
	input wire[`OpCodeBus]		opcode_i,
	input wire[`InstAddrBus] 	pc_i,
	input wire[`RegBus]			imm_i,

	//data to send to the next stage
	output reg 					we_o,
	output reg[`RegAddrBus]		wd_o,
	output reg[`RegBus]			wdata_o,
	output reg 					meme_o,
	output reg 					memrw_o,
	output reg 					memsigned_o,
	output reg[`DataBusLog]		memwide_o,
	output reg[`RegBus] 		memaddr_o,
	output reg[`DataBus] 		memdata_o,

	//forwarding
	output reg 					fwd_we_o,
	output reg[`RegAddrBus] 	fwd_wd_o,
	output reg[`RegBus]			fwd_wdata_o
);

	reg[`RegBus]				logicout;

	always @(*) begin
		if (rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (opcode_i)
				`OpLUI:begin
					logicout <= reg1_i;
				end
				`OpPlus:begin
					logicout <= reg1_i + reg2_i;
				end
				`OpMinus:begin
					logicout <= reg1_i - reg2_i;
				end
				`OpXor:begin
					logicout <= reg1_i ^ reg2_i;
				end
				`OpOr:begin
					logicout <= reg1_i | reg2_i;
				end
				`OpAnd:begin
					logicout <= reg1_i & reg2_i;
				end
				`OpLessThanImm:begin
					if ($signed(reg1_i) < $signed(reg2_i)) begin
						logicout <= `OneWord;
					end else begin
						logicout <= `ZeroWord;
					end
				end
				`OpLessThanImmUnsigned:begin
					if (reg1_i < reg2_i) begin
						logicout <= `OneWord;
					end else begin
						logicout <= `ZeroWord;
					end
				end
				`OpLogicLeft:begin
					logicout <= reg1_i << reg2_i;
				end
				`OpLogicRight:begin
					logicout <= reg1_i >> reg2_i;
				end
				`OpArithmeticRight:begin
					logicout <= $signed(reg1_i) >>> $signed(reg2_i);
				end
				`OpAUIPC:begin
					logicout <= pc_i + reg2_i;
				end
				`OpJAL:begin
					logicout <= pc_i + `FourWord;
				end
				`OpJALR:begin
					logicout <= pc_i + `FourWord;
				end
				//below is for locating address, not for writing to rd
				`OpLoad8:begin
					logicout <= reg1_i + reg2_i;
				end
				`OpLoad16:begin
					logicout <= reg1_i + reg2_i;
				end
				`OpLoad32:begin
					logicout <= reg1_i + reg2_i;
				end
				`OpLoad8Unsigned:begin
					logicout <= reg1_i + reg2_i;
				end
				`OpLoad16Unsigned:begin
					logicout <= reg1_i + reg2_i;
				end
				`OpStore8:begin
					logicout <= reg1_i + imm_i;
				end
				`OpStore16:begin
					logicout <= reg1_i + imm_i;
				end
				`OpStore32:begin
					logicout <= reg1_i + imm_i;
				end
				default:begin
					logicout <= `ZeroWord;
				end
			endcase
		end
	end

	always @(*) begin
		if (rst) begin
			meme_o 		<= `MemoryDisable;
			memrw_o 	<= `MemoryRead;
			memwide_o	<= `Memory0bits;
			memsigned_o	<= `MemoryNoSignedExtend;
			memaddr_o	<= `ZeroWord;
		end else begin
			case (opcode_i)
				`OpLoad8:begin
					meme_o 		<= `MemoryEnable;
					memrw_o 	<= `MemoryRead;
					memwide_o	<= `Memory8bits;
					memsigned_o	<= `MemorySignedExtend;
					memaddr_o	<= logicout;
					memdata_o	<= `ZeroWord;
				end
				`OpLoad16:begin
					meme_o 		<= `MemoryEnable;
					memrw_o 	<= `MemoryRead;
					memwide_o	<= `Memory16bits;
					memsigned_o	<= `MemorySignedExtend;
					memaddr_o	<= logicout;
					memdata_o	<= `ZeroWord;
				end
				`OpLoad32:begin
					meme_o 		<= `MemoryEnable;
					memrw_o 	<= `MemoryRead;
					memwide_o	<= `Memory32bits;
					memsigned_o	<= `MemoryNoSignedExtend;
					memaddr_o	<= logicout;
					memdata_o	<= `ZeroWord;
				end
				`OpLoad8Unsigned:begin
					meme_o 		<= `MemoryEnable;
					memrw_o 	<= `MemoryRead;
					memwide_o	<= `Memory8bits;
					memsigned_o	<= `MemoryNoSignedExtend;
					memaddr_o	<= logicout;
					memdata_o	<= `ZeroWord;
				end
				`OpLoad16Unsigned:begin
					meme_o 		<= `MemoryEnable;
					memrw_o 	<= `MemoryRead;
					memwide_o	<= `Memory16bits;
					memsigned_o	<= `MemoryNoSignedExtend;
					memaddr_o	<= logicout;
					memdata_o	<= `ZeroWord;
				end
				`OpStore8:begin
					meme_o 		<= `MemoryEnable;
					memrw_o 	<= `MemoryWrite;
					memwide_o	<= `Memory8bits;
					memsigned_o	<= `MemoryNoSignedExtend;
					memaddr_o	<= logicout;
					memdata_o	<= reg2_i;
				end
				`OpStore16:begin
					meme_o 		<= `MemoryEnable;
					memrw_o 	<= `MemoryWrite;
					memwide_o	<= `Memory16bits;
					memsigned_o	<= `MemoryNoSignedExtend;
					memaddr_o	<= logicout;
					memdata_o	<= reg2_i;
				end
				`OpStore32:begin
					meme_o 		<= `MemoryEnable;
					memrw_o 	<= `MemoryWrite;
					memwide_o	<= `Memory32bits;
					memsigned_o	<= `MemoryNoSignedExtend;
					memaddr_o	<= logicout;
					memdata_o	<= reg2_i;
				end
				default:begin
					meme_o 		<= `MemoryDisable;
					memrw_o 	<= `MemoryRead;
					memsigned_o	<= `MemoryNoSignedExtend;
					memwide_o	<= `Memory0bits;
					memaddr_o	<= `ZeroWord;
					memdata_o	<= `ZeroWord;
				end
			endcase
		end
	end

	always @(*) begin
		we_o 	<= we_i;
		wd_o 	<= wd_i;
		if (opcode_i < `OpNothing || opcode_i == `OpAUIPC || opcode_i == `OpJAL || opcode_i == `OpJALR) begin
			fwd_we_o 	<= `ForwardingEnable;
			fwd_wd_o 	<= wd_i;
			fwd_wdata_o <= logicout;
			wdata_o 	<= logicout;
		end else begin
			fwd_we_o 	<= `ForwardingDisable;
			fwd_wd_o 	<= `ZeroWord;
			fwd_wdata_o <= `ZeroWord;
			wdata_o 	<= `ZeroWord;
		end
	end

endmodule