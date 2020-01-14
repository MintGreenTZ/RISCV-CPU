`include "defines.v"

module mem_ctrl(
	input wire					clk,
	input wire					rst,

	//interaction with IF
	input wire 					ife_i,
	input wire[`InstAddrBus]	pc,
	input wire 					reorder_jump,
	output reg 					ifready_o,
	output reg[`InstBus] 		ifdata_o,

	//interaction with MEM
	input wire 					meme_i,
	input wire 					memrw_i,
	input wire 					memsigned_i,
	input wire[`DataBusLog] 	memwide_i,
	input wire[`InstAddrBus] 	memaddr_i,
	input wire[`DataBus] 		memdata_i,
	output reg 					memready_o,
	output reg[`DataBus] 		memdata_o,

	//interaction with RAM
	output reg 					ram_rw,
	output reg[`InstAddrBus] 	ram_addr,
	output reg[`RAMBus] 		ram_data,
	input wire[`RAMBus] 		ram_result,

	//stall
	output reg[`StallBus] 		stall
);
	reg 				who;
	reg 				rw;
	reg 				sign_extended;
	reg[`DataBusLog]	wide;
	reg[`InstAddrBus]	addr;
	reg[2:0]			stage = 3'b000;
	reg[`DataBus]		data;

	always @(posedge reorder_jump) begin
		if (rst) begin
			ifready_o	= `NotReady;
			ifdata_o 	= `ZeroWord;
			memready_o 	= `NotReady;
			memdata_o 	= `ZeroWord;
			ram_rw 		= `MemoryRead;
			ram_addr 	= `ZeroAddr;
			ram_data 	= `ZeroWord;
		end begin
			ifready_o	= `NotReady;
			ifdata_o 	= `ZeroWord;
			memready_o 	= `NotReady;
			memdata_o 	= `ZeroWord;

			if (who == `IF_work) begin
				ram_rw 		= `MemoryRead;
				ram_addr 	= pc;
				ram_data 	= `ZeroWord;

				who 			= `IF_work;
				rw 				= `MemoryRead;
				sign_extended 	= `MemoryNoSignedExtend;
				wide 			= `Memory32bits;
				addr 			= pc;
				stage 			= `Stage5;
			end
		end
	end

	/*always @(posedge meme_i) begin
		if (rst) begin
			ifready_o	= `NotReady;
			ifdata_o 	= `ZeroWord;
			memready_o 	= `NotReady;
			memdata_o 	= `ZeroWord;
			ram_rw 		= `MemoryRead;
			ram_addr 	= `ZeroAddr;
			ram_data 	= `ZeroWord;
		end else begin
			ifready_o	= `NotReady;
			ifdata_o 	= `ZeroWord;
			memready_o 	= `NotReady;
			memdata_o 	= `ZeroWord;
			ram_rw 		= memrw_i;
			ram_addr 	= memaddr_i;
			ram_data 	= memdata_i[`Piece0];
			stall 		= 6'b011111;

			who 			= `MEM_work;
			rw 				= memrw_i;
			sign_extended 	= memsigned_i;
			wide 			= memwide_i;
			addr 			= memaddr_i;
			case (memwide_i)
				`Memory32bits: 	stage = `Stage5;
				`Memory16bits: 	stage = `Stage3;
				`Memory8bits:	stage = `Stage1;
			endcase
		end
	end*/

	always @(posedge clk) begin
		if (rst) begin
			ifready_o	= `NotReady;
			ifdata_o 	= `ZeroWord;
			memready_o 	= `NotReady;
			memdata_o 	= `ZeroWord;
			ram_rw 		= `MemoryRead;
			ram_addr 	= `ZeroAddr;
			ram_data 	= `ZeroWord;
			stall 		= 6'b000001;
		end else if (stage == 0) begin
			/*********************************Stage0 case begin**************************************************/
			if (meme_i == `MemoryEnable && memrw_i == `MemoryWrite && memwide_i == `Memory8bits) begin //1 cycle done
				ifready_o	= `NotReady;
				ifdata_o 	= `ZeroWord;
				memready_o 	= `Ready;
				memdata_o 	= `ZeroWord;
				ram_rw 		= `MemoryWrite;
				ram_addr 	= memaddr_i;
				ram_data 	= memdata_i[`Piece0];
				stall 		= 6'b000000;
			end else if (meme_i == `MemoryEnable) begin //MEM_work
				ifready_o	= `NotReady;
				ifdata_o 	= `ZeroWord;
				memready_o 	= `NotReady;
				memdata_o 	= `ZeroWord;
				ram_rw 		= memrw_i;
				ram_addr 	= memaddr_i;
				ram_data 	= memdata_i[`Piece0];
				stall 		= 6'b011111;

				who 			= `MEM_work;
				rw 				= memrw_i;
				sign_extended 	= memsigned_i;
				wide 			= memwide_i;
				addr 			= memaddr_i;
				case (memwide_i)
					`Memory32bits: 	stage = `Stage5;
					`Memory16bits: 	stage = `Stage3;
					`Memory8bits:	stage = `Stage1;
				endcase
			end else if (ife_i == `MemoryEnable) begin //IF_work
				ifready_o	= `NotReady;
				ifdata_o 	= `ZeroWord;
				memready_o 	= `NotReady;
				memdata_o 	= `ZeroWord;
				ram_rw 		= `MemoryRead;
				ram_addr 	= pc;
				ram_data 	= `ZeroWord;
				stall 		= 6'b000001;

				who 			= `IF_work;
				rw 				= `MemoryRead;
				sign_extended 	= `MemoryNoSignedExtend;
				wide 			= `Memory32bits;
				addr 			= pc;
				stage 			= `Stage5;
			end else begin //do nothing
				ifready_o	= `NotReady;
				ifdata_o 	= `ZeroWord;
				memready_o 	= `NotReady;
				memdata_o 	= `ZeroWord;
				ram_rw 		= `MemoryRead;
				ram_addr 	= `ZeroWord;
				ram_data 	= `ZeroWord;
				stall 		= 6'b000000;

				who 			= `IF_work;
				rw 				= `MemoryRead;
				sign_extended 	= `MemoryNoSignedExtend;
				wide 			= `Memory0bits;
				addr 			= `ZeroAddr;
				stage 			= `Stage0;
			end
			/*********************************Stage0 case end**************************************************/
		end else if (rw == `MemoryRead) begin
			case (wide)
				`Memory32bits:begin
					case (stage)
						`Stage5:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= addr + `Shift1;
							ram_data 		= `ZeroWord;
							stage 			= stage - 3'b001;
						end
						`Stage4:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= addr + `Shift2;
							ram_data 		= `ZeroWord;
							data[`Piece0]	= ram_result;
							stage 			= stage - 3'b001;
						end
						`Stage3:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= addr + `Shift3;
							ram_data 		= `ZeroWord;
							data[`Piece1]	= ram_result;
							stage 			= stage - 3'b001;
						end
						`Stage2:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= `ZeroAddr;
							ram_data 		= `ZeroWord;
							data[`Piece2]	= ram_result;
							stage 			= stage - 3'b001;
						end
						`Stage1:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= `ZeroAddr;
							ram_data 		= `ZeroWord;
							data			= {ram_result, data[23:0]};
							stage 			= stage - 3'b001;
						end
					endcase
				end
				`Memory16bits:begin
					case (stage)
						`Stage3:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= addr + `Shift1;
							ram_data 		= `ZeroWord;
							stage 			= stage - 3'b001;
						end
						`Stage2:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= `ZeroAddr;
							ram_data 		= `ZeroWord;
							data[`Piece0]	= ram_result;
							stage 			= stage - 3'b001;
						end
						`Stage1:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= `ZeroAddr;
							ram_data 		= `ZeroWord;
							if (sign_extended == `MemorySignedExtend)
								data 		= {{16{ram_result[7]}}, ram_result, data[7:0]};
							else
								data		= {{16{1'b0}}, ram_result, data[7:0]};
							stage 			= stage - 3'b001;
						end
					endcase
				end
				`Memory8bits:begin
					case (stage)
						`Stage2:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= `ZeroAddr;
							ram_data 		= `ZeroWord;
							stage 			= stage - 3'b001;
						end
						`Stage1:begin
							ram_rw 			= `MemoryRead;
							ram_addr 		= `ZeroAddr;
							ram_data 		= `ZeroWord;
							if (sign_extended == `MemorySignedExtend)
								data		= {{24{ram_result[7]}}, ram_result};
							else
								data		= {{24{1'b0}}, ram_result};
							stage 			= stage - 3'b001;
						end
					endcase
				end
			endcase
			if (stage == `Stage0) begin
				if (who == `MEM_work) begin
					ifready_o	= `NotReady;
					ifdata_o 	= `ZeroWord;
					memready_o 	= `Ready;
					memdata_o 	= data;
				end else begin
					ifready_o	= `Ready;
					ifdata_o 	= data;
					memready_o 	= `NotReady;
					memdata_o 	= `ZeroWord;
				end
			end else begin
				ifready_o	= `NotReady;
				ifdata_o 	= `ZeroWord;
				memready_o 	= `NotReady;
				memdata_o 	= `ZeroWord;
			end
		end else if (rw == `MemoryWrite) begin
			case (wide)
				`Memory32bits:begin
					case (stage)
						`Stage3:begin
							ram_rw 			= `MemoryWrite;
							ram_addr 		= addr + `Shift1;
							ram_data 		= `ZeroWord;
							stage 			= stage - 3'b001;
						end
						`Stage2:begin
							ram_rw 			= `MemoryWrite;
							ram_addr 		= addr + `Shift2;
							ram_data 		= `ZeroWord;
							stage 			= stage - 3'b001;
						end
						`Stage1:begin
							ram_rw 			= `MemoryWrite;
							ram_addr 		= addr + `Shift3;
							ram_data 		= `ZeroWord;
							stage 			= stage - 3'b001;
						end
					endcase
				end
				`Memory16bits:begin
					case (stage)
						`Stage1:begin
							ram_rw 			= `MemoryWrite;
							ram_addr 		= addr + `Shift1;
							ram_data 		= `ZeroWord;
							stage 			= stage - 3'b001;
						end
					endcase
				end
			endcase
			if (stage == `Stage0) begin
				if (who == `MEM_work) begin
					ifready_o	= `NotReady;
					ifdata_o 	= `ZeroWord;
					memready_o 	= `Ready;
					memdata_o 	= `ZeroWord;
				end else begin
					ifready_o	= `Ready;
					ifdata_o 	= `ZeroWord;
					memready_o 	= `NotReady;
					memdata_o 	= `ZeroWord;
				end
			end else begin
				ifready_o	= `NotReady;
				ifdata_o 	= `ZeroWord;
				memready_o 	= `NotReady;
				memdata_o 	= `ZeroWord;
			end
		end
	end

endmodule