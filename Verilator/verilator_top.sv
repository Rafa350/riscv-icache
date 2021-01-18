`ifdef VERILATOR
`include "Types.sv"
`endif


module top
    import Types::*;
(
    input  logic i_clock,  // Clock
    input  logic i_reset,  // Reset

    input  [31:0] i_addr,
    output [31:0] o_inst);

    logic    read = 1'b1;
    logic    busy;

    ICache
    icache (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .i_addr  (i_addr[11:0]),
        .i_rd    (read),
        .o_inst  (o_inst),
        .o_busy  (busy));

endmodule
