module iMem #(
    parameter DATA_WIDTH = 32, // Memory bit width
    parameter ADDR_WIDTH = 14, // Memory depth = 2^ADDR_WIDTH
    parameter INIT_FILE  = "memdata.hex"  // Relative path to hex file, empty if all zeros
)(
    input clk,
    input [ADDR_WIDTH-1:0] addr,
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

    assign dout = mem[addr];

endmodule