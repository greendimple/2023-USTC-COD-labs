`timescale 1ns / 1ps
// f[31] = sign
// f[30:23] = exp
// f[22:0] = frac 
module fRF
#(  parameter WIDTH = 32 ,
    parameter DEPTH = 5) //数据宽度和存储器深度
(
input clk, //时钟（上升沿有效）
input[DEPTH-1 : 0] ra0, //读端口0地址
output[WIDTH - 1 : 0] rd0, //读端口0数据
input[DEPTH-1: 0] ra1, //读端口1地址
output[WIDTH - 1 : 0] rd1, //读端口1数据
input[DEPTH-1 : 0] wa, //写端口地址
input we, //写使能，高电平有效
input[WIDTH - 1 : 0] wd //写端口数据
// input[DEPTH-1 : 0] ra_dbg, //读端口2地址, 用于PDU从外部读取寄存器的值
// output[WIDTH - 1 : 0] rd_dbg //读端口2数据
);
reg [WIDTH - 1 : 0] regfile[0 : 31];

assign rd0 = ((we && (wa==ra0)) ? wd : regfile[ra0]), 
       rd1 = ((we && (wa==ra1)) ? wd : regfile[ra1]);
// assign rd_dbg = regfile[ra_dbg];

always @ (posedge clk) begin
    if (we ) regfile[wa] <= wd;//f0可被写入
end

integer i;
initial begin
i = 0;
while (i < 32) begin
regfile[i] = 32'b0;
i = i + 1;
end
end
endmodule
