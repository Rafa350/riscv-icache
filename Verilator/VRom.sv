module VRom
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32)
(
    input  logic [ADDR_WIDTH-1:0] i_addr,
    output logic [DATA_WIDTH-1:0] o_data);

    // verilator lint_off WIDTH
    assign o_data = ~i_addr;
    // verilator lint_on WIDTH

endmodule