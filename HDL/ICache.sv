module ICache
    import Types::*;
#(
    parameter CACHE_BLOCKS   = 4,
    parameter CACHE_ELEMENTS = 128)
(
    input logic    i_clock,
    input logic    i_reset,

    input InstAddr i_addr,
    input logic    i_rd,
    output Inst    o_inst,
    output logic   o_busy);

    typedef enum logic [1:0] {
        State_INIT,
        State_IDLE,
        State_READ,
        State_CACHE
    } State;


    InstAddr     addr;
    Inst         inst;
    logic        cl;
    logic        wr;
    logic [11:0] count, nextCount;  // Contador per inicialitzacio
    State        state, nextState;  // Estat intern
    logic        hit;


    // -------------------------------------------------------------------
    // Set 0
    // -------------------------------------------------------------------

    logic cacheSet0_hit;
    Inst  cacheSet0_inst;

    ICacheSet #(
        .CACHE_BLOCKS   (CACHE_BLOCKS),
        .CACHE_ELEMENTS (CACHE_ELEMENTS))
    cacheSet0 (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .i_addr  (addr),
        .i_wr    (0),
        .i_cl    (cl),
        .i_inst  (0),
        .o_inst  (cacheSet0_inst),
        .o_hit   (cacheSet0_hit));


    // -------------------------------------------------------------------
    // Set 1
    // -------------------------------------------------------------------

    logic cacheSet1_hit;
    Inst  cacheSet1_inst;

    ICacheSet #(
        .CACHE_BLOCKS   (CACHE_BLOCKS),
        .CACHE_ELEMENTS (CACHE_ELEMENTS))
    cacheSet1 (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .i_addr  (addr),
        .i_wr    (0),
        .i_cl    (cl),
        .i_inst  (0),
        .o_inst  (cacheSet1_inst),
        .o_hit   (cacheSet1_hit));


    // -------------------------------------------------------------------
    // Obte la instruccio del cache, si existeix
    // -------------------------------------------------------------------

    always_comb
        unique casez ({cacheSet1_hit, cacheSet0_hit})
            2'b00: begin
                hit = 1'b0;
                inst = Inst'(0);
            end

            2'b1?: begin
                hit = 1'b1;
                inst = cacheSet1_inst;
            end

            2'b01: begin
                hit = 1'b1;
                inst = cacheSet0_inst;
            end
        endcase


    // -------------------------------------------------------------------
    // FSM de control de les operacions del cache
    // -------------------------------------------------------------------

    // Evalua el nou estat
    //
    always_comb begin
        o_busy = 1'b1;
        cl = 1'b0;
        wr = 1'b0;
        addr = i_addr;
        nextCount = 0;
        unique case (state)
            State_INIT:
                begin
                    cl = 1'b1;
                    addr = InstAddr'({count, 2'b00});
                    nextCount = count + 1;
                    nextState = (count == (CACHE_ELEMENTS)) ? State_IDLE : state;
                end

            State_IDLE:
                if (hit) begin
                    o_inst = inst;
                    o_busy = 1'b1;
                    nextState = state;
                end
                else
                    nextState = State_READ;

            State_READ:
                nextState = State_IDLE;

            State_CACHE:
                nextState = State_IDLE;

            default:
                nextState = state;
        endcase
    end

    // Actualitzacio del contador
    //
    always_ff @(posedge i_clock)
        if (~i_reset & (state == State_INIT))
            count <= nextCount;

    // Actualitzacio del estat
    //
    always_ff @(posedge i_clock)
        if (i_reset)
            state <= State_INIT;
        else
            state <= nextState;


endmodule
