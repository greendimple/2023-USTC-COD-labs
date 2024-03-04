`timescale 1ns / 1ps

module dm_dout_wb_sel(
input lb_wb,
input lw_wb,
input lh_wb,
input lbu_wb,
input lhu_wb,
input [31:0] dm_dout_wb,
output reg [31:0] dm_dout_wb_load
);

always @(*) begin
    case({lw_wb,lh_wb,lb_wb,lbu_wb,lhu_wb})
        5'b10000:dm_dout_wb_load=dm_dout_wb;
        5'b01000:begin
            if(dm_dout_wb[15]) dm_dout_wb_load={16'hFFFF,dm_dout_wb[15:0]};
            else dm_dout_wb_load={16'b0,dm_dout_wb[15:0]};
        end
        5'b00100:begin
            if(dm_dout_wb[7]) dm_dout_wb_load={28'hFFFFFFF,dm_dout_wb[7:0]};
            else dm_dout_wb_load={28'b0,dm_dout_wb[7:0]};
        end
        5'b00010: dm_dout_wb_load={28'b0,dm_dout_wb[7:0]};
        5'b00001: dm_dout_wb_load={16'b0,dm_dout_wb[15:0]};
        default: dm_dout_wb_load=dm_dout_wb;
    endcase
end
endmodule
