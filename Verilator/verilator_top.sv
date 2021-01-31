`ifdef VERILATOR
`include "Config.sv"
`include "Types.sv"
`endif


module top
    import Types::*;
(
    input  logic i_clock,  // Clock
    input  logic i_reset); // Reset

    int tickCount;

    InstAddr addr;
    Inst     inst;
    logic    read;
    logic    busy;
    logic    hit;


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
        .i_addr     (addr),
        .i_rd       (read),
        .o_inst     (inst),
        .o_busy     (busy),
        .o_hit      (hit),
        .o_mem_addr (imem_addr),
        .i_mem_data (imem_data));


    initial begin
        tickCount = 0;
        read = 1'b0;
    end

    always_comb begin
        if (tickCount > 500)
            $finish;

        read = 1'b0;
        addr = InstAddr'(0);

        if (tickCount == 40) begin
            addr = InstAddr'(12'h010);
            read = 1'b1;
        end

        if (tickCount == 50) begin
            addr = InstAddr'(12'h010);
            read = 1'b1;
        end

        if (tickCount == 60) begin
            addr = InstAddr'(12'h012);
            read = 1'b1;
        end

        if (tickCount == 70) begin
            addr = InstAddr'(12'h017);
            read = 1'b1;
        end

        if (tickCount == 80) begin
            addr = InstAddr'(12'h011);
            read = 1'b1;
        end

        if (tickCount == 90) begin
            addr = InstAddr'(12'hF11);
            read = 1'b1;
        end

        if (tickCount == 100) begin
            addr = InstAddr'(12'h011);
            read = 1'b1;
        end

        if (tickCount == 110) begin
            addr = InstAddr'(12'hF10);
            read = 1'b1;
        end
    end

    always_ff @(posedge i_clock)
        if (i_reset)
            tickCount <= 0;
        else
            tickCount <= tickCount + 1;

endmodule
