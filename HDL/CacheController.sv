module CacheController
#(
    parameter INDEX_WIDTH = 5, // Amplada del index en bits
    parameter BLOCK_WIDTH = 2) // Amplada del block en bits
(
    input  logic i_clock,
    input  logic i_reset,
    input  logic i_hit,
    input  logic i_rd,
    input  logic [INDEX_WIDTH-1:0] i_index,
    output logic [INDEX_WIDTH-1:0] o_index,
    output logic [BLOCK_WIDTH-1:0] o_block,
    output logic o_wr,
    output logic o_cl,
    output logic o_hit,
    output logic o_busy);


    localparam CACHE_ELEMENTS = 2**INDEX_WIDTH;
    localparam CACHE_BLOCKS   = 2**BLOCK_WIDTH;


    typedef enum logic [1:0] { // Estats de la maquina
        State_INIT,            // -Inidiclitzacio
        State_IDLE,            // -Obte dades de la cache
        State_READ             // -Actualitzacio del cache
    } State;

    typedef logic [INDEX_WIDTH-1:0] Index;  // Index del cache
    typedef logic [BLOCK_WIDTH-1:0] Block;  // Bloc de dades


    Index index;      // Index del cache
    Index nextIndex;  // Seguent valor de 'index'
    Block block;      // Block del cache
    Block nextBlock;  // Seguent valor de 'block'
    State state;      // Estat de la maquina
    State nextState;  // Seguent valor de 'state'


    always_comb begin

        o_index = i_index;
        o_block = Block'(0);
        o_wr    = 1'b0;
        o_cl    = 1'b0;
        o_hit   = 1'b0;
        o_busy  = 1'b1;

        nextState = state;
        nextIndex = 0;
        nextBlock = 0;

        unique case (state)
            State_INIT:
                begin
                    o_index = index;
                    o_cl = 1'b1;
                    nextIndex = index + 1;
                    if (Index'(index) == Index'(CACHE_ELEMENTS-1))
                        nextState = State_IDLE;
                end

            State_IDLE:
                begin
                    o_hit = i_hit;
                    o_busy = 1'b0;
                    if (~i_hit & i_rd) begin
                        nextIndex = i_index;
                        nextState = State_READ;
                    end
                end

            State_READ:
                begin
                    o_index = index;
                    o_block = block;
                    o_wr = 1'b1;
                    nextIndex = index;
                    nextBlock = block + 1;
                    if (Block'(block) == Block'(CACHE_BLOCKS-1))
                        nextState = State_IDLE;
                end

            default:
                begin
                end

        endcase
    end

    always_ff @(posedge i_clock)
        if (i_reset) begin
            index <= Index'(0);
            block <= Block'(0);
            state <= State_INIT;
        end
        else begin
            index <= nextIndex;
            block <= nextBlock;
            state <= nextState;
        end


endmodule