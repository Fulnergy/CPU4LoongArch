module alu(
input [2:0] func3,
input [6:0] func7,
//num1对应rs1读出的数，num2由外部处理，来自rs2或立即数。
//对于R-type，I-type和AUIPC的运算，将结果直接填入result。
//对于LUI，立即数会处在num2中，需特别处理。
input [31:0] num1, num2,
output reg [31:0] result,
//对于B-type的比较，将结果填入zero
output reg zero
);

endmodule