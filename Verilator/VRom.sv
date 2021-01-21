module VRom
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32)
(
    input  logic [ADDR_WIDTH-1:0] i_addr,
    output logic [DATA_WIDTH-1:0] o_data);

    assign o_data = {20'hABCD0, i_addr[11:0]};

endmodule