`timescale 1ns / 1ps

module Encoder(
input jal,
input jalr,
input br,
output reg [1:0] pc_sel
);
always @(*) begin
    if(br) pc_sel=2'b10;
    else if(jal) pc_sel=2'b11;
    else if(jalr) pc_sel=2'b01;
    else pc_sel=2'b00;
end
initial begin
    pc_sel=2'b00;
end
endmodule
