module ICache
    import Types::*;
#(
    parameter CACHE_BLOCKS   = 4,
    parameter CACHE_ELEMENTS = 32)
(
    input  logic    i_clock,
    input  logic    i_reset,

    input  InstAddr i_addr,
    input  logic    i_rd,
    output Inst     o_inst,
    output logic    o_busy,

    output InstAddr o_mem_addr,
    input  Inst     i_mem_data);


    typedef enum logic [1:0] {
        State_INIT,
        State_IDLE,
        State_ALLOC
    } State;


    InstAddr                   addr;           // Adressa
    Inst                       inst;           // Dades
    logic                      cl;             // Autoritzacio de borrat
    logic                      wr;             // Autoritzacio d' escriptura
    logic [CACHE_ELEMENTS-3:0] initCount,      // Contador per inicialitzacio
                               nextInitCount;
    logic [CACHE_BLOCKS-1:0]   allocCount,     // Contador per asignacio
                               nextAllocCount;
    InstAddr                   allocAddr,      // Adressa per assignacio
                               nextAllocAddr;
    State                      state,          // Estat
                               nextState;


    // -------------------------------------------------------------------
    // Set
    // -------------------------------------------------------------------

    logic cacheSet_hit;
    Inst  cacheSet_data;

    CacheSet #(
        .DATA_WIDTH     ($size(Inst)),
        .ADDR_WIDTH     ($size(InstAddr)),
        .CACHE_ELEMENTS (CACHE_ELEMENTS))
    cacheSet (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .i_addr  (addr),
        .i_wr    (wr),
        .i_cl    (cl),
        .i_data  (i_mem_data),
        .o_data  (cacheSet_data),
        .o_hit   (cacheSet_hit));


    // -------------------------------------------------------------------
    // FSM de control de les operacions del cache
    // -------------------------------------------------------------------

    always_comb begin

        cl = 1'b0;
        wr = 1'b0;
        addr = i_addr;
        nextInitCount = 0;
        nextAllocCount = 0;
        nextAllocAddr = {i_addr[$size(InstAddr)-1:2], 2'b00};
        nextState = state;

        unique case (state)
            State_INIT:
                begin
                    cl            = 1'b1;
                    addr          = InstAddr'({initCount, 2'b00});
                    nextInitCount = initCount + 1;
                    nextState     = (initCount == CACHE_ELEMENTS-1) ? State_IDLE : state;
                end

            State_IDLE:
                nextState = cacheSet_hit ? state : State_ALLOC;

            State_ALLOC:
                begin
                    wr             = 1'b1;
                    addr           = allocAddr;
                    o_mem_addr     = allocAddr;
                    nextAllocCount = allocCount + 1;
                    nextAllocAddr  = allocAddr + 1;
                    nextState      = (allocCount == CACHE_BLOCKS-1) ? State_IDLE : state;
                end

            default: ;
        endcase
    end

    // Asignacioo de les sortides
    //
    assign o_busy = cacheSet_hit & (state == State_IDLE);
    assign o_inst = cacheSet_data;

    // Actualitzacio dels contadors
    //
    always_ff @(posedge i_clock)
        if (i_reset) begin
            initCount <= 0;
            allocCount <= 0;
            allocAddr <= 0;
        end
        else begin
            initCount <= nextInitCount;
            allocCount <= nextAllocCount;
            allocAddr <= nextAllocAddr;
        end

    // Actualitzacio del estat
    //
    always_ff @(posedge i_clock)
        if (i_reset)
            state <= State_INIT;
        else
            state <= nextState;

endmodule
