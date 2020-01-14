//global definition
`define RstEnable			1'b1
`define RstDisable			1'b0
`define ZeroAddr 			32'h00000000
`define ZeroWord			32'h00000000
`define OneWord				32'h00000001
`define FourWord 			32'h00000004
`define WriteEnable			1'b1
`define WriteDisable		1'b0
`define ReadEnable			1'b1
`define ReadDisable			1'b0
`define InstValid			1'b1
`define InstInvalid			1'b0
`define True_v				1'b1
`define False_v				1'b0
`define ChipEnable			1'b1
`define ChipDisable			1'b0
`define MemoryEnable 		1'b1 
`define MemoryDisable 		1'b0
`define ForwardingEnable	1'b1
`define ForwardingDisable	1'b0
`define JumpEnable 			1'b1 
`define JumpDisable 		1'b0

//inst definition
`define ShamtEnable						1'b0
`define ShamtDisable					1'b1
`define OpNumLog						7
`define OpCodeBus 						4:0
`define OpLUI							5'b00000
`define OpPlus							5'b00001
`define OpMinus							5'b00010
`define OpXor							5'b00011
`define OpOr 							5'b00100 
`define OpAnd 							5'b00101 
`define OpLessThanImm 					5'b00110 
`define OpLessThanImmUnsigned			5'b00111 
`define OpLogicLeft						5'b01000 
`define OpLogicRight 					5'b01001 
`define OpArithmeticRight				5'b01010 
`define OpNothing						5'b01011
`define OpLoad8							5'b01100
`define OpLoad16						5'b01101
`define OpLoad32						5'b01110
`define OpLoad8Unsigned					5'b01111
`define OpLoad16Unsigned				5'b10000 
`define OpStore8 						5'b10001
`define OpStore16 						5'b10010 
`define OpStore32 						5'b10011
`define OpBranchEqual 					5'b10100
`define OpBranchNotEqual 				5'b10101 
`define OpBranchLessThan 				5'b10110 
`define OpBranchGreaterEqual 			5'b10111 
`define OpBranchLessThanUnsigned		5'b11000 
`define OpBranchGreaterEqualUnsigned	5'b11001
`define OpAUIPC 						5'b11010 
`define OpJAL 							5'b11011 
`define OpJALR 							5'b11100

//ROM definition
`define InstAddrBus				31:0
`define InstBus 				31:0
`define DataBus 				31:0
`define DataBusLog 				2:0		//k Byte
`define Memory0bits				3'b000
`define Memory8bits				3'b001
`define Memory16bits			3'b010
`define Memory32bits			3'b100
`define MemoryRead 				1'b0
`define MemoryWrite 			1'b1
`define MemorySignedExtend		1'b1 
`define MemoryNoSignedExtend 	1'b0

//Regfile definition
`define RegAddrBus		4:0
`define RegBus 			31:0
`define RegNum			32
`define RegNumLog2		5
`define NOPRegAddr		5'b00000

//staller
`define StallBus	5:0
`define Stop 		1'b1
`define NoStop 		1'b0

//mem controller
`define Ready 		1'b1
`define NotReady	1'b0
`define IF_work 	1'b1
`define MEM_work 	1'b0
`define RAMBus 		7:0
`define Reorder 	1'b1
`define NoReorder 	1'b0
`define Stage5 		3'b101
`define Stage4 		3'b100
`define Stage3 		3'b011
`define Stage2 		3'b010
`define Stage1 		3'b001
`define Stage0 		3'b000
`define StageReady	3'b111
`define Piece3		31:24
`define Piece2 		23:16
`define Piece1 		15:8
`define Piece0 		7:0		//0->1->2->3 (from lower bit)
`define Shift1 		32'h00000001
`define Shift2 		32'h00000002
`define Shift3 		32'h00000003