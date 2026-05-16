module alu(
input [2:0] func3,
input [6:0] func7,
//num1来自PC或rs1，num2来自rs2或立即数。
//对于R-type，I-type和AUIPC的运算，将结果直接填入result。
input [31:0] num1, num2,
output reg [31:0] result,
//对于B-type的比较，将结果填入zero
output reg zero
);

// R-type & I-type ALU 运算
always @(*) begin
    case (func3)
        3'b000: begin  // ADD/ADDI/SUB
            if (func7[5])  // func7[5]=1 且 R-type 时为 SUB
                result = num1 - num2;
            else
                result = num1 + num2;
        end
        3'b001: begin  // SLL/SLLI
            result = num1 << num2[4:0];
        end
        3'b010: begin  // SLT/SLTI (有符号比较)
            result = ($signed(num1) < $signed(num2)) ? 32'b1 : 32'b0;
        end
        3'b011: begin  // SLTU/SLTIU (无符号比较)
            result = (num1 < num2) ? 32'b1 : 32'b0;
        end
        3'b100: begin  // XOR/XORI
            result = num1 ^ num2;
        end
        3'b101: begin  // SRL/SRLI / SRA/SRAI
            if (func7[5])  // func7[5]=1 时为 SRA/SRAI (算术右移)
                result = $signed(num1) >>> num2[4:0];
            else
                result = num1 >> num2[4:0];
        end
        3'b110: begin  // OR/ORI
            result = num1 | num2;
        end
        3'b111: begin  // AND/ANDI
            result = num1 & num2;
        end
        default: begin
            result = 32'b0;
        end
    endcase
end

// B-type 分支条件比较
always @(*) begin
    case (func3)
        3'b000: zero = (num1 == num2) ? 1'b1 : 1'b0;  // BEQ
        3'b001: zero = (num1 != num2) ? 1'b1 : 1'b0;  // BNE
        3'b100: zero = ($signed(num1) < $signed(num2)) ? 1'b1 : 1'b0;  // BLT
        3'b101: zero = ($signed(num1) >= $signed(num2)) ? 1'b1 : 1'b0;  // BGE
        3'b110: zero = (num1 < num2) ? 1'b1 : 1'b0;  // BLTU
        3'b111: zero = (num1 >= num2) ? 1'b1 : 1'b0;  // BGEU
        default: zero = 1'b0;
    endcase
end

endmodule