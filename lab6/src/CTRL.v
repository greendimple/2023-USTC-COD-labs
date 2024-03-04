`timescale 1ns / 1ps

module CTRL(
input     [31:0] inst,
output reg       jal,jalr,
output reg [2:0] br_type,
output reg       wb_en,//write_back,RF写使能
output reg [1:0] wb_sel,
output reg [1:0] alu_op1_sel,
output reg       alu_op2_sel,
output reg [3:0] alu_ctrl,
output reg [2:0] imm_type,
output reg       mem_we,
output reg       lb,lw,lh,lbu,lhu,
output reg [2:0] sw_sh_sb,

output reg rf_re0,
output reg rf_re1,

output reg float,//是否为浮点指令
output reg rf_read_sel_id,//读的是浮点寄存器还是整数寄存器
output reg rf_wb_sel_id,//写的是浮点寄存器还是整数寄存器
output [2:0] rm
);

assign rm=inst[14:12];

always @(*) begin
    case (inst[6:0])
        7'b0010011: begin
        if(inst[14:12]==3'b000)//addi
        begin 
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b00;//inst[19:15]
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b0000;//+
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        else if(inst[14:12]==3'b111)//andi
        begin
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b00;//inst[19:15]
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b0101;//&
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        else if(inst[14:12]==3'b100)//xori
        begin
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b00;//inst[19:15]
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b0111;//^
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        else if(inst[14:12]==3'b110)//ori
        begin
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b00;//inst[19:15]
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b0110;//|
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        else if(inst[14:12]==3'b010)//slti
        begin
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b00;//inst[19:15]
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b0100;//< signed
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        else if(inst[14:12]==3'b011)//sltiu
        begin
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b00;//inst[19:15]
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b0011;//< unsigned
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        else if(inst[14:12]==3'b001 && inst[31:25]==7'b0)//slli
        begin
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b00;//inst[19:15]
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b1001;//<<
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        else if(inst[14:12]==3'b101 && inst[31:25]==7'b0)//srli
        begin
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b00;//inst[19:15]
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b1000;//>>
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        else if(inst[14:12]==3'b101 && inst[31:25]==7'b0100000)//srai
        begin
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b00;//inst[19:15]
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b1010;//>>>
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        else//全0
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                wb_en=1'b0;//do not write back
                wb_sel=2'b00;//随便
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b0;//rs2
                alu_ctrl=4'b0000;//+
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem
                rf_re0=1'b0;
                rf_re1=1'b0;
                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
        end

        7'b0110011: begin 
            if(inst[14:12]==3'b111 && inst[31:25]==7'b0)//and
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b0101;//&
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b000 && inst[31:25]==7'b0)//add
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b0000;//+
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b000 && inst[31:25]==7'b0100000)//sub
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b0001;//-
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b110)//or
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b0110;//|
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b100)//xor
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b0111;//^
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b001)//sll
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b1001;//<<
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b101 && inst[31:25]==7'b0000000)//srl
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b1000;//>>
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b101 && inst[31:25]==7'b0100000)//sra
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b1010;//>>>
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b010)//slt
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b0100;//< signed
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b011)//sltu
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b0;//alu out
                alu_op1_sel=2'b00;//inst[19:15]
                alu_op2_sel=1'b0;//inst[24:20]
                alu_ctrl=4'b0011;//< unsigned
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else//全0
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                wb_en=1'b0;//do not write back
                wb_sel=2'b00;//随便
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b0;//rs2
                alu_ctrl=4'b0000;//+
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                rf_re0=1'b0;
                rf_re1=1'b0;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
        end
        7'b0110111: begin //lui
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b10;//12
            alu_op2_sel=1'b1;//imm(已经左移12bit)
            alu_ctrl=4'b0000;//+
            imm_type=3'b100;//U-type
            mem_we=1'b0;//do not write mem

            rf_re0=1'b0;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        7'b0010111: begin //auipc
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b0;//alu out
            alu_op1_sel=2'b01;//pc
            alu_op2_sel=1'b1;//imm(已经左移12bit)
            alu_ctrl=4'b0000;//+
            imm_type=3'b100;//U-type
            mem_we=1'b0;//do not write mem

            rf_re0=1'b0;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        7'b1101111: begin //jal
            jal=1;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b01;//pc+4
            alu_op1_sel=2'b01;//inst[19:12],rs1
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b0000;//+,结果给NPC_sel
            imm_type=3'b101;//J-type
            mem_we=1'b0;//do not write mem

            rf_re0=1'b0;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        7'b1100111: begin //jalr
            jal=0;
            jalr=1;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            if(inst[11:7]==3'b000) wb_en=1'b0;//write back
            else wb_en=1'b1;
            wb_sel=2'b01;//pc+4
            alu_op1_sel=2'b00;//rs1
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b0000;//+,结果给AND,再给NPC_sel
            imm_type=3'b001;//I-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            rf_re1=1'b0;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        7'b1100011: begin 
            if(inst[14:12]==3'b000)//beq
                br_type=3'b001;//beq
            else if(inst[14:12]==3'b100)//blt
                br_type=3'b010;//blt
            else if(inst[14:12]==3'b001)//bne
                br_type=3'b011;//bne
            else if(inst[14:12]==3'b111)//bgeu
                br_type=3'b100;//bgeu
            else if(inst[14:12]==3'b110)//bltu
                br_type=3'b101;//bltu
            else if(inst[14:12]==3'b101)//bge
                br_type=3'b110;//bge
            else br_type=3'b000;//do not branch
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            wb_en=1'b0;//do not write back
            wb_sel=2'b11;//随便
            alu_op1_sel=2'b01;//pc
            alu_op2_sel=1'b1;//imm
            alu_ctrl=4'b0000;//+
            imm_type=3'b011;//B-type
            mem_we=1'b0;//do not write mem

            if(inst[19:15]==3'b000) rf_re0=1'b0;
            else rf_re0=1'b1;
            if(inst[24:20]==3'b000) rf_re1=1'b0;
            else rf_re1=1'b1;

            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
        7'b0000011: begin 
            if(inst[14:12]==3'b010)//lw
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=1;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b10;//mem_read_data
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b1;//imm
                alu_ctrl=4'b0000;//+,结果作为地址给mem_addr
                imm_type=3'b001;//I-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                rf_re1=1'b0;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b000)//lb
            begin
                jal=0;
                jalr=0;
                lb=1;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b10;//mem_read_data
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b1;//imm
                alu_ctrl=4'b0000;//+,结果作为地址给mem_addr
                imm_type=3'b001;//I-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                rf_re1=1'b0;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b001)//lh
            begin
                jal=0;
                jalr=0;
                lb=0;lh=1;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b10;//mem_read_data
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b1;//imm
                alu_ctrl=4'b0000;//+,结果作为地址给mem_addr
                imm_type=3'b001;//I-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                rf_re1=1'b0;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b100)//lbu
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=1;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b10;//mem_read_data
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b1;//imm
                alu_ctrl=4'b0000;//+,结果作为地址给mem_addr
                imm_type=3'b001;//I-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                rf_re1=1'b0;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b101)//lhu
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=1;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                if(inst[11:7]==3'b000) wb_en=1'b0;//write back
                else wb_en=1'b1;
                wb_sel=2'b10;//mem_read_data
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b1;//imm
                alu_ctrl=4'b0000;//+,结果作为地址给mem_addr
                imm_type=3'b001;//I-type
                mem_we=1'b0;//do not write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                rf_re1=1'b0;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                wb_en=1'b0;//do not write back
                wb_sel=2'b00;//随便
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b0;//rs2
                alu_ctrl=4'b0000;//+
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                rf_re0=1'b0;
                rf_re1=1'b0;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
        end
        7'b0100011: begin 
            if(inst[14:12]==3'b010)//sw
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b100;
                br_type=3'b00;//not branch
                wb_en=1'b0;//do not write back
                wb_sel=2'b10;//随便
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b1;//imm
                alu_ctrl=4'b0000;//+,结果作为地址给mem_addr
                imm_type=3'b010;//S-type
                mem_we=1'b1;//write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b001)//sh
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b010;
                br_type=3'b00;//not branch
                wb_en=1'b0;//do not write back
                wb_sel=2'b10;//随便
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b1;//imm
                alu_ctrl=4'b0000;//+,结果作为地址给mem_addr
                imm_type=3'b010;//S-type
                mem_we=1'b1;//write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else if(inst[14:12]==3'b000)//sb
            begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b001;
                br_type=3'b00;//not branch
                wb_en=1'b0;//do not write back
                wb_sel=2'b10;//随便
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b1;//imm
                alu_ctrl=4'b0000;//+,结果作为地址给mem_addr
                imm_type=3'b010;//S-type
                mem_we=1'b1;//write mem

                if(inst[19:15]==3'b000) rf_re0=1'b0;
                else rf_re0=1'b1;
                if(inst[24:20]==3'b000) rf_re1=1'b0;
                else rf_re1=1'b1;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
            else begin
                // 全0
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                wb_en=1'b0;//do not write back
                wb_sel=2'b00;//随便
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b0;//rs2
                alu_ctrl=4'b0000;//+
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                rf_re0=1'b0;
                rf_re1=1'b0;

                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
        end

        // floating point instruction //
        7'b1010011: begin
            if(inst[31:25]==7'b0) begin//fadd.s
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                wb_en=1'b1;//write back
                wb_sel=2'b00;//alu
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b0;//rs2
                alu_ctrl=4'b1011;//fadd
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                rf_re0=1'b1;
                rf_re1=1'b1;

                float=1;
                rf_read_sel_id=1;
                rf_wb_sel_id=1;
            end
            else if(inst[31:25]==7'b0000100) begin//fsub.s
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                wb_en=1'b1;//write back
                wb_sel=2'b00;//alu
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b0;//rs2
                alu_ctrl=4'b1100;//fsub
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                rf_re0=1'b1;
                rf_re1=1'b1;

                float=1;
                rf_read_sel_id=1;
                rf_wb_sel_id=1;
            end
            else if(inst[31:25]==7'b1100000) begin//fcvt.w.s
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                wb_en=1'b1;//write back
                wb_sel=2'b00;//alu
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b0;//rs2
                alu_ctrl=4'b1101;//fcvt.w.s
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                rf_re0=1'b1;
                rf_re1=1'b0;
                
                float=1;
                rf_read_sel_id=1;
                rf_wb_sel_id=0;
            end
            else if(inst[31:25]==7'b1101000) begin//fcvt.s.w
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                wb_en=1'b1;//write back
                wb_sel=2'b00;//alu
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b0;//rs2
                alu_ctrl=4'b1110;//fcvt.s.w
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                rf_re0=1'b1;
                rf_re1=1'b0;
                
                float=1;
                rf_read_sel_id=0;
                rf_wb_sel_id=1;
            end
            else begin
                jal=0;
                jalr=0;
                lb=0;lh=0;lw=0;lbu=0;lhu=0;
                sw_sh_sb=3'b000;
                br_type=3'b00;//not branch
                wb_en=1'b0;//do not write back
                wb_sel=2'b00;//随便
                alu_op1_sel=2'b00;//rs1
                alu_op2_sel=1'b0;//rs2
                alu_ctrl=4'b0000;//+
                imm_type=3'b000;//R-type
                mem_we=1'b0;//do not write mem

                rf_re0=1'b0;
                rf_re1=1'b0;
                float=0;
                rf_read_sel_id=0;
                rf_wb_sel_id=0;
            end
        end

        default: begin
            // 全0
            jal=0;
            jalr=0;
            lb=0;lh=0;lw=0;lbu=0;lhu=0;
            sw_sh_sb=3'b000;
            br_type=3'b00;//not branch
            wb_en=1'b0;//do not write back
            wb_sel=2'b00;//随便
            alu_op1_sel=2'b00;//rs1
            alu_op2_sel=1'b0;//rs2
            alu_ctrl=4'b0000;//+
            imm_type=3'b000;//R-type
            mem_we=1'b0;//do not write mem

            rf_re0=1'b0;
            rf_re1=1'b0;
            float=0;
            rf_read_sel_id=0;
            rf_wb_sel_id=0;
        end
    endcase
end
endmodule
