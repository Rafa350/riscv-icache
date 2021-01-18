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


    InstAddr imem_addr;
    Inst     imem_data;

    // Memoria d'intruccions
    VRom #(
        .DATA_WIDTH ($size(Inst)),
        .ADDR_WIDTH ($size(InstAddr)))
    imem (
        .i_addr (imem_addr),
        .o_data (imem_data));


    // Cache d'instruccions
    //
    ICache
    icache (
        .i_clock    (i_clock),
        .i_reset    (i_reset),
        .i_addr     (i_addr[11:0]),
        .i_rd       (read),
        .o_inst     (o_inst),
        .o_busy     (busy),
        .o_mem_addr (imem_addr),
        .i_mem_data (imem_data));

endmodule
