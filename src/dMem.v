module dMem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 14,
    parameter INIT_FILE  = "memdata.hex"
)(
    input clka,
    input wea,
    input [ADDR_WIDTH-1:0] addra,
    input [DATA_WIDTH-1:0] dina,
    output reg [DATA_WIDTH-1:0] douta
);

    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    integer i;
    initial begin
        for (i = 0; i < 1<<ADDR_WIDTH; i = i + 1)
            mem[i] = {DATA_WIDTH{1'b0}};    
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    always @(posedge clka) begin
        if (wea) begin
            mem[addra]<=dina;
            douta<=dina;
        end else begin
            douta<= mem[addra];
        end
    end

endmodule