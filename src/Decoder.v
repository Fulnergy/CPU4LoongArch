//用于从输入的指令中提取出各种信号
module decoder(
input [31:0] inst,
output reg branch, //若下一个pc跳到其它地址，则为高电平
output reg aluSrc, memRead, memWrite, memToReg, regWrite,
output reg [1:0] ALUOp
    );

wire [6:0] opc = inst[6:0];

assign branch = opc == 7'b1100011;
assign aluSrc = (opc == 7'b0000011) ||
                (opc == 7'b0010011) ||
                (opc == 7'b0100011) ||
                (opc == 7'b1100111) ||
                (opc == 7'b0010111) ||
                (opc == 7'b0110111); 
assign memRead = opc == 7'b0000011;
assign memWrite = opc == 7'b0100011;
assign memToReg = (opc == 7'b0000011);
assign regWrite = (opc == 7'b0110011) ||
                  (opc == 7'b0000011) ||
                  (opc == 7'b0010011) ||
                  (opc == 7'b1101111) ||
                  (opc == 7'b1100111) ||
                  (opc == 7'b0110111) ||
                  (opc == 7'b0010111);

always @* begin
if(opc==7'b0110011) ALUOp = 2;
else if(opc==7'b1100011) ALUOp = 1;
else ALUOp = 0;
end

endmodule
