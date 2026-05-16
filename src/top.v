module top(
    input clk_fast,//最快的钟，来自硬件的100Mhz时钟
    input rst,//复位信号，低电平有效
    input en //使能信号，高电平有效
);

reg clk_slow;
reg [1:0] clk_cnt;
always @(posedge clk) begin
    if(~rst) clk_slow<=1'b0;
    else if(clk_cnt==2'd3)begin
        clk_cnt<=2'd0;
        clk_slow<=~clk_slow;
    end
    else begin
        clk_cnt<=clk_cnt+1;
    end
end

reg [31:0] imm; //指令中提取出的立即数
reg [31:0] inst;
reg [31:0] writeData; //向寄存器存入的数
wire branch, memWrite;
wire zero;
wire [2:0] func3;
wire [6:0] func7;
wire [4:0] rs1, rs2, rd;
wire aluOp, auipc, lui, memRead, jal, regWrite;
wire [31:0] num1, num2, result;
wire [31:0] readData1, readData2;
wire [31:0] pc;
wire [31:0] dout;

assign num1 = auipc ? pc : readData1;
assign num2 = aluOp ? readData2 : imm;

decoder udecoder(
    .inst(inst),
    .imm(imm),
    .func3(func3),
    .func7(func7),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .aluOp(aluOp),
    .auipc(auipc),
    .lui(lui),
    .memRead(memRead),
    .jal(jal),
    .regWrite(regWrite),
    .memWrite(memWrite),
    .branch(branch)
);

iFetch uifetch(
    .clk(clk_slow),
    .rst(rst),
    .branch(branch),
    .imm(imm),
    .zero(zero),
    .inst(inst),
    .pc(pc)
);

alu ualu(
    .func3(func3),
    .func7(func7),
    .lui(lui),
    .num1(num1),
    .num2(num2),
    .result(result),
    .zero(zero)
);

always @(*) begin
    if(lui) begin
        writeData = imm;
    end
    else if(memRead) begin
        writeData = dout;
    end
    else if(jal) begin
        writeData = pc + 4;
    end
    else begin
        writeData = result;
    end
end

regs uregister(
    .clk(clk),
    .writeReg(regWrite),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .writeData(writeData),
    .readData1(readData1),
    .readData2(readData2)
);

dcontrol udcontrol(
    .clk(clk),
    .writeEn(memWrite),
    .func3(func3),
    .imm(imm),
    .din(readData2),
    .dout(dout)
);


endmodule