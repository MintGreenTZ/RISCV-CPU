// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "defines.v"

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire					rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

    /**********************************************Main 5-stage*******************************************/
    //link IF - IF/ID
    wire[7:0]           count;
    wire[`InstAddrBus]  pc;
    //link IF/ID - ID
    wire[`InstAddrBus]  id_pc_i;
    wire[`InstBus]      id_inst_i;
    //link ID - ID/EX
    wire[`RegBus]		id_reg1_o;
	wire[`RegBus]		id_reg2_o;
	wire 				id_we_o;
	wire[`RegAddrBus]	id_wd_o;
	wire[`OpCodeBus]	id_opcode_o;
	wire[`InstAddrBus]  id_pc_o;
    wire[`RegBus]       id_imm_o;
    //link ID/EX - EX
    wire[`RegBus]		ex_reg1_i;
	wire[`RegBus]		ex_reg2_i;
	wire 				ex_we_i;
	wire[`RegAddrBus]	ex_wd_i;
	wire[`OpCodeBus]	ex_opcode_i;
	wire[`InstAddrBus]  ex_pc_i;
    wire[`RegBus]       ex_imm_i;
    //link EX - EX/MEM
    wire 				ex_we_o;
	wire[`RegAddrBus]	ex_wd_o;
	wire[`RegBus]		ex_wdata_o;
	wire 				ex_meme_o;
	wire 				ex_memrw_o;
	wire 				ex_memsigned_o;
	wire[`DataBusLog]	ex_memwide_o;
	wire[`RegBus] 		ex_memaddr_o;
    wire[`DataBus]      ex_memdata_o;
    //link EX/MEM - MEM
    wire 				mem_we_i;
	wire[`RegAddrBus]	mem_wd_i;
	wire[`RegBus]		mem_wdata_i;
	wire 				mem_meme_i;
	wire 				mem_memrw_i;
	wire 				mem_memsigned_i;
	wire[`DataBusLog]	mem_memwide_i;
	wire[`RegBus] 		mem_memaddr_i;
    wire[`DataBus]      mem_memdata_i;
    //link MEM - MEM/WB
    wire 				mem_we_o;
	wire[`RegAddrBus]	mem_wd_o;
	wire[`RegBus]		mem_wdata_o;
	//link MEM/WB - REG
	wire 				wb_we_i;
	wire[`RegAddrBus]	wb_wd_i;
	wire[`RegBus]		wb_wdata_i;
    /*****************************************************************************************************/

    /**********************************************With ID************************************************/
    //link ID - IF
    wire                jumpe;
    wire[`InstAddrBus]  jumpaddr;
    //link ID - REG
   	wire 				rs1e;
	wire 				rs2e;
	wire[`RegAddrBus]	rs1addr;
	wire[`RegAddrBus]	rs2addr;
	wire[`RegBus]		rs1data;
	wire[`RegBus]		rs2data;
    //link ID - EX && ID - MEM (Forwarding)
    wire 				fwdex_we;
	wire[`RegAddrBus]	fwdex_wd;
	wire[`RegBus] 		fwdex_wdata;
	wire 				fwdmem_we;
	wire[`RegAddrBus]	fwdmem_wd;
	wire[`RegBus] 		fwdmem_wdata;

    /*****************************************************************************************************/
	
	/**********************************************With MEM_CTRL******************************************/
    //link IF - MEM_CTRL
    wire                ife;
    wire                reorder_jump;
    wire                ifready;
    wire[`DataBus]      ifdata;
    //link MEM - MEM_CTRL
	wire 				meme;
	wire 				memrw;
	wire 				memsigned;
	wire[`DataBusLog] 	memwide;
	wire[`RegBus] 		memaddr;
	wire[`DataBus] 		memdata;
	wire 				memready;
	wire[`DataBus] 		memresult;
    /*****************************************************************************************************/

    /**********************************************With STALL_CTRL****************************************/
    //link STALL_CTRL
    wire                stall_from_if;
    wire                stall_from_mem;
    wire[`StallBus]     stall;
    /*****************************************************************************************************/

    pc_reg pc_reg0(
        .clk(clk_in), .rst(rst_in), .stall(stall), .count(count),
        //jump order from id
        .jumpe_i(jumpe), .jumpaddr_i(jumpaddr),
        //interaction with mem_ctrl
        .ife(ife), .pc(pc), .reorder_jump(reorder_jump), .ifready_i(ifready), .ifdata_i(ifdata),
        //stall request
    	.stall_from_if(stall_from_if)
    );

    if_id if_id0(
        .clk(clk_in), .rst(rst_in), .stall(stall),
        .if_pc(pc), .if_inst(ifdata),
        .id_pc(id_pc_i), .id_inst(id_inst_i)
    );

    id id0(
        .rst(rst_in),
        //data from if
        .pc_i(id_pc_i), .inst_i(id_inst_i),
        //data exchange with Regfile
        .rs1e_o(rs1e), .rs2e_o(rs2e), .rs1addr_o(rs1addr), .rs2addr_o(rs2addr),
        .rs1data_i(rs1data), .rs2data_i(rs2data),
        //data get from forwarding
        .fwdex_we_i(fwdex_we), .fwdex_wd_i(fwdmem_wd), .fwdex_wdata_i(fwdex_wdata),
		.fwdmem_we_i(fwdmem_we), .fwdmem_wd_i(fwdmem_wd), .fwdmem_wdata_i(fwdmem_wdata),
		//data to send to the next stage
		.reg1_o(id_reg1_o), .reg2_o(id_reg2_o), .we_o(id_we_o), .wd_o(id_wd_o), .opcode_o(id_opcode_o), .pc_o(id_pc_o), .imm_o(id_imm_o),
		//jump pulse (give to if)
		.jumpe_o(jumpe), .jumpaddr_o(jumpaddr)
    );

    id_ex id_ex0(
    	.clk(clk_in), .rst(rst_in), .stall(stall),
    	.id_reg1(id_reg1_o), .id_reg2(id_reg2_o), .id_we(id_we_o), .id_wd(id_wd_o), .id_opcode(id_opcode_o), .id_pc(id_pc_o), .id_imm(id_imm_o),
		.ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i), .ex_we(ex_we_i), .ex_wd(ex_wd_i), .ex_opcode(ex_opcode_i), .ex_pc(ex_pc_i), .ex_imm(ex_imm_i)
    );

    ex ex0(
    	.rst(rst_in),
    	//data from id
    	.reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i), .we_i(ex_we_i), .wd_i(ex_wd_i), .opcode_i(ex_opcode_i), .pc_i(ex_pc_i), .imm_i(ex_imm_i), 
    	//data to send to the next stage
    	.we_o(ex_we_o), .wd_o(ex_wd_o), .wdata_o(ex_wdata_o), .meme_o(ex_meme_o), .memrw_o(ex_memrw_o), 
        .memsigned_o(ex_memsigned_o), .memwide_o(ex_memwide_o), .memaddr_o(ex_memaddr_o), .memdata_o(ex_memdata_o), 
		//forwarding
		.fwd_we_o(fwdex_we), .fwd_wd_o(fwdex_wd), .fwd_wdata_o(fwdex_wdata)
    );

    ex_mem ex_mem0(
    	.clk(clk_in), .rst(rst_in), .stall(stall),
    	.ex_we(ex_we_o), .ex_wd(ex_wd_o), .ex_wdata(ex_wdata_o), .ex_meme(ex_meme_o), .ex_memrw(ex_memrw_o),
        .ex_memsigned(ex_memsigned_o), .ex_memwide(ex_memwide_o), .ex_memaddr(ex_memaddr_o), .ex_memdata(ex_memdata_o), 
		.mem_we(mem_we_i), .mem_wd(mem_wd_i), .mem_wdata(mem_wdata_i), .mem_meme(mem_meme_i), .mem_memrw(mem_memrw_i), 
        .mem_memsigned(mem_memsigned_i), .mem_memwide(mem_memwide_i), .mem_memaddr(mem_memaddr_i), .mem_memdata(mem_memdata_i)
    );

    mem mem0(
    	.rst(rst_in),
    	//data from ex
    	.we_i(mem_we_i), .wd_i(mem_wd_i), .wdata_i(mem_wdata_i), .meme_i(mem_meme_i), .memrw_i(mem_memrw_i), 
        .memsigned_i(mem_memsigned_i), .memwide_i(mem_memwide_i), .memaddr_i(mem_memaddr_i), .memdata_i(mem_memdata_i), 
		//data to send to the next stage
    	.we_o(mem_we_o), .wd_o(mem_wd_o), .wdata_o(mem_wdata_o),
		//interaction with mem_ctrl
		.meme_o(meme), .memrw_o(memrw), .memsigned_o(memsigned), .memwide_o(memwide),
		.memaddr_o(memaddr), .memdata_o(memdata), .memready_i(memready), .memresult_i(memresult),
		//forwarding
		.fwd_we_o(fwdmem_we), .fwd_wd_o(fwdmem_wd), .fwd_wdata_o(fwdmem_wdata),
		//stall request
		.stall_from_mem(stall_from_mem)
    );

    mem_wb mem_wb0(
    	.clk(clk_in), .rst(rst_in), .stall(stall),
    	.mem_we(mem_we_o), .mem_wd(mem_wd_o), .mem_wdata(mem_wdata_o),
    	.wb_we(wb_we_i), .wb_wd(wb_wd_i), .wb_wdata(wb_wdata_i)
    );

    regfile regfile0(
    	.clk(clk_in), .rst(rst_in),
    	//from wb
		.we(wb_we_i), .wd(wb_wd_i), .wdata(wb_wdata_i),
		//interaction with id
		.rs1e_i(rs1e), .rs1addr_i(rs1addr), .rs1data_o(rs1data),
		.rs2e_i(rs2e), .rs2addr_i(rs2addr), .rs2data_o(rs2data)
    );

    mem_ctrl mem_ctrl0(
    	.clk(clk_in), .rst(rst_in),
    	//interaction with IF
    	.ife_i(ife), .pc(pc), .reorder_jump(reorder_jump), .ifready_o(ifready), .ifdata_o(ifdata),
    	//interaction with MEM
    	.meme_i(meme), .memrw_i(memrw), .memsigned_i(memsigned), .memwide_i(memwide),
		.memaddr_i(memaddr), .memdata_i(memdata), .memready_o(memready), .memdata_o(memresult),
		//interaction with RAM
		.ram_rw(mem_wr), .ram_addr(mem_a), .ram_data(mem_dout), .ram_result(mem_din)
    );

    stall_ctrl stall_ctrl0(
    	.rst(rst_in),
    	.stall_from_if(stall_from_if), .stall_from_mem(stall_from_mem),
    	.stall(stall)
    );
endmodule