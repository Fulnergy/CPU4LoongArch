module dMem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 14,
    parameter INIT_FILE  = "memdata.hex"
)(
    input clk,
    input writeEn,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    integer i;
    initial begin
        for (i = 0; i < 1<<ADDR_WIDTH; i = i + 1)
            mem[i] = {DATA_WIDTH{1'b0}};    
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    always @(posedge clk) begin
        if (writeEn) begin
            mem[addr]<=din;
            dout<=din;
        end else begin
            dout<= mem[addr];
        end
    end

endmodule