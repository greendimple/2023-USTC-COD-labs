`timescale 1ns / 1ps

module SEG_REG(
// control
input clk,
input flush,
input stall,
// IO
input [31:0] pc_cur_in,
output reg [31:0] pc_cur_out,
input [31:0] inst_in,
output reg [31:0] inst_out,
input [4:0] rf_ra0_in,
output reg [4:0] rf_ra0_out,
input [4:0] rf_ra1_in,
output reg [4:0] rf_ra1_out,
input rf_re0_in,
output reg rf_re0_out,
input rf_re1_in,
output reg rf_re1_out,
input [31:0] rf_rd0_raw_in,
output reg [31:0] rf_rd0_raw_out,
input [31:0] rf_rd1_raw_in,
output reg [31:0] rf_rd1_raw_out,
input [31:0] rf_rd0_in,
output reg [31:0] rf_rd0_out,
input [31:0] rf_rd1_in,
output reg [31:0] rf_rd1_out,
input [4:0] rf_wa_in,
output reg [4:0] rf_wa_out,
input [1:0] rf_wd_sel_in,
output reg [1:0] rf_wd_sel_out,
input rf_we_in,
output reg rf_we_out,
input [2:0] imm_type_in,
output reg [2:0] imm_type_out,
input [31:0] imm_in,
output reg [31:0] imm_out,
input [1:0] alu_src1_sel_in,//changed
output reg [1:0] alu_src1_sel_out,//changed
input alu_src2_sel_in,
output reg alu_src2_sel_out,
input [31:0] alu_src1_in,
output reg [31:0] alu_src1_out,
input [31:0] alu_src2_in,
output reg [31:0] alu_src2_out,
input [3:0] alu_func_in,
output reg [3:0] alu_func_out,
input [31:0] alu_ans_in,
output reg [31:0] alu_ans_out,
input [31:0] pc_add4_in,
output reg [31:0] pc_add4_out,
input [31:0] pc_br_in,
output reg [31:0] pc_br_out,
input [31:0] pc_jal_in,
output reg [31:0] pc_jal_out,
input [31:0] pc_jalr_in,
output reg [31:0] pc_jalr_out,
input jal_in,
output reg jal_out,
input jalr_in,
output reg jalr_out,
input [2:0] br_type_in,//changed
output reg [2:0] br_type_out,//changed
input br_in,
output reg br_out,
input [1:0] pc_sel_in,
output reg [1:0] pc_sel_out,
input [31:0] pc_next_in,
output reg [31:0] pc_next_out,
input [31:0] dm_addr_in,
output reg [31:0] dm_addr_out,
input [31:0] dm_din_in,
output reg [31:0] dm_din_out,
input [31:0] dm_dout_in,
output reg [31:0] dm_dout_out,
input dm_we_in,
output reg dm_we_out,
// for load
input lb_in,
output reg lb_out,
input lw_in,
output reg lw_out,
input lh_in,
output reg lh_out,
input lbu_in,
output reg lbu_out,
input lhu_in,
output reg lhu_out,
// for store
input [2:0] sw_sh_sb_in,
output reg [2:0] sw_sh_sb_out,
// for floating point
input float_in,
output reg float_out,
input rf_read_sel_in,
output reg rf_read_sel_out,
input rf_wb_sel_in,
output reg rf_wb_sel_out,
input [2:0] rm_in,
output reg [2:0] rm_out
);

always @(posedge clk) begin
    if(flush)begin
        pc_cur_out<=32'b0;
        inst_out<=32'b0;
        rf_ra0_out<=5'b0;
        rf_ra1_out<=5'b0;
        rf_re0_out<=1'b0;
        rf_re1_out<=1'b0;
        rf_rd0_raw_out<=32'b0;
        rf_rd1_raw_out<=32'b0;
        rf_rd0_out<=32'b0;
        rf_rd1_out<=32'b0;
        rf_wa_out<=5'b0;
        rf_wd_sel_out<=2'b0;
        rf_we_out<=1'b0;
        imm_type_out<=3'b0;
        imm_out<=32'b0;
        alu_src1_sel_out<=1'b0;
        alu_src2_sel_out<=1'b0;
        alu_src1_out<=32'b0;
        alu_src2_out<=32'b0;
        alu_func_out<=4'b0;
        alu_ans_out<=32'b0;
        pc_add4_out<=32'b0;
        pc_br_out<=32'b0;
        pc_jal_out<=32'b0;
        pc_jalr_out<=32'b0;
        jal_out<=1'b0;
        jalr_out<=1'b0;
        br_type_out<=2'b0;
        br_out<=1'b0;
        pc_sel_out<=2'b0;
        pc_next_out<=32'b0;
        dm_addr_out<=32'b0;
        dm_din_out<=32'b0;
        dm_dout_out<=32'b0;
        dm_we_out<=1'b0;
        lb_out<=1'b0;
        lw_out<=1'b0;
        lh_out<=1'b0;
        lbu_out<=1'b0;
        lhu_out<=1'b0;
        sw_sh_sb_out<=3'b0;
        float_out<=0;
        rf_read_sel_out<=0;
        rf_wb_sel_out<=0;
        rm_out<=3'b0;
    end
    else if(stall)begin
        pc_cur_out<=pc_cur_out;
        inst_out<=inst_out;
        rf_ra0_out<=rf_ra0_out;
        rf_ra1_out<=rf_ra1_out;
        rf_re0_out<=rf_re0_out;
        rf_re1_out<=rf_re1_out;
        rf_rd0_raw_out<=rf_rd0_raw_out;
        rf_rd1_raw_out<=rf_rd1_raw_out;
        rf_rd0_out<=rf_rd0_out;
        rf_rd1_out<=rf_rd1_out;
        rf_wa_out<=rf_wa_out;
        rf_wd_sel_out<=rf_wd_sel_out;
        rf_we_out<=rf_we_out;
        imm_type_out<=imm_type_out;
        imm_out<=imm_out;
        alu_src1_sel_out<=alu_src1_sel_out;
        alu_src2_sel_out<=alu_src2_sel_out;
        alu_src1_out<=alu_src1_out;
        alu_src2_out<=alu_src2_out;
        alu_func_out<=alu_func_out;
        alu_ans_out<=alu_ans_out;
        pc_add4_out<=pc_add4_out;
        pc_br_out<=pc_br_out;
        pc_jal_out<=pc_jal_out;
        pc_jalr_out<=pc_jalr_out;
        jal_out<=jal_out;
        jalr_out<=jalr_out;
        br_type_out<=br_type_out;
        br_out<=br_out;
        pc_sel_out<=pc_sel_out;
        pc_next_out<=pc_next_out;
        dm_addr_out<=dm_addr_out;
        dm_din_out<=dm_din_out;
        dm_dout_out<=dm_dout_out;
        dm_we_out<=dm_we_out;
        lb_out<=lb_out;
        lw_out<=lw_out;
        lh_out<=lh_out;
        lbu_out<=lbu_out;
        lhu_out<=lhu_out;
        sw_sh_sb_out<=sw_sh_sb_out;
        float_out<=float_out;
        rf_read_sel_out<=rf_read_sel_out;
        rf_wb_sel_out<=rf_wb_sel_out;
        rm_out<=rm_out;
    end
    else begin
        pc_cur_out<=pc_cur_in;
        inst_out<=inst_in;
        rf_ra0_out<=rf_ra0_in;
        rf_ra1_out<=rf_ra1_in;
        rf_re0_out<=rf_re0_in;
        rf_re1_out<=rf_re1_in;
        rf_rd0_raw_out<=rf_rd0_raw_in;
        rf_rd1_raw_out<=rf_rd1_raw_in;
        rf_rd0_out<=rf_rd0_in;
        rf_rd1_out<=rf_rd1_in;
        rf_wa_out<=rf_wa_in;
        rf_wd_sel_out<=rf_wd_sel_in;
        rf_we_out<=rf_we_in;
        imm_type_out<=imm_type_in;
        imm_out<=imm_in;
        alu_src1_sel_out<=alu_src1_sel_in;
        alu_src2_sel_out<=alu_src2_sel_in;
        alu_src1_out<=alu_src1_in;
        alu_src2_out<=alu_src2_in;
        alu_func_out<=alu_func_in;
        alu_ans_out<=alu_ans_in;
        pc_add4_out<=pc_add4_in;
        pc_br_out<=pc_br_in;
        pc_jal_out<=pc_jal_in;
        pc_jalr_out<=pc_jalr_in;
        jal_out<=jal_in;
        jalr_out<=jalr_in;
        br_type_out<=br_type_in;
        br_out<=br_in;
        pc_sel_out<=pc_sel_in;
        pc_next_out<=pc_next_in;
        dm_addr_out<=dm_addr_in;
        dm_din_out<=dm_din_in;
        dm_dout_out<=dm_dout_in;
        dm_we_out<=dm_we_in;
        lb_out<=lb_in;
        lw_out<=lw_in;
        lh_out<=lh_in;
        lbu_out<=lbu_in;
        lhu_out<=lhu_in;
        sw_sh_sb_out<=sw_sh_sb_in;
        float_out<=float_in;
        rf_read_sel_out<=rf_read_sel_in;
        rf_wb_sel_out<=rf_wb_sel_in;
        rm_out<=rm_in;
    end
end

endmodule