`timescale 1ns / 1ps

module Hazard(
input [4:0] rf_ra0_ex,
input [4:0] rf_ra1_ex,
input rf_re0_ex,
input rf_re1_ex,

input [4:0] rf_wa_mem,
input [4:0] rf_wa_wb,

input rf_we_mem,
input rf_we_wb,

input [1:0] rf_wd_sel_mem,

input [31:0] alu_ans_mem,
input [31:0] pc_add4_mem,
input [31:0] imm_mem,

input [31:0] rf_wd_wb,

input [1:0] pc_sel_ex,
input jal_id,

input rf_re0_id,rf_re1_id,rf_we_ex,
input [4:0] rf_ra0_id,rf_ra1_id,rf_wa_ex,
input [1:0] rf_wd_sel_ex,

input float_id,float_ex,float_mem,float_wb,
input rf_read_sel_ex,rf_wb_sel_mem,rf_wb_sel_wb,rf_wb_sel_id,

output reg rf_rd0_fe,//forwarding enable
output reg rf_rd1_fe,
output reg [31:0] rf_rd0_fd,
output reg [31:0] rf_rd1_fd,
output reg stall_if,
output reg stall_id,
output reg stall_ex,

output reg flush_if,
output reg flush_id,
output reg flush_ex,
output reg flush_mem
);

// forwarding
always @(*) begin //for rd0
    // mem
    if(rf_we_mem==1 && rf_re0_ex!=0 && rf_ra0_ex==rf_wa_mem && (|rf_ra0_ex) && rf_wd_sel_mem!=2'b10
       && rf_read_sel_ex==rf_wb_sel_mem)begin
        rf_rd0_fe=1;
        if(rf_wd_sel_mem==2'b00) rf_rd0_fd=alu_ans_mem;
        else if(rf_wd_sel_mem==2'b01) rf_rd0_fd=pc_add4_mem;
        else rf_rd0_fd=imm_mem;
    end
    // wb
    else if(rf_we_wb==1 && rf_re0_ex!=0 && rf_ra0_ex==rf_wa_wb && (|rf_ra0_ex)
            && rf_read_sel_ex==rf_wb_sel_wb)begin
        rf_rd0_fe=1;
        rf_rd0_fd=rf_wd_wb;
    end
    else if(rf_we_mem==1 && rf_re0_ex!=0 && rf_ra0_ex==rf_wa_mem && (|rf_ra0_ex) && rf_wd_sel_mem==2'b10
            && rf_read_sel_ex==rf_wb_sel_mem)begin
        rf_rd0_fe=1;
        rf_rd0_fd=rf_wd_wb;
    end
    else begin
        rf_rd0_fe=1'b0;
        rf_rd0_fd=32'd0;
    end
end

always @(*) begin //for rd1
    // mem
    if(rf_we_mem==1 && rf_re1_ex!=0 && rf_ra1_ex==rf_wa_mem && (|rf_ra1_ex) && rf_wd_sel_mem!=2'b10
       && rf_read_sel_ex==rf_wb_sel_mem)begin
        rf_rd1_fe=1;
        if(rf_wd_sel_mem==2'b00) rf_rd1_fd=alu_ans_mem;
        else if(rf_wd_sel_mem==2'b01) rf_rd1_fd=pc_add4_mem;
        else rf_rd1_fd=imm_mem;
    end
    // wb
    else if(rf_we_wb==1 && rf_re1_ex!=0 && rf_ra1_ex==rf_wa_wb && (|rf_ra1_ex)
            && rf_read_sel_ex==rf_wb_sel_wb)begin
        rf_rd1_fe=1;
        rf_rd1_fd=rf_wd_wb;
    end
    else if(rf_we_mem==1 && rf_re1_ex!=0 && rf_ra1_ex==rf_wa_mem && (|rf_ra1_ex) && rf_wd_sel_mem==2'b10
            && rf_read_sel_ex==rf_wb_sel_mem)begin
        rf_rd1_fe=1;
        rf_rd1_fd=rf_wd_wb;
    end
    // else if (rf_we_ex && rf_re1_id && rf_wa_ex == rf_ra1_id && rf_wd_sel_ex == 2'b10)begin
    //     rf_rd1_fe=1;
    //     rf_rd1_fd=rf_wd_wb;
    // end
    else begin
        rf_rd1_fe=1'b0;
        rf_rd1_fd=32'd0;
    end
end

// load use
always @(*) begin
    // 假定 WB_SEL_MEM 代表寄存器堆写回选择器选择 MEM_dout 的结果
    // 增加 rf_re0_id、rf_re1_id、rf_ra0_id、rf_ra1_id、rf_we_ex、rf_wa_ex、rf_wd_sel_ex 即可
    if (rf_we_ex && rf_re0_id && rf_wa_ex == rf_ra0_id && rf_wd_sel_ex == 2'b10 && rf_read_sel_ex==rf_wb_sel_id
     || rf_we_ex && rf_re1_id && rf_wa_ex == rf_ra1_id && rf_wd_sel_ex == 2'b10 && rf_read_sel_ex==rf_wb_sel_id)
    begin
        stall_if = 1'b1;
        stall_id = 1'b1;
        stall_ex = 1'b0;
    end
    // else if((rf_we_mem==1 && rf_re0_ex!=0 && rf_ra0_ex==rf_wa_mem && (|rf_ra0_ex) && rf_wd_sel_mem==2'b10)
    //       ||(rf_we_mem==1 && rf_re1_ex!=0 && rf_ra1_ex==rf_wa_mem && (|rf_ra1_ex) && rf_wd_sel_mem==2'b10))begin
    //     stall_if=1'b1;
    //     stall_id=1'b1;
    //     stall_ex=1'b1;
    // end

    else begin
        stall_if=1'b0;
        stall_id=1'b0;
        stall_ex=1'b0;
    end
end

// branch jal jalr
always @(*) begin
    if(pc_sel_ex==2'b01 || pc_sel_ex==2'b11)begin//jalr jal
        flush_if=1'b0;
        flush_id=1'b1;
        flush_ex=1'b1;
        flush_mem=1'b0;//2nd method
    end
    else if(pc_sel_ex==2'b10 )begin//branch
        flush_if=1'b0;
        flush_id=1'b1;
        flush_ex=1'b1;
        flush_mem=1'b1;//2nd method
    end
    // else if(jal_id)begin//jal
    //     flush_if=1'b0;
    //     flush_id=1'b1;
    //     flush_ex=1'b0;
    //     flush_mem=1'b0;//2nd method
    // end
    else if(rf_we_ex && rf_re0_id && rf_wa_ex == rf_ra0_id && rf_wd_sel_ex == 2'b10 && rf_read_sel_ex==rf_wb_sel_id
         || rf_we_ex && rf_re1_id && rf_wa_ex == rf_ra1_id && rf_wd_sel_ex == 2'b10 && rf_read_sel_ex==rf_wb_sel_id) 
    begin
        flush_if=1'b0;
        flush_id=1'b0;
        flush_ex=1'b1;
        flush_mem=1'b0;
    end
    // else if((rf_we_mem==1 && rf_re0_ex!=0 && rf_ra0_ex==rf_wa_mem && (|rf_ra0_ex) && rf_wd_sel_mem==2'b10)
    //  ||(rf_we_mem==1 && rf_re1_ex!=0 && rf_ra1_ex==rf_wa_mem && (|rf_ra1_ex) && rf_wd_sel_mem==2'b10)) begin
    //     flush_if=1'b0;
    //     flush_id=1'b0;
    //     flush_ex=1'b0;
    //     flush_mem=1'b1;
    // end
    else begin
        flush_if=1'b0;
        flush_id=1'b0;
        flush_ex=1'b0;
        flush_mem=1'b0;//2nd method
    end
end

endmodule
