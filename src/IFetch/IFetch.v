`include "..." 
module IFetch(
input clk, rst, branch, zero,
input [31:0] imm,
output [31:0] inst
    );
    reg [31:0] pc;
    imem #(.DATA_WIDTH(32),.ADDR_WIDTH(14),.INIT_FILE("ifetch_test.txt")) uimem(.clk(clk),.addr(pc[15:2]),.dout(inst));
    
    always@(negedge clk, posedge rst) begin
        if(rst)
            pc<= 32'h0;
        else if(branch&&zero)
            pc<= pc + (imm<<1);   
        else
           pc<= pc + 4;    
    end
endmodule