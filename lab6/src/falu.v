`timescale 1ns / 1ps

module falu #(parameter WIDTH = 32) //数据宽度
(
input [WIDTH-1:0] a, b, //两操作数（对于减运算，a是被减数）
input [3:0] func, //操作功能（加、减、与、或、异或等）
input [2:0] rm, //rounding mode(浮点)
output reg [WIDTH-1:0] y //运算结果（和、差 …）
);

// reg sign;
reg [31:0] tmp,tmp1,tmp2;
reg [7:0] exp,exp1,exp2,width;
reg [22:0] frac,frac1,frac2;
integer width1,width2,i,j;

always @(*) begin
    case (func)
        4'b1011: begin//fadd //rne
            exp1 = a[30:23];
            exp2 = b[30:23];
            frac1 = a[22:0];
            frac2 = b[22:0];
            width1=exp1-127;
            width2=exp2-127;
          
            if(exp1>=exp2) begin
                i=exp2;
                tmp={8'd0,1'b1,frac2}>>(exp1-exp2);//指数相同时的有效数字部分

                if(a[31]==b[31]) begin//shift right
                    tmp1=tmp+{8'd0,1'b1,frac1};//add
                    if(tmp1[24]) begin 
                        if(tmp1[0]==0) frac=tmp1[23:1];//直接舍去
                        else begin
                            if(tmp1[1]==0) frac=tmp1[23:1];//直接舍去
                            else frac=tmp1[23:1]+1;//进一
                        end
                        exp=exp1+1;
                    end
                    else begin frac=tmp1[22:0];exp=exp1;end
                    y={a[31],exp,frac};
                end
                else if(a[31]&(~b[31])) begin//shift left
                        tmp1=-tmp+{8'd0,1'b1,frac1};//sub
                        j=0;
                        // while(!tmp1[i] && i>=0) i=i-1;//i位置为第一个1
                        for(i=0;i<=23;i=i+1) if(tmp1[i] && i>j) j=i;
                        for(i=22;i>=0;i=i-1) 
                            if(j+i-23>=0) frac[i]=tmp1[j+i-23];
                            else frac[i]=0;//无舍入
                        exp=exp1-(23-j);
                        y={1'b1,exp,frac};
                end
                else begin//shift left
                        tmp1=-tmp+{8'd0,1'b1,frac1};//sub
                        j=0;
                        for(i=0;i<=23;i=i+1) if(tmp1[i] && i>j) j=i;
                        for(i=22;i>=0;i=i-1) 
                            if(j+i-23>=0) frac[i]=tmp1[j+i-23];
                            else frac[i]=0;//无舍入
                        exp=exp1-(23-j);
                        y={1'b0,exp,frac};
                end
            end
            else begin//exp1<exp2
                i=exp1;
                tmp={8'd0,1'b1,frac1}>>(exp2-exp1);//指数相同时的有效数字部分
                if(a[31]==b[31]) begin
                    tmp1=tmp+{8'd0,1'b1,frac2};//add
                    if(tmp1[24]) begin 
                        if(tmp1[0]==0) frac=tmp1[23:1];//直接舍去
                        else begin
                            if(tmp1[1]==0) frac=tmp1[23:1];//直接舍去
                            else frac=tmp1[23:1]+1;//进一
                        end
                        exp=exp2+1;
                    end
                    else begin frac=tmp1[22:0];exp=exp2;end
                    y={b[31],exp,frac};
                end
                else if(a[31]&(~b[31])) begin
                        tmp1=-tmp+{8'd0,1'b1,frac2};//sub
                        j=0;
                        for(i=0;i<=23;i=i+1) if(tmp1[i] && i>j) j=i;//i位置为第一个1
                        for(i=22;i>=0;i=i-1) 
                            if(j+i-23>=0) frac[i]=tmp1[j+i-23];
                            else frac[i]=0;//无舍入
                        exp=exp2-(23-j);
                        y={1'b0,exp,frac};
                end
                else begin
                        tmp1=-tmp+{8'd0,1'b1,frac2};//sub
                        j=0;
                        for(i=0;i<=23;i=i+1) if(tmp1[i] && i>j) j=i;//i位置为第一个1
                        for(i=22;i>=0;i=i-1) 
                            if(j+i-23>=0) frac[i]=tmp1[j+i-23];
                            else frac[i]=0;//无舍入
                        exp=exp2-(23-j);
                        y={1'b1,exp,frac};
                end
            end
        end
        4'b1100: begin//fsub //rne
            exp1 = a[30:23];
            exp2 = b[30:23];
            frac1 = a[22:0];
            frac2 = b[22:0];
            width1=exp1-127;
            width2=exp2-127;
          
            if(exp1>=exp2) begin
                i=exp2;
                tmp={8'd0,1'b1,frac2}>>(exp1-exp2);//指数相同时的有效数字部分

                if(a[31]!=b[31]) begin//shift right
                    tmp1=tmp+{8'd0,1'b1,frac1};//add
                    if(tmp1[24]) begin 
                        if(tmp1[0]==0) frac=tmp1[23:1];//直接舍去
                        else begin
                            if(tmp1[1]==0) frac=tmp1[23:1];//直接舍去
                            else frac=tmp1[23:1]+1;//进一
                        end
                        exp=exp1+1;
                    end
                    else begin frac=tmp1[22:0];exp=exp1;end
                    y={a[31],exp,frac};
                end
                else if(a[31]) begin//shift left 均为负
                        tmp1=-tmp+{8'd0,1'b1,frac1};//sub
                        j=0;
                        // while(!tmp1[i] && i>=0) i=i-1;//i位置为第一个1
                        for(i=0;i<=23;i=i+1) if(tmp1[i] && i>j) j=i;
                        for(i=22;i>=0;i=i-1) 
                            if(j+i-23>=0) frac[i]=tmp1[j+i-23];
                            else frac[i]=0;//无舍入
                        exp=exp1-(23-j);
                        y={1'b1,exp,frac};
                end
                else begin//shift left 均为正
                        tmp1=-tmp+{8'd0,1'b1,frac1};//sub
                        j=0;
                        for(i=0;i<=23;i=i+1) if(tmp1[i] && i>j) j=i;
                        for(i=22;i>=0;i=i-1) 
                            if(j+i-23>=0) frac[i]=tmp1[j+i-23];
                            else frac[i]=0;//无舍入
                        exp=exp1-(23-j);
                        y={1'b0,exp,frac};
                end
            end
            else begin//exp1<exp2
                i=exp1;
                tmp={8'd0,1'b1,frac1}>>(exp2-exp1);//指数相同时的有效数字部分
                if(a[31]!=b[31]) begin
                    tmp1=tmp+{8'd0,1'b1,frac2};//add
                    if(tmp1[24]) begin 
                        if(tmp1[0]==0) frac=tmp1[23:1];//直接舍去
                        else begin
                            if(tmp1[1]==0) frac=tmp1[23:1];//直接舍去
                            else frac=tmp1[23:1]+1;//进一
                        end
                        exp=exp2+1;
                    end
                    else begin frac=tmp1[22:0];exp=exp2;end
                    y={a[31],exp,frac};
                end
                else if(!a[31]) begin//均为正
                        tmp1=-tmp+{8'd0,1'b1,frac2};//sub
                        j=0;
                        for(i=0;i<=23;i=i+1) if(tmp1[i] && i>j) j=i;//i位置为第一个1
                        for(i=22;i>=0;i=i-1) 
                            if(j+i-23>=0) frac[i]=tmp1[j+i-23];
                            else frac[i]=0;//无舍入
                        exp=exp2-(23-j);
                        y={1'b1,exp,frac};
                end
                else begin//均为负
                        tmp1=-tmp+{8'd0,1'b1,frac2};//sub
                        j=0;
                        for(i=0;i<=23;i=i+1) if(tmp1[i] && i>j) j=i;//i位置为第一个1
                        for(i=22;i>=0;i=i-1) 
                            if(j+i-23>=0) frac[i]=tmp1[j+i-23];
                            else frac[i]=0;//无舍入
                        exp=exp2-(23-j);
                        y={1'b0,exp,frac};
                end
            end
        end
        4'b1101: begin//fcvt.w.s
        // 把寄存器 f[rs1]中的单精度浮点数转化为 32 位二进制补码表示的整数，再写入 x[rd]中
            exp = a[30:23];
            frac = a[22:0];
            width=a[30:23]-127;//尾数被截取的宽度，可能大于23
            tmp=0;

            if(rm==3'b000 || rm==3'b111) begin//Round to Nearest, ties to Even ,rne
                if(width>=23) begin
                    tmp=0;
                    tmp=frac<<(width-23);
                    tmp[width]=1;
                    y=(a[31]?-tmp:tmp);
                end
                else if( width<23 && frac[22-width]==0) begin//舍去
                    j=23-width;
                    tmp=0;
                    for(i=0;i<width && i<32;i=i+1) begin
                        tmp[i]=frac[j+i];
                    end
                    tmp[i]=1;
                    y=(a[31]?-tmp:tmp);
                end
                else begin//进位
                    if((frac<<(width+1))==0) begin//小数部分==0.5
                        if(frac[23-width]) begin//奇数，进一
                            // y=(a[31] ? -(frac>>(23-width)+32'b1<<width+32'd1) : (frac>>(23-width)+32'b1<<width+32'd1));
                            j=23-width;
                            tmp=0;
                            for(i=0;i<width && i<32;i=i+1) begin
                                tmp[i]=frac[j];
                                j=j+1;
                            end
                            tmp[i]=1;
                            y=(a[31]?-(tmp+1):tmp+1);
                        end
                        else begin//偶数，截去
                            j=23-width;
                            tmp=0;
                            for(i=0;i<width && i<32;i=i+1) begin
                                tmp[i]=frac[j];
                                j=j+1;
                            end
                            tmp[i]=1;
                            y=(a[31]?-tmp:tmp);
                        end
                    end
                    else//小数部分>0.5，进一
                        j=23-width;
                        tmp=0;
                        for(i=0;i<width && i<32;i=i+1) begin
                            tmp[i]=frac[j];
                            j=j+1;
                        end
                        tmp[i]=1;
                        y=(a[31]?-(tmp+1):tmp+1);
                end
            end

            else if(rm==3'b001) begin//Round towards Zero
                // 直接截尾
                if(width>=23) begin
                    tmp=0;
                    tmp=frac<<(width-23);
                    tmp[width]=1;
                    y=(a[31]?-tmp:tmp);
                end
                else begin
                    j=23-width;
                    tmp=0;
                    for(i=0;i<width && i<32;i=i+1) begin
                        tmp[i]=frac[j];
                        j=j+1;
                    end
                    tmp[i]=1;
                    y=(a[31]?-tmp:tmp);
                end
            end

            else if(rm==3'b010) begin//Round Down (towards −∞)
                if(width>=23) begin
                    tmp=0;
                    tmp=frac<<(width-23);
                    tmp[width]=1;
                    y=(a[31]?-tmp:tmp);
                end
                else begin
                    if(!a[31]) begin//正数直接截尾
                        // y=frac>>(23-width)+32'b1<<width;
                        j=23-width;
                        y=0;
                        for(i=0;i<width && i<32;i=i+1) begin
                            y[i]=frac[j];
                            j=j+1;
                        end
                        y[i]=1;
                    end
                    else begin
                        //负数多余位全为0直接截尾
                        if((frac<<width) == 0) begin
                            // y=-(frac>>(23-width)+32'b1<<width);
                            j=23-width;
                            tmp=0;
                            for(i=0;i<width && i<32;i=i+1) begin
                                tmp[i]=frac[j];
                                j=j+1;
                            end
                            tmp[i]=1;
                            y=-tmp;
                        end
                        //负数多余位不全为0进位1
                        else begin
                        // y=-(frac>>(23-width)+32'b1<<width+32'd1);
                            j=23-width;
                            tmp=0;
                            for(i=0;i<width && i<32;i=i+1) begin
                                tmp[i]=frac[j];
                                j=j+1;
                            end
                            tmp[i]=1;
                            y=-(tmp+1);
                        end
                    end
                end
            end

            else if(rm==3'b011) begin//Round Up (towards +∞)
                if(width>=23) begin
                    tmp=0;
                    tmp=frac<<(width-23);
                    tmp[width]=1;
                    y=(a[31]?-tmp:tmp);
                end
                else begin
                    if(!a[31]) begin
                        //正数多余位全为0直接截尾
                        if((frac<<width) == 0) begin
                        // y=frac>>(23-width)+32'b1<<width;
                            j=23-width;
                            y=0;
                            for(i=0;i<width && i<32;i=i+1) begin
                                y[i]=frac[j];
                                j=j+1;
                            end
                            y[i]=1;
                        end
                        //正数多余位不全为0进位1
                        else begin
                        // y=frac>>(23-width)+32'b1<<width+32'd1;
                            j=23-width;
                            y=0;
                            for(i=0;i<width && i<32;i=i+1) begin
                                y[i]=frac[j];
                                j=j+1;
                            end
                            y[i]=1;
                        end
                    end
                    else begin//负数直接截尾
                        // y=-(frac>>(23-width)+32'b1<<width);
                        j=23-width;
                        tmp=0;
                        for(i=0;i<width && i<32;i=i+1) begin
                            tmp[i]=frac[j];
                            j=j+1;
                        end
                        tmp[i]=1;
                        y=-tmp;
                    end
                end
            end

            else begin
                tmp=0;
                y=0;//随便
            end
        end
        4'b1110: begin//fcvt.s.w
        // 把寄存器 x[rs1]中的 32 位二进制补码表示的整数转化为单精度浮点数，再写入 f[rd]中
            y =32'd0;
            tmp=0;
            tmp1=0;
            tmp2=0;
            if (a == 32'b0) begin // 特殊情况：输入为零
                y = 32'h00000000;
            end 
            else begin
                // 提取符号位
                y[31] = a[31];
                
                // 指数部分
                tmp =$signed(a);
                if (tmp[31]) tmp1 = -tmp; // 取绝对值
                else tmp1=tmp;
                j=0;
                for(i=0;i<32;i=i+1) begin//为1的最高位exp
                    if(tmp1[i] && i>j) j=i;
                end
                exp=j;
                y[30:23] = exp + 23'd127;
                
                // 尾数部分
                if(rm==3'b000 || rm==3'b111) begin//Round to Nearest, ties to Even ,rne
                    if(j<=23||tmp1[j-23]==0) begin//直接舍去
                        for (i = 22; i >= 0; i = i - 1) 
                            if((j+i-23)>=0) y[i] = tmp1[j+i-23];
                            else y[i]=0;
                    end
                    else if(tmp1<<(31-exp+23+1)==0) begin//0.5
                        if(tmp1[j-22]) begin//奇数
                            for (i = 22; i >= 0; i = i - 1)
                                tmp2[i] = tmp1[j+i-23];
                            tmp2[31:23]=0;
                            y[22:0]=tmp2+1;//进一
                        end
                        else begin//偶数
                            for (i = 22; i >= 0; i = i - 1)
                                y[i] = tmp1[j+i-23];//直接舍去
                        end
                    end
                    else begin//进一
                        for (i = 22; i >= 0; i = i - 1)
                            tmp2[i] = tmp1[j+i-23];
                        tmp2[31:23]=0;
                        y[22:0]=tmp2+1;
                    end
                end
                else if(rm==3'b001) begin//Round towards Zero
                    for (i = 22; i >= 0; i = i - 1)
                        if(j+i-23>=0) y[i] = tmp1[j+i-23];//直接舍去
                        else y[i]=0;
                end 
                else if(rm==3'b010) begin//Round Down (towards −∞)
                    //正数直接截尾//负数多余位全为0直接截尾
                    if(a>0 || (a<0 && tmp1<<(32-exp)==0)) begin
                        for (i = 22; i >= 0; i = i - 1)
                            if(j+i-23>=0) y[i] = tmp1[j+i-23];
                            else y[i]=0;
                    end
                    else begin//负数多余位不全为0进位1
                        for (i = 22; i >= 0; i = i - 1)
                            if(j+i-23>=0) tmp2[i] = tmp1[j+i-23];
                            else tmp2[i]=0;
                        tmp2[31:23]=0;
                        y[22:0]=tmp2+1;
                    end
                end
                else if(rm==3'b011) begin//Round Up (towards +∞)
                    //负数直接截尾//正数多余位全为0直接截尾
                    if(a<0 || (a<0 && tmp1<<(32-exp)==0)) begin
                        for (i = 22; i >= 0; i = i - 1)
                            y[i] = tmp1[j+i-23];
                    end
                    else begin//正数多余位不全为0进位1
                        for (i = 22; i >= 0; i = i - 1)
                            if(j+i-23>=0) tmp2[i] = tmp1[j+i-23];
                            else tmp2[i]=0;
                        tmp2[31:23]=0;
                        y[22:0]=tmp2+1;
                    end
                end
            end
        end
        default :begin
            y=32'b0;
            exp=0;
            tmp=0;
        end

    endcase
end

endmodule
