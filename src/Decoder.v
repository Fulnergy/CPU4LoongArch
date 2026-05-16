//用于从输入的指令中提取出各种信号
module decoder(
input [31:0] inst,
//所有操作使用同一个立即数，提取时若不满32位，则有符号扩展至32位。
output reg [31:0] imm,
//计算部分：
output reg [2:0] func3,
output reg [6:0] func7,
output reg [4:0] rs1,rs2,rd,
//alu该运算寄存器还是立即数？若aluOp为1，则运算寄存器，否则运算立即数
output reg aluOp,
//这条指令要将PC加上立即数吗？若auipc为1，则num1取PC，否则取rs1的值
output reg auipc,
//alu中怎么处理立即数？若lui为1，则直接采取立即数作为输出，否则进行二元运算。
output reg lui,
//该指令是否从内存读取数据？若memRead为1，则writeData取dout，否则取其他。
output reg memRead,
//该指令是否写回PC+4？若jal为1，则writeData取pc+4，否则取其他。
output reg jal,
//存取部分：
output reg regWrite,
output reg memWrite,
//控制部分：    (为1则跳转)
output reg branch
    );

parameter RTYPE  = 7'b0110011;
parameter ITYPE_ALU  = 7'b0010011;
parameter ITYPE_LOAD   = 7'b0000011;
parameter ITYPE_JALR   = 7'b1100111;
parameter STYPE  = 7'b0100011;
parameter BTYPE  = 7'b1100011;
parameter UTYPE_LUI   = 7'b0110111;
parameter UTYPE_AUIPC = 7'b0010111;
parameter JTYPE  = 7'b1101111;

wire [6:0] opc = inst[6:0];

assign func3 = inst[14:12];
assign func7 = inst[31:25];
assign rs1 = inst[19:15];
assign rs2 = inst[24:20];
assign rd = inst[11:7];
assign aluOp = opc == RTYPE ||
               opc == BTYPE ? 1 : 0;
assign auipc = opc == UTYPE_AUIPC ? 1 : 0;
assign lui = opc == UTYPE_LUI ? 1 : 0;
assign memRead = opc == ITYPE_LOAD ? 1 : 0;
assign jal = (opc == JTYPE || opc == ITYPE_JALR) ? 1 : 0;

assign regWrite = opc == RTYPE ||
                  opc == ITYPE_ALU ||
                  opc == ITYPE_LOAD ||
                  opc == ITYPE_JALR ||
                  opc == UTYPE_LUI ||
                  opc == UTYPE_AUIPC ||
                  opc == JTYPE ? 1 : 0;

assign memWrite = opc == STYPE ? 1 : 0;

assign branch = opc == BTYPE ||
                opc == ITYPE_JALR ||
                opc == JTYPE ? 1 : 0;

always @(*) begin
    case (opc)
        RTYPE: begin
            imm = 32'b0;
        end
        ITYPE_ALU, ITYPE_LOAD, ITYPE_JALR: begin
            // I-type: imm[31:0] = {{21{inst[31]}}, inst[30:20]}
            imm = { {21{inst[31]}}, inst[30:20] };
        end
        STYPE: begin
            // S-type: imm[31:0] = {{21{inst[31]}}, inst[30:25], inst[11:7]}
            imm = { {21{inst[31]}}, inst[30:25], inst[11:7] };
        end
        BTYPE: begin
            // B-type: imm[31:0] = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}
            imm = { {20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0 };
        end
        UTYPE_LUI, UTYPE_AUIPC: begin
            // U-type: imm[31:0] = {inst[31:12], 12'b0}
            imm = { inst[31:12], 12'b0 };
        end
        JTYPE: begin
            // J-type: imm[31:0] = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0}
            imm = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0 };
        end
        default: begin
            imm = 32'b0;
        end
    endcase
end

endmodule

