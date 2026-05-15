module regs (
    input clk,
    input writeReg,
    input [4:0] rs1,              
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] writeData,
    output [31:0] readData1,
    output [31:0] readData2
);


    reg [31:0] regs [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
               regs[i]=32'b0;
    end

    assign readData1=regs[rs1];
    assign readData2=regs[rs2];


    always @(posedge clk ) begin
        if(writeReg)begin
            if(rd)regs[rd]<=writeData;
        end
    end
    
endmodule