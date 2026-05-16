module top(
    input clk,//最快的钟，控制最底层每一步的前进
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
wire branch, memRead, memWrite;
wire zero;
wire [2:0] func3;
wire [6:0] func7;
wire [4:0] rs1, rs2, rd;
wire aluOp, auipc, regWrite;
wire [31:0] num1, num2, result;
wire [31:0] readData1, readData2, writeData;

wire [31:0] pc;

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
    .regWrite(regWrite),
    .memWrite(memWrite),
    .branch(branch)
);

iFetch uifetch(
    .clk(clk),
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
    .num1(num1),
    .num2(num2),
    .result(result),
    .zero(zero)
);

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

dmem #() udmem(

);


endmodule