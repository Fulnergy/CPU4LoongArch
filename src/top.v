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
wire branch, aluSrc, memRead, memWrite, memToReg;
iFetch uifetch(

);

reg [1:0] aluOp;
decoder udecoder(

);

dmem #() udmem(

);



endmodule