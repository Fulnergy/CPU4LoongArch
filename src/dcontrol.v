module dcontrol(
    input clk,
    input writeEn,//若向dmem存入，则为1，否则为0
    input [2:0] func3,
    input [31:0] imm,//此处立即数作为基址+偏移，即字节地址
    input [31:0] din,
    output [31:0] dout
);

wire [31:0] mem_dout;
wire [13:0] word_addr = imm[15:2];
wire [3:0] byteWe;

// 根据func3和字节偏移生成字节写使能信号
assign byteWe = (writeEn) ?
    (func3 == 3'b010) ? 4'b1111 :                          // SW: 写全部4字节
    (func3 == 3'b001) ? (imm[1] ? 4'b1100 : 4'b0011) :     // SH: 写高2字节或低2字节
    (func3 == 3'b000) ? (imm[1:0] == 2'b00 ? 4'b0001 :
                         imm[1:0] == 2'b01 ? 4'b0010 :
                         imm[1:0] == 2'b10 ? 4'b0100 :
                         imm[1:0] == 2'b11 ? 4'b1000 : 4'b0000) : // SB: 写单个字节
    4'b0000 : 4'b0000;  // 不写入

wire [31:0] din_byte;  // 将要写入的字节放到正确的位置
assign din_byte = (func3 == 3'b000) ?
    (imm[1:0] == 2'b00 ? {24'b0, din[7:0]} :
     imm[1:0] == 2'b01 ? {16'b0, din[7:0], 8'b0} :
     imm[1:0] == 2'b10 ? {8'b0, din[7:0], 16'b0} :
                         {din[7:0], 24'b0}) :
    (func3 == 3'b001) ?
    (imm[1] ? {din[15:0], 16'b0} : {16'b0, din[15:0]}) :
    din;  // SW

dmem #(.DATA_WIDTH(32), .ADDR_WIDTH(14), .INIT_FILE("memdata.hex")) udmem(
    .clk(clk),
    .writeEn(|byteWe),  // 任一字节使能即写入
    .byteWe(byteWe),
    .addr(word_addr),
    .din(din_byte),
    .dout(mem_dout)
);

// Load: 根据func3对读出的数据进行截断和扩展
reg [31:0] dout_reg;
assign dout = dout_reg;

always @(*) begin
    case (func3)
        3'b000: begin  // LB: 加载字节，有符号扩展
            case (imm[1:0])
                2'b00: dout_reg = {{24{mem_dout[7]}},  mem_dout[7:0]};
                2'b01: dout_reg = {{24{mem_dout[15]}}, mem_dout[15:8]};
                2'b10: dout_reg = {{24{mem_dout[23]}}, mem_dout[23:16]};
                2'b11: dout_reg = {{24{mem_dout[31]}}, mem_dout[31:24]};
                default: dout_reg = mem_dout;
            endcase
        end
        3'b001: begin  // LH: 加载半字，有符号扩展
            case (imm[1])
                1'b0: dout_reg = {{16{mem_dout[15]}}, mem_dout[15:0]};
                1'b1: dout_reg = {{16{mem_dout[31]}}, mem_dout[31:16]};
                default: dout_reg = mem_dout;
            endcase
        end
        3'b010: begin  // LW: 加载字
            dout_reg = mem_dout;
        end
        3'b100: begin  // LBU: 加载字节，无符号扩展
            case (imm[1:0])
                2'b00: dout_reg = {24'b0, mem_dout[7:0]};
                2'b01: dout_reg = {24'b0, mem_dout[15:8]};
                2'b10: dout_reg = {24'b0, mem_dout[23:16]};
                2'b11: dout_reg = {24'b0, mem_dout[31:24]};
                default: dout_reg = mem_dout;
            endcase
        end
        3'b101: begin  // LHU: 加载半字，无符号扩展
            case (imm[1])
                1'b0: dout_reg = {16'b0, mem_dout[15:0]};
                1'b1: dout_reg = {16'b0, mem_dout[31:16]};
                default: dout_reg = mem_dout;
            endcase
        end
        default: begin
            dout_reg = mem_dout;
        end
    endcase
end
endmodule