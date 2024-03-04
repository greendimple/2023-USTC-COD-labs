`timescale 1ns / 1ps

/* 
 *   Author: YOU
 *   Last update: 2023.04.20
 */

module CPU(
    input clk, 
    input rst,

    // MEM And MMIO Data BUS
    output [31:0] im_addr,      // Instruction address (The same as current PC)
    input [31:0] im_dout,       // Instruction data (Current instruction)
    output [31:0] mem_addr,     // Memory read/write address
    output mem_we,              // Memory writing enable		            
    output [31:0] mem_din,      // Data ready to write to memory
    input [31:0] mem_dout,	    // Data read from memory
    output [2:0] sw_sh_sb,      // Memory write sel

    // Debug BUS with PDU
    output [31:0] current_pc, 	        // Current_pc, pc_out
    output [31:0] next_pc,              // Next_pc, pc_in    
    input [31:0] cpu_check_addr,	    // Check current datapath state (code)
    output [31:0] cpu_check_data        // Current datapath state data
);

    // Write your CPU here!
    // You might need to write these modules:
    //      ALU、RF、Control、Add(Or just add-mode ALU)、And(Or just and-mode ALU)、PCReg、Imm、Branch、Mux、...
    wire [31:0] inst_raw,dm_dout,dm_dout_wb,dm_dout_wb_load,
    pc_cur_if,pc_cur_id,pc_cur_ex,pc_cur_mem,pc_cur_wb,
    pc_add4_if,pc_add4_id,pc_add4_ex,pc_add4_mem,pc_add4_wb,
    alu_ans_mem,alu_ans_ex,alu_ans_wb,
    alu_ans_ex_float,alu_ans_ex_no_float,
    alu_src1_ex,alu_src2_ex,alu_src1_mem,alu_src1_wb,alu_src2_mem,alu_src2_wb,
    rf_rd0_raw_id,rf_rd0_raw_ex,rf_rd0_raw_mem,rf_rd0_raw_wb,
    rf_rd1_raw_id,rf_rd1_raw_ex,rf_rd1_raw_mem,rf_rd1_raw_wb,

    rf_rd0_raw_id_float,rf_rd0_raw_id_no_float,
    rf_rd1_raw_id_float,rf_rd1_raw_id_no_float,

    rf_rd0_ex,rf_rd0_mem,rf_rd0_wb,
    rf_rd1_ex,rf_rd1_mem,rf_rd1_wb,
    rf_rd0_fd,rf_rd1_fd,
    rf_wd_wb,
    rf_rd_dbg_id,rf_rd_dbg_id_float,rf_rd_dbg_id_no_float,
    rd1_id,rd1_ex,
    imm_id,imm_ex,imm_mem,imm_wb,
    dm_din_ex,dm_din_mem,dm_din_wb,
    dm_addr_mem,dm_addr_wb, 
    pc_next,pc_next_mem,pc_next_wb,
    pc_br_mem,pc_br_wb,
    pc_jalr_ex,pc_jalr_mem,pc_jalr_wb,
    pc_jal_mem,pc_jal_wb,
    inst_if,inst_id,inst_ex,inst_mem,inst_wb,
    check_data_if,check_data_id,check_data_ex,check_data_mem,check_data_wb,check_data_hzd,
    check_data;
    // pc_jal_id;

    wire  rf_we_id,rf_we_ex,rf_we_mem,rf_we_wb,
    dm_we_id,dm_we_ex,dm_we_mem,dm_we_wb;
    wire br_ex,br_mem,br_wb,
    rf_re0_id,rf_re0_ex,rf_re0_mem,rf_re0_wb,
    rf_re1_id,rf_re1_ex,rf_re1_mem,rf_re1_wb,
    rf_rd0_fe,rf_rd1_fe,

    alu_src2_sel_id,alu_src2_sel_ex,alu_src2_sel_mem,alu_src2_sel_wb,
    // mem_we_id,

    // for load
    lb_id,lb_ex,lb_mem,lb_wb,
    lw_id,lw_ex,lw_mem,lw_wb,
    lh_id,lh_ex,lh_mem,lh_wb,
    lhu_id,lhu_ex,lhu_mem,lhu_wb,
    lbu_id,lbu_ex,lbu_mem,lbu_wb,

    //for float
    float_id,float_ex,float_mem,float_wb,
    rf_read_sel_id,rf_read_sel_ex,rf_read_sel_mem,rf_read_sel_wb,
    rf_wb_sel_id,rf_wb_sel_ex,rf_wb_sel_mem,rf_wb_sel_wb,

    jalr_id,jalr_ex,jalr_mem,jalr_wb,
    jal_id,jal_ex,jal_mem,jal_wb;
    wire stall_if,stall_id,stall_ex,
    flush_if,flush_id,flush_ex,flush_mem;
    wire [4:0] rf_ra0_id,rf_ra0_ex,rf_ra0_mem,rf_ra0_wb,
    rf_ra1_id,rf_ra1_ex,rf_ra1_mem,rf_ra1_wb,
    rf_wa_id,rf_wa_ex,rf_wa_mem,rf_wa_wb;
    wire [1:0] 
    pc_sel_ex,pc_sel_mem,pc_sel_wb,pc_sel,
    rf_wd_sel_id,rf_wd_sel_ex,rf_wd_sel_mem,rf_wd_sel_wb,
    alu_src1_sel_id,alu_src1_sel_ex,alu_src1_sel_mem,alu_src1_sel_wb;//changed
    wire [2:0] imm_type_id,imm_type_ex,imm_type_mem,imm_type_wb,
    br_type_id,br_type_ex,br_type_mem,br_type_wb,//changed
    rm_id,rm_ex,rm_mem,rm_wb,//for float
    sw_sh_sb_id,sw_sh_sb_ex,sw_sh_sb_mem;//for store
    wire [3:0] alu_func_id,alu_func_ex,alu_func_mem,alu_func_wb;

    assign im_addr=pc_cur_if,mem_addr=alu_ans_mem,mem_din=dm_din_mem,mem_we=dm_we_mem,current_pc=pc_cur_if,next_pc=pc_next;
    assign inst_raw=im_dout,dm_dout=mem_dout;
    assign sw_sh_sb=sw_sh_sb_mem;

    assign rf_rd0_raw_id=(rf_read_sel_id?rf_rd0_raw_id_float:rf_rd0_raw_id_no_float),
           rf_rd1_raw_id=(rf_read_sel_id?rf_rd1_raw_id_float:rf_rd1_raw_id_no_float);
    // assign rf_rd_dbg_id=(rf_read_sel_id?rf_rd_dbg_id_float:rf_rd_dbg_id_no_float);
    assign alu_ans_ex=(float_ex?alu_ans_ex_float:alu_ans_ex_no_float);

    PC  pc(
    .pc_next(pc_next),
    .clk(clk), 
    .rst(rst),
    .stall(stall_if),
    .pc_cur(pc_cur_if)
    );
    
    ADD ADD(
    .lhs(32'd4),
    .rhs(pc_cur_if),
    .res(pc_add4_if)
    );

    Mux2 inst_flush(
    .mux_sr1(inst_raw),
    .mux_sr2(32'h0000_0033),//nop
    .mux_ctrl(flush_if),
    .mux_out(inst_if)
    );  

    SEG_REG seg_reg_if_id(
    .clk(clk),
    .flush(flush_id),
    .stall(stall_id),
    .pc_cur_in(pc_cur_if),
    .pc_cur_out(pc_cur_id),
    .inst_in(inst_if),
    .inst_out(inst_id),
    .rf_ra0_in(inst_if[19:15]),
    .rf_ra0_out(rf_ra0_id),
    .rf_ra1_in(inst_if[24:20]),
    .rf_ra1_out(rf_ra1_id),
    .rf_re0_in(1'h0),
    .rf_re0_out(),
    .rf_re1_in(1'h0),
    .rf_re1_out(),
    .rf_rd0_raw_in(32'h0),
    .rf_rd0_raw_out(),
    .rf_rd1_raw_in(32'h0),
    .rf_rd1_raw_out(),
    .rf_rd0_in(32'h0),
    .rf_rd0_out(),
    .rf_rd1_in(32'h0),
    .rf_rd1_out(),
    .rf_wa_in(inst_if[11:7]),
    .rf_wa_out(rf_wa_id),
    .rf_wd_sel_in(2'h0),
    .rf_wd_sel_out(),
    .rf_we_in(1'h0),
    .rf_we_out(),
    .imm_type_in(3'h0),
    .imm_type_out(),
    .imm_in(32'h0),
    .imm_out(),
    .alu_src1_sel_in(2'h0),
    .alu_src1_sel_out(),
    .alu_src2_sel_in(1'h0),
    .alu_src2_sel_out(),
    .alu_src1_in(32'h0),
    .alu_src1_out(),
    .alu_src2_in(32'h0),
    .alu_src2_out(),
    .alu_func_in(4'h0),
    .alu_func_out(),
    .alu_ans_in(32'h0),
    .alu_ans_out(),
    .pc_add4_in(pc_add4_if),
    .pc_add4_out(pc_add4_id),
    .pc_br_in(32'h0),
    .pc_br_out(),
    .pc_jal_in(32'h0),
    .pc_jal_out(),
    .pc_jalr_in(32'h0),
    .pc_jalr_out(),
    .jal_in(1'h0),
    .jal_out(),
    .jalr_in(1'h0),
    .jalr_out(),
    .br_type_in(3'h0),
    .br_type_out(),
    .br_in(1'h0),
    .br_out(),
    .pc_sel_in(2'h0),
    .pc_sel_out(),
    .pc_next_in(32'h0),
    .pc_next_out(),
    .dm_addr_in(32'h0),
    .dm_addr_out(),
    .dm_din_in(32'h0),
    .dm_din_out(),
    .dm_dout_in(32'h0),
    .dm_dout_out(),
    .dm_we_in(1'h0),
    .dm_we_out(),

    .lb_in(1'b0),
    .lb_out(),
    .lw_in(1'b0),
    .lw_out(),
    .lh_in(1'b0),
    .lh_out(),
    .lbu_in(1'b0),
    .lbu_out(),
    .lhu_in(1'b0),
    .lhu_out(),
    .sw_sh_sb_in(3'b0),
    .sw_sh_sb_out(),

    .float_in(1'b0),
    .float_out(),
    .rf_read_sel_in(1'b0),
    .rf_read_sel_out(),
    .rf_wb_sel_in(1'b0),
    .rf_wb_sel_out(),
    .rm_in(3'b0),
    .rm_out()
    );

    
    RF rf( 
    .clk(clk), //时钟（上升沿有效）
    .ra0(rf_ra0_id), //读端口0地址
    .rd0(rf_rd0_raw_id_no_float), //读端口0数据
    .ra1(rf_ra1_id), //读端口1地址
    .rd1(rf_rd1_raw_id_no_float), //读端口1数据
    .wa(rf_wa_wb), //写端口地址
    .we(rf_we_wb & (~rf_wb_sel_wb)), //写使能，高电平有效
    .wd(rf_wd_wb), //写端口数据
    .ra_dbg(cpu_check_addr[4:0]), //读端口2地址, 用于PDU从外部读取寄存器的值
    .rd_dbg(rf_rd_dbg_id_no_float) //读端口2数据
    );

    fRF frf( 
    .clk(clk), //时钟（上升沿有效）
    .ra0(rf_ra0_id), //读端口0地址
    .rd0(rf_rd0_raw_id_float), //读端口0数据
    .ra1(rf_ra1_id), //读端口1地址
    .rd1(rf_rd1_raw_id_float), //读端口1数据
    .wa(rf_wa_wb), //写端口地址
    .we(rf_we_wb & rf_wb_sel_wb), //写使能，高电平有效
    .wd(rf_wd_wb) //写端口数据
    // .ra_dbg(cpu_check_addr[4:0]), //读端口2地址, 用于PDU从外部读取寄存器的值
    // .rd_dbg(rf_rd_dbg_id_float) //读端口2数据
    );

    Immediate immediate(
    .inst(inst_id),
    .imm_type(imm_type_id),
    .imm(imm_id)
    );

    CTRL ctrl(
    .inst(inst_id),
    .jal(jal_id),
    .jalr(jalr_id),
    .br_type(br_type_id),
    .wb_en(rf_we_id),//write_back,RF写使能
    .wb_sel(rf_wd_sel_id),
    .alu_op1_sel(alu_src1_sel_id),
    .alu_op2_sel(alu_src2_sel_id),
    .alu_ctrl(alu_func_id),
    .imm_type(imm_type_id),
    .mem_we(dm_we_id),

    .lb(lb_id),
    .lw(lw_id),
    .lh(lh_id),
    .lbu(lbu_id),
    .lhu(lhu_id),

    .sw_sh_sb(sw_sh_sb_id),

    .float(float_id),
    .rf_read_sel_id(rf_read_sel_id),
    .rf_wb_sel_id(rf_wb_sel_id),
    .rm(rm_id),

    .rf_re0(rf_re0_id),
    .rf_re1(rf_re1_id)
    );

    SEG_REG seg_reg_id_ex(
    .clk(clk),
    .flush(flush_ex),
    .stall(stall_ex),
    .pc_cur_in(pc_cur_id),
    .pc_cur_out(pc_cur_ex),
    .inst_in(inst_id),
    .inst_out(inst_ex),
    .rf_ra0_in(rf_ra0_id),
    .rf_ra0_out(rf_ra0_ex),
    .rf_ra1_in(rf_ra1_id),
    .rf_ra1_out(rf_ra1_ex),
    .rf_re0_in(rf_re0_id),
    .rf_re0_out(rf_re0_ex),
    .rf_re1_in(rf_re1_id),
    .rf_re1_out(rf_re1_ex),
    .rf_rd0_raw_in(rf_rd0_raw_id),
    .rf_rd0_raw_out(rf_rd0_raw_ex),
    .rf_rd1_raw_in(rf_rd1_raw_id),
    .rf_rd1_raw_out(rf_rd1_raw_ex),
    .rf_rd0_in(32'h0),
    .rf_rd0_out(),
    .rf_rd1_in(32'h0),
    .rf_rd1_out(),
    .rf_wa_in(rf_wa_id),
    .rf_wa_out(rf_wa_ex),
    .rf_wd_sel_in(rf_wd_sel_id),
    .rf_wd_sel_out(rf_wd_sel_ex),
    .rf_we_in(rf_we_id),
    .rf_we_out(rf_we_ex),
    .imm_type_in(imm_type_id),
    .imm_type_out(imm_type_ex),
    .imm_in(imm_id),
    .imm_out(imm_ex),
    .alu_src1_sel_in(alu_src1_sel_id),
    .alu_src1_sel_out(alu_src1_sel_ex),
    .alu_src2_sel_in(alu_src2_sel_id),
    .alu_src2_sel_out(alu_src2_sel_ex),
    .alu_src1_in(32'h0),
    .alu_src1_out(),
    .alu_src2_in(32'h0),
    .alu_src2_out(),
    .alu_func_in(alu_func_id),
    .alu_func_out(alu_func_ex),
    .alu_ans_in(32'h0),
    .alu_ans_out(),
    .pc_add4_in(pc_add4_id),
    .pc_add4_out(pc_add4_ex),
    .pc_br_in(32'h0),
    .pc_br_out(),
    .pc_jal_in(32'h0),
    .pc_jal_out(),
    .pc_jalr_in(32'h0),
    .pc_jalr_out(),
    .jal_in(jal_id),
    .jal_out(jal_ex),
    .jalr_in(jalr_id),
    .jalr_out(jalr_ex),
    .br_type_in(br_type_id),
    .br_type_out(br_type_ex),
    .br_in(1'h0),
    .br_out(),
    .pc_sel_in(2'h0),
    .pc_sel_out(),
    .pc_next_in(32'h0),
    .pc_next_out(),
    .dm_addr_in(32'h0),
    .dm_addr_out(),
    .dm_din_in(rd1_id),
    .dm_din_out(dm_din_ex),//无效信号
    .dm_dout_in(32'h0),
    .dm_dout_out(),
    .dm_we_in(dm_we_id),
    .dm_we_out(dm_we_ex),

    .lb_in(lb_id),
    .lb_out(lb_ex),
    .lw_in(lw_id),
    .lw_out(lw_ex),
    .lh_in(lh_id),
    .lh_out(lh_ex),
    .lbu_in(lbu_id),
    .lbu_out(lbu_ex),
    .lhu_in(lhu_id),
    .lhu_out(lhu_ex),
    .sw_sh_sb_in(sw_sh_sb_id),
    .sw_sh_sb_out(sw_sh_sb_ex),

    .float_in(float_id),
    .float_out(float_ex),
    .rf_read_sel_in(rf_read_sel_id),
    .rf_read_sel_out(rf_read_sel_ex),
    .rf_wb_sel_in(rf_wb_sel_id),
    .rf_wb_sel_out(rf_wb_sel_ex),
    .rm_in(rm_id),
    .rm_out(rm_ex)
    );

    AND AND(
    .lhs(32'hFFFFFFFE), 
    .rhs(alu_ans_ex),
    .res(pc_jalr_ex)
    );

    Mux4 alu_sel1(
    .mux_sr1(rf_rd0_ex),
    .mux_sr2(pc_cur_ex),
    .mux_sr3(32'h0),
    .mux_sr4(32'h0),
    .mux_ctrl(alu_src1_sel_ex),
    .mux_out(alu_src1_ex)
    );  
    Mux2 alu_sel2(
    .mux_sr1(rf_rd1_ex),
    .mux_sr2(imm_ex),
    .mux_ctrl(alu_src2_sel_ex),
    .mux_out(alu_src2_ex)
    );  

    
    alu alu(
    .a(alu_src1_ex),
    .b(alu_src2_ex), 
    .func(alu_func_ex),
    .y(alu_ans_ex_no_float),
    .of()//悬空
    );

    falu falu(
    .a(alu_src1_ex),
    .b(alu_src2_ex), 
    .func(alu_func_ex),
    .y(alu_ans_ex_float),
    .rm(rm_ex)
    );

    branch branch(
    .op1(rf_rd0_ex),
    .op2(rf_rd1_ex),
    .br_type(br_type_ex),//考虑上次选做
    .br(br_ex) 
    );

    Encoder pc_sel_gen(
    .jal(jal_ex),
    .jalr(jalr_ex),
    .br(br_ex),
    .pc_sel(pc_sel_ex)
    );

    Mux2 rf_rd0_fwd(
    .mux_sr1(rf_rd0_raw_ex),
    .mux_sr2(rf_rd0_fd),
    .mux_ctrl(rf_rd0_fe),
    .mux_out(rf_rd0_ex)
    );  

    Mux2 rf_rd1_fwd(
    .mux_sr1(rf_rd1_raw_ex),
    .mux_sr2(rf_rd1_fd),
    .mux_ctrl(rf_rd1_fe),
    .mux_out(rf_rd1_ex)
    );  

    SEG_REG seg_reg_ex_mem(
    .clk(clk),
    .flush(flush_mem),
    .stall(1'h0),
    .pc_cur_in(pc_cur_ex),
    .pc_cur_out(pc_cur_mem),
    .inst_in(inst_ex),
    .inst_out(inst_mem),
    .rf_ra0_in(rf_ra0_ex),
    .rf_ra0_out(rf_ra0_mem),
    .rf_ra1_in(rf_ra1_ex),
    .rf_ra1_out(rf_ra1_mem),
    .rf_re0_in(rf_re0_ex),
    .rf_re0_out(rf_re0_mem),
    .rf_re1_in(rf_re1_ex),
    .rf_re1_out(rf_re1_mem),
    .rf_rd0_raw_in(rf_rd0_raw_ex),
    .rf_rd0_raw_out(rf_rd0_raw_mem),
    .rf_rd1_raw_in(rf_rd1_raw_ex),
    .rf_rd1_raw_out(rf_rd1_raw_mem),
    .rf_rd0_in(rf_rd0_ex),
    .rf_rd0_out(rf_rd0_mem),
    .rf_rd1_in(rf_rd1_ex),
    .rf_rd1_out(rf_rd1_mem),
    .rf_wa_in(rf_wa_ex),
    .rf_wa_out(rf_wa_mem),
    .rf_wd_sel_in(rf_wd_sel_ex),
    .rf_wd_sel_out(rf_wd_sel_mem),
    .rf_we_in(rf_we_ex),
    .rf_we_out(rf_we_mem),
    .imm_type_in(imm_type_ex),
    .imm_type_out(imm_type_mem),
    .imm_in(imm_ex),
    .imm_out(imm_mem),
    .alu_src1_sel_in(alu_src1_sel_ex),
    .alu_src1_sel_out(alu_src1_sel_mem),
    .alu_src2_sel_in(alu_src2_sel_ex),
    .alu_src2_sel_out(alu_src2_sel_mem),
    .alu_src1_in(alu_src1_ex),
    .alu_src1_out(alu_src1_mem),
    .alu_src2_in(alu_src2_ex),
    .alu_src2_out(alu_src2_mem),
    .alu_func_in(alu_func_ex),
    .alu_func_out(alu_func_mem),
    .alu_ans_in(alu_ans_ex),
    .alu_ans_out(alu_ans_mem),
    .pc_add4_in(pc_add4_ex),
    .pc_add4_out(pc_add4_mem),
    .pc_br_in(alu_ans_ex),
    .pc_br_out(pc_br_mem),
    .pc_jal_in(alu_ans_ex),
    .pc_jal_out(pc_jal_mem),
    .pc_jalr_in(pc_jalr_ex),
    .pc_jalr_out(pc_jalr_mem),
    .jal_in(jal_ex),
    .jal_out(jal_mem),
    .jalr_in(jalr_ex),
    .jalr_out(jalr_mem),
    .br_type_in(br_type_ex),
    .br_type_out(br_type_mem),
    .br_in(br_ex),
    .br_out(br_mem),
    .pc_sel_in(pc_sel_ex),
    .pc_sel_out(pc_sel_mem),
    .pc_next_in(pc_next),
    .pc_next_out(pc_next_mem),
    .dm_addr_in(alu_ans_ex),
    .dm_addr_out(dm_addr_mem),
    .dm_din_in(rf_rd1_ex),//bug
    .dm_din_out(dm_din_mem),
    .dm_dout_in(32'h0),
    .dm_dout_out(),
    .dm_we_in(dm_we_ex),
    .dm_we_out(dm_we_mem),

    .lb_in(lb_ex),
    .lb_out(lb_mem),
    .lw_in(lw_ex),
    .lw_out(lw_mem),
    .lh_in(lh_ex),
    .lh_out(lh_mem),
    .lbu_in(lbu_ex),
    .lbu_out(lbu_mem),
    .lhu_in(lhu_ex),
    .lhu_out(lhu_mem),
    .sw_sh_sb_in(sw_sh_sb_ex),
    .sw_sh_sb_out(sw_sh_sb_mem),

    .float_in(float_ex),
    .float_out(float_mem),
    .rf_read_sel_in(rf_read_sel_ex),
    .rf_read_sel_out(rf_read_sel_mem),
    .rf_wb_sel_in(rf_wb_sel_ex),
    .rf_wb_sel_out(rf_wb_sel_mem),
    .rm_in(rm_ex),
    .rm_out(rm_mem)
    );

    SEG_REG seg_reg_mem_wb(
    .clk(clk),
    .flush(1'h0),
    .stall(1'h0),
    .pc_cur_in(pc_cur_mem),
    .pc_cur_out(pc_cur_wb),
    .inst_in(inst_mem),
    .inst_out(inst_wb),
    .rf_ra0_in(rf_ra0_mem),
    .rf_ra0_out(rf_ra0_wb),
    .rf_ra1_in(rf_ra1_mem),
    .rf_ra1_out(rf_ra1_wb),
    .rf_re0_in(rf_re0_mem),
    .rf_re0_out(rf_re0_wb),
    .rf_re1_in(rf_re1_mem),
    .rf_re1_out(rf_re1_wb),
    .rf_rd0_raw_in(rf_rd0_raw_mem),
    .rf_rd0_raw_out(rf_rd0_raw_wb),
    .rf_rd1_raw_in(rf_rd1_raw_mem),
    .rf_rd1_raw_out(rf_rd1_raw_wb),
    .rf_rd0_in(rf_rd0_mem),
    .rf_rd0_out(rf_rd0_wb),
    .rf_rd1_in(rf_rd1_mem),
    .rf_rd1_out(rf_rd1_wb),
    .rf_wa_in(rf_wa_mem),
    .rf_wa_out(rf_wa_wb),
    .rf_wd_sel_in(rf_wd_sel_mem),
    .rf_wd_sel_out(rf_wd_sel_wb),
    .rf_we_in(rf_we_mem),
    .rf_we_out(rf_we_wb),
    .imm_type_in(imm_type_mem),
    .imm_type_out(imm_type_wb),
    .imm_in(imm_mem),
    .imm_out(imm_wb),
    .alu_src1_sel_in(alu_src1_sel_mem),
    .alu_src1_sel_out(alu_src1_sel_wb),
    .alu_src2_sel_in(alu_src2_sel_mem),
    .alu_src2_sel_out(alu_src2_sel_wb),
    .alu_src1_in(alu_src1_mem),
    .alu_src1_out(alu_src1_wb),
    .alu_src2_in(alu_src2_mem),
    .alu_src2_out(alu_src2_wb),
    .alu_func_in(alu_func_mem),
    .alu_func_out(alu_func_wb),
    .alu_ans_in(alu_ans_mem),
    .alu_ans_out(alu_ans_wb),
    .pc_add4_in(pc_add4_mem),
    .pc_add4_out(pc_add4_wb),
    .pc_br_in(pc_br_mem),
    .pc_br_out(pc_br_wb),
    .pc_jal_in(pc_jal_mem),
    .pc_jal_out(pc_jal_wb),
    .pc_jalr_in(pc_jalr_mem),
    .pc_jalr_out(pc_jalr_wb),
    .jal_in(jal_mem),
    .jal_out(jal_wb),
    .jalr_in(jalr_mem),
    .jalr_out(jalr_wb),
    .br_type_in(br_type_mem),
    .br_type_out(br_type_wb),
    .br_in(br_mem),
    .br_out(br_wb),
    .pc_sel_in(pc_sel_mem),
    .pc_sel_out(pc_sel_wb),
    .pc_next_in(pc_next_mem),
    .pc_next_out(pc_next_wb),
    .dm_addr_in(dm_addr_mem),
    .dm_addr_out(dm_addr_wb),
    .dm_din_in(dm_din_mem),
    .dm_din_out(dm_din_wb),
    .dm_dout_in(dm_dout),
    .dm_dout_out(dm_dout_wb),
    .dm_we_in(dm_we_mem),
    .dm_we_out(dm_we_wb),

    .lb_in(lb_mem),
    .lb_out(lb_wb),
    .lw_in(lw_mem),
    .lw_out(lw_wb),
    .lh_in(lh_mem),
    .lh_out(lh_wb),
    .lbu_in(lbu_mem),
    .lbu_out(lbu_wb),
    .lhu_in(lhu_mem),
    .lhu_out(lhu_wb),
    .sw_sh_sb_in(3'b0),
    .sw_sh_sb_out(),

    .float_in(float_mem),
    .float_out(float_wb),
    .rf_read_sel_in(rf_read_sel_mem),
    .rf_read_sel_out(rf_read_sel_wb),
    .rf_wb_sel_in(rf_wb_sel_mem),
    .rf_wb_sel_out(rf_wb_sel_wb),
    .rm_in(rm_mem),
    .rm_out(rm_wb)
    );

    dm_dout_wb_sel dm_dout_wb_sel(
    .lb_wb(lb_wb),
    .lw_wb(lw_wb),
    .lh_wb(lh_wb),
    .lbu_wb(lbu_wb),
    .lhu_wb(lhu_wb),
    .dm_dout_wb(dm_dout_wb),
    .dm_dout_wb_load(dm_dout_wb_load)
    );
    
    Mux4 reg_write_sel(
    .mux_sr1(alu_ans_wb),
    .mux_sr2(pc_add4_wb),
    .mux_sr3(dm_dout_wb_load),
    .mux_sr4(imm_wb),
.mux_ctrl(rf_wd_sel_wb),
    .mux_out(rf_wd_wb)
    );  

    Mux4 npc_sel(
    .mux_sr1(pc_add4_if),
    .mux_sr2(pc_jalr_ex),
    .mux_sr3(alu_ans_ex),//br
    .mux_sr4(alu_ans_ex), //jal 
    .mux_ctrl(pc_sel_ex), 
    .mux_out(pc_next)
    );

    // debug
    Check_Data_SEL check_data_sel_if(
        .pc_cur(pc_cur_if),
        .instruction(inst_if),
        .rf_ra0(inst_if[19:15]),
        .rf_ra1(inst_if[24:20]),
        .rf_re0(1'h0),
        .rf_re1(1'h0),
        .rf_rd0_raw(32'h0),
        .rf_rd1_raw(32'h0),
        .rf_rd0(32'h0),
        .rf_rd1(32'h0),
        .rf_wa(inst_if[11:7]),
        .rf_wd_sel(2'h0),
        .rf_wd(32'h0),
        .rf_we(1'h0),
        .immediate(32'h0),
        .alu_sr1(32'h0),
        .alu_sr2(32'h0),
        .alu_func(4'h0),
        .alu_ans(32'h0),
        .pc_add4(pc_add4_if),
        .pc_br(32'h0),
        .pc_jal(32'h0),
        .pc_jalr(32'h0),
        .pc_sel(2'h0),
        .pc_next(32'h0),
        .dm_addr(32'h0),
        .dm_din(32'h0),
        .dm_dout(32'h0),
        .dm_we(1'h0),   

        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_if)
    ); 

    Check_Data_SEL check_data_sel_id (
        .pc_cur(pc_cur_id),
        .instruction(inst_id),
        .rf_ra0(rf_ra0_id),
        .rf_ra1(rf_ra1_id),
        .rf_re0(rf_re0_id),
        .rf_re1(rf_re1_id),
        .rf_rd0_raw(rf_rd0_raw_id),
        .rf_rd1_raw(rf_rd1_raw_id),//bug
        .rf_rd0(32'h0),
        .rf_rd1(32'h0),
        .rf_wa(rf_wa_id),
        .rf_wd_sel(rf_wd_sel_id),
        .rf_wd(32'h0),
        .rf_we(rf_we_id),
        .immediate(imm_id),
        .alu_sr1(32'h0),
        .alu_sr2(32'h0),
        .alu_func(alu_func_id),
        .alu_ans(32'h0),
        .pc_add4(pc_add4_id),
        .pc_br(32'h0),
        .pc_jal(32'h0),
        .pc_jalr(32'h0),
        .pc_sel(2'h0),
        .pc_next(32'h0),
        .dm_addr(32'h0),
        .dm_din(rf_rd1_raw_id),
        .dm_dout(32'h0),
        .dm_we(dm_we_id),   

        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_id)
    ); 

    Check_Data_SEL check_data_sel_ex (
        .pc_cur(pc_cur_ex),
        .instruction(inst_ex),
        .rf_ra0(rf_ra0_ex),
        .rf_ra1(rf_ra1_ex),
        .rf_re0(rf_re0_ex),
        .rf_re1(rf_re1_ex),
        .rf_rd0_raw(rf_rd0_raw_ex),
        .rf_rd1_raw(rf_rd1_raw_ex),//bug
        .rf_rd0(rf_rd0_ex),
        .rf_rd1(rf_rd1_ex),
        .rf_wa(rf_wa_ex),
        .rf_wd_sel(rf_wd_sel_ex),
        .rf_wd(32'h0),
        .rf_we(rf_we_ex),
        .immediate(imm_ex),
        .alu_sr1(alu_src1_ex),
        .alu_sr2(alu_src2_ex),
        .alu_func(alu_func_ex),
        .alu_ans(alu_ans_ex),
        .pc_add4(pc_add4_ex),
        .pc_br(alu_ans_ex),
        .pc_jal(alu_ans_ex),
        .pc_jalr(pc_jalr_ex),
        .pc_sel(pc_sel_ex),
        .pc_next(pc_next),
        .dm_addr(alu_ans_ex),
        .dm_din(rf_rd1_ex),
        .dm_dout(32'h0),
        .dm_we(dm_we_ex),   

        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_ex)
    ); 

    Check_Data_SEL check_data_sel_mem (
        .pc_cur(pc_cur_mem),
        .instruction(inst_mem),
        .rf_ra0(rf_ra0_mem),
        .rf_ra1(rf_ra1_mem),
        .rf_re0(rf_re0_mem),
        .rf_re1(rf_re1_mem),
        .rf_rd0_raw(rf_rd0_raw_mem),
        .rf_rd1_raw(rf_rd1_raw_mem),//bug
        .rf_rd0(rf_rd0_mem),
        .rf_rd1(rf_rd1_mem),
        .rf_wa(rf_wa_mem),
        .rf_wd_sel(rf_wd_sel_mem),
        .rf_wd(32'h0),
        .rf_we(rf_we_mem),
        .immediate(imm_mem),
        .alu_sr1(alu_src1_mem),
        .alu_sr2(alu_src2_mem),
        .alu_func(alu_func_mem),
        .alu_ans(alu_ans_mem),
        .pc_add4(pc_add4_mem),
        .pc_br(pc_br_mem),
        .pc_jal(pc_jal_mem),
        .pc_jalr(pc_jalr_mem),
        .pc_sel(pc_sel_mem),
        .pc_next(pc_next_mem),
        .dm_addr(dm_addr_mem),
        .dm_din(dm_din_mem),
        .dm_dout(dm_dout),
        .dm_we(dm_we_mem),   

        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_mem)
    ); 

    Check_Data_SEL check_data_sel_wb (
        .pc_cur(pc_cur_wb),
        .instruction(inst_wb),
        .rf_ra0(rf_ra0_wb),
        .rf_ra1(rf_ra1_wb),
        .rf_re0(rf_re0_wb),
        .rf_re1(rf_re1_wb),
        .rf_rd0_raw(rf_rd0_raw_wb),
        .rf_rd1_raw(rf_rd1_raw_wb),//bug
        .rf_rd0(rf_rd0_wb),
        .rf_rd1(rf_rd1_wb),
        .rf_wa(rf_wa_wb),
        .rf_wd_sel(rf_wd_sel_wb),
        .rf_wd(rf_wd_wb),
        .rf_we(rf_we_wb),
        .immediate(imm_wb),
        .alu_sr1(alu_src1_wb),
        .alu_sr2(alu_src2_wb),
        .alu_func(alu_func_wb),
        .alu_ans(alu_ans_wb),
        .pc_add4(pc_add4_wb),
        .pc_br(pc_br_wb),
        .pc_jal(pc_jal_wb),
        .pc_jalr(pc_jalr_wb),
        .pc_sel(pc_sel_wb),
        .pc_next(pc_next_wb),
        .dm_addr(dm_addr_wb),
        .dm_din(dm_din_wb),
        .dm_dout(dm_dout_wb),
        .dm_we(dm_we_wb),   

        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_wb)
    ); 

    Check_Data_SEL_HZD check_data_sel_hzd (
        .rf_ra0_ex(rf_ra0_ex),
        .rf_ra1_ex(rf_ra1_ex),
        .rf_re0_ex(rf_re0_ex),
        .rf_re1_ex(rf_re1_ex),
        .pc_sel_ex(pc_sel_ex),
        .rf_wa_mem(rf_wa_mem),
        .rf_we_mem(rf_we_mem),
        .rf_wd_sel_mem(rf_wd_sel_mem),
        .alu_ans_mem(alu_ans_mem),
        .pc_add4_mem(pc_add4_mem),
        .imm_mem(imm_mem),
        .rf_wa_wb(rf_wa_wb),
        .rf_we_wb(rf_we_wb),
        .rf_wd_wb(rf_wd_wb),

        .rf_rd0_fe(rf_rd0_fe),
        .rf_rd1_fe(rf_rd1_fe),
        .rf_rd0_fd(rf_rd0_fd),
        .rf_rd1_fd(rf_rd1_fd),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .stall_ex(stall_ex),
        .flush_if(flush_if),
        .flush_id(flush_id),
        .flush_ex(flush_ex),
        .flush_mem(flush_mem),

        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_hzd)
    );

    Check_Data_SEG_SEL check_data_seg_sel (
        .check_data_if(check_data_if),
        .check_data_id(check_data_id),
        .check_data_ex(check_data_ex),
        .check_data_mem(check_data_mem),
        .check_data_wb(check_data_wb),
        .check_data_hzd(check_data_hzd),

        .check_addr(cpu_check_addr[7:5]),
        .check_data(check_data)
    ); 
    
    Mux2 cpu_check_data_sel(
        .mux_sr1(check_data),
        .mux_sr2(rf_rd_dbg_id),
        .mux_ctrl(cpu_check_addr[12]),
        .mux_out(cpu_check_data)
    );

    Hazard hazard(
    .rf_ra0_ex(rf_ra0_ex),
    .rf_ra1_ex(rf_ra1_ex),
    .rf_re0_ex(rf_re0_ex),
    .rf_re1_ex(rf_re1_ex),
    .rf_wa_mem(rf_wa_mem),
    .rf_we_mem(rf_we_mem),
    .rf_wd_sel_mem(rf_wd_sel_mem),
    .alu_ans_mem(alu_ans_mem),
    .pc_add4_mem(pc_add4_mem),
    .imm_mem(imm_mem),
    .rf_wa_wb(rf_wa_wb),
    .rf_we_wb(rf_we_wb),
    .rf_wd_wb(rf_wd_wb),
    .pc_sel_ex(pc_sel_ex),
    .jal_id(jal_id),

    .rf_rd0_fe(rf_rd0_fe),
    .rf_rd1_fe(rf_rd1_fe),
    .rf_rd0_fd(rf_rd0_fd),
    .rf_rd1_fd(rf_rd1_fd),
    .stall_if(stall_if),
    .stall_id(stall_id),
    .stall_ex(stall_ex),

    .flush_if(flush_if),
    .flush_id(flush_id),
    .flush_ex(flush_ex),
    .flush_mem(flush_mem),

    .float_id(float_id),
    .float_ex(float_ex),
    .float_mem(float_mem),
    .float_wb(float_wb),
    .rf_read_sel_ex(rf_read_sel_ex),
    .rf_wb_sel_mem(rf_wb_sel_mem),
    .rf_wb_sel_wb(rf_wb_sel_wb),
    .rf_wb_sel_id(rf_wb_sel_id),
    
    .rf_re0_id(rf_re0_id),
    .rf_re1_id(rf_re1_id),
    .rf_we_ex(rf_we_ex),
    .rf_ra0_id(rf_ra0_id),
    .rf_ra1_id(rf_ra1_id),
    .rf_wa_ex(rf_wa_ex),
    .rf_wd_sel_ex(rf_wd_sel_ex)
    );

    // jal_addr jal_addr(
    // .imm_id(imm_id),
    // .pc_cur_id(pc_cur_id),
    // .pc_jal_id(pc_jal_id)
    // );
    
    // Mux2#(.WIDTH(2)) jal_pc_sel (
    //     .mux_sr1(pc_sel_ex),
    //     .mux_sr2(2'b11),
    //     .mux_ctrl(jal_id),
    //     .mux_out(pc_sel)
    // );
endmodule