module alu(
input clk,
input [2:0] func3,
input [6:0] func7,
//num1对应rs1,num2由外部处理，来自rs2或立即数。
input [31:0] num1, num2,
output reg [31:0] result
);

endmodule