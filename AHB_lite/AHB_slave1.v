// we chose AHB slave 1 to be a memory slave 
module AHB_Slave_1 #(
    parameter MEM_WIDTH = 8 , parameter MEM_DEPTH = 1024 // I chose 128 bits for the width as 128 = 32*4 to enable transfers of 8 bits size 
) (
    // Global Signals
    input HCLK,
    input HRESETn,
    // input from master
    input [31:0] HADDR,
    input [31:0] HWDATA,
    // input from decoder
    input HSELx_slaves,
    // control signals
    input HWRITE,
    input [2:0] HSIZE,
    input [1:0] HTRANS,
    input [2:0] HBURST,
    input HREADY,
    // output to MUX
    output reg HREADYOUT,
    output reg HRESP,
    output reg [31:0] HRDATA // Read data to master
);
    // we made this salve as a memory to test read and write operations
    reg [MEM_WIDTH-1:0] memory [MEM_DEPTH-1:0]; // Memory array

    // internal signlas
    wire [31:0] HADDR_Half; // address that incerements the HADDR by 1 to write 16 bits
    wire [31:0] HADDR_Full_1; // address that incerements the HADDR by 1 to write 32 bits
    wire [31:0] HADDR_Full_2; // address that incerements the HADDR by 2 to write 32 bits
    wire [31:0] HADDR_Full_3; // address that incerements the HADDR by 3 to write 32 bits

    assign HADDR_Half = HADDR[29:0] + 1; // Half address for 16 bits transfer
    assign HADDR_Full_1 = HADDR[29:0] + 1; // Full address for 32 bits transfer
    assign HADDR_Full_2 = HADDR[29:0] + 2; // Full address for 32 bits transfer
    assign HADDR_Full_3 = HADDR[29:0] + 3; // Full address for 32 bits transfer

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HREADYOUT <= 1'b1; // Initially ready
            HRESP <= 1'b0; // No error response
            HRDATA <= 32'h00000000; // Default read data
        end else if (!HSELx_slaves) begin // select Slave 1 if HSELx is 2'b00
            // Write operation for both single and incermental burst transfers (HBURST = 1)
            if (HWRITE && (HTRANS == 2'b10 || HTRANS == 2'b11)) begin // as the state is NONSEQ or SEQ we can write
                // 8 bits transfer 
                if ((HBURST == 3'b000 || HBURST == 3'b001) && HSIZE == 3'b000) begin 
                    memory[HADDR[29:0]] <= HWDATA[7:0]; // Write 8 bits to memory
                end 
                // 16 bits transfer 
                else if ((HBURST == 3'b000 || HBURST == 3'b001) && HSIZE == 3'b001) begin // 16 bits transfer
                    memory[HADDR[29:0]] <= HWDATA[7:0]; // Write 8 bits to memory
                    memory[HADDR_Half] <= HWDATA[15:8]; // Write next 8 bits to memory
                end 
                // 32 bits transfer 
                else if ((HBURST == 3'b000 || HBURST == 3'b001) && HSIZE == 3'b010) begin // 32 bits transfer
                    memory[HADDR[29:0]] <= HWDATA[7:0]; // Write first 8 bits to memory
                    memory[HADDR_Full_1] <= HWDATA[15:8]; // Write next 8 bits to memory
                    memory[HADDR_Full_2] <= HWDATA[23:16]; // Write next 8 bits to memory
                    memory[HADDR_Full_3] <= HWDATA[31:24]; // Write last 8 bits to memory
                end
            // Read operation for both single and incermental burst transfers (HBURST = 1)
            end else if (!HWRITE && (HTRANS == 2'b10 || HTRANS == 2'b11)) begin // as the state is NONSEQ or SEQ we can read
                // 8 bits transfer 
                if ((HBURST == 3'b000 || HBURST == 3'b001) && HSIZE == 3'b000) begin 
                    HRDATA <= {24'h000000, memory[HADDR[29:0]]}; // Read 8 bits from memory
                end 
                // 16 bits transfer 
                else if ((HBURST == 3'b000 || HBURST == 3'b001) && HSIZE == 3'b001) begin // 16 bits transfer
                    HRDATA <= {16'h0000, memory[HADDR_Half], memory[HADDR[29:0]]}; // Read 16 bits from memory
                end 
                // 32 bits transfer 
                else if ((HBURST == 3'b000 || HBURST == 3'b001) && HSIZE == 3'b010)  begin // 32 bits transfer
                    HRDATA <= {memory[HADDR_Full_3], memory[HADDR_Full_2], memory[HADDR_Full_1], memory[HADDR[29:0]]}; // Read 32 bits from memory
                end
            end
        end
    end
endmodule