// this module will connect the AHB Master and Slaves modules
module AHB_TOP (
    // Global Signals
    input HCLK,
    input HRESETn,
    // Processor signals (we will act as the Processor in the testbench)
    input [31:0] PADDR,
    input [31:0] PWDATA,
    input PWRITE,
    input [2:0] PSIZE,
    input [1:0] PTRANS,
    input [2:0] PBURST
);
    // internal connections between master and slaves
    // from Master to slaves
    wire [31:0] HADDR;
    wire [31:0] HWDATA;
    wire HWRITE;
    wire [2:0] HSIZE;
    wire [1:0] HTRANS;
    wire [2:0] HBURST;
    wire HREADY;
    wire HRESP;
    
    // from Slave to Master
    wire HREADYOUT;

    // from Decoder 
    wire HSELx_slaves; // Slave select signal
    wire HSELx_Mux; // Slave select signal for MUX

    // from Slaves to Master
    wire [31:0] HRDATA;

    // instantiate the AHB Master
    AHB_Master master (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PSIZE(PSIZE),
        .PTRANS(PTRANS),
        .PBURST(PBURST),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HWRITE(HWRITE),
        .HSIZE(HSIZE),
        .HTRANS(HTRANS),
        .HBURST(HBURST),
        .HREADY(HREADY),
        .HRESP(HRESP),
        .HRDATA(HRDATA)
        );

    // instantaite the decoder to select the slave based on the most signficant two bits of the address
    AHB_Decoder decoder (
        .HADDR(HADDR),
        .HSELx_slaves(HSELx_slaves),
        .HSELx_Mux(HSELx_Mux)
    );

    // instantiate the AHB Slave 1
    AHB_Slave_1 slave1 (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HSELx_slaves(HSELx_slaves),
        .HWRITE(HWRITE),
        .HSIZE(HSIZE),
        .HTRANS(HTRANS),
        .HBURST(HBURST),
        .HREADY(HREADY),
        .HREADYOUT(HREADYOUT),
        .HRESP(HRESP),
        .HRDATA(HRDATA)
    );

    // instantiate the Multiplexer
    AHB_MUX mux (
        .HRESP_Slave_1(HRESP),
        .HREADYOUT_1(HREADYOUT),
        .HRDATA_Slave_1(HRDATA),
        .HSELx_Mux(HSELx_Mux),
        .HREADY(HREADY),
        .HRESP(HRESP)
    );
        

endmodule