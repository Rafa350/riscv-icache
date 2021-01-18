module ICacheSet
    import Types::*;
#(
    parameter CACHE_BLOCKS   = 4,   // Nombre de blocks de dades en cada elements (1, 2, 4 o 8)
    parameter CACHE_ELEMENTS = 128) // Numbre d'elements en el cache
(
    input  logic    i_clock, // Clock
    input  logic    i_reset, // Reset
    input  InstAddr i_addr,  // Adressa
    input  logic    i_wr,    // Habilita escriptura
    input  logic    i_cl,    // Habilida invalidacio
    input  Inst     i_inst,  // Instruccio a escriure
    output Inst     o_inst,  // Instruccio lleigida
    output logic    o_hit);  // Indica intruccio recuperada


    localparam BLOCK_WIDTH = $clog2(CACHE_BLOCKS);
    localparam INDEX_WIDTH = $clog2(CACHE_ELEMENTS);
    localparam TAG_WIDTH   = $size(InstAddr)-INDEX_WIDTH-BLOCK_WIDTH;

    typedef logic [TAG_WIDTH-1:0] Tag;


    logic flags [CACHE_ELEMENTS];
    Tag   tags  [CACHE_ELEMENTS];
    Inst  data  [CACHE_ELEMENTS*CACHE_BLOCKS];


    logic [BLOCK_WIDTH-1:0] block = i_addr[BLOCK_WIDTH-1:0];
    logic [INDEX_WIDTH-1:0] index = i_addr[(INDEX_WIDTH+BLOCK_WIDTH)-1:BLOCK_WIDTH];
    Tag                     tag   = i_addr[(TAG_WIDTH+INDEX_WIDTH+BLOCK_WIDTH)-1:INDEX_WIDTH+BLOCK_WIDTH];

    always_ff @(posedge i_clock)
        if (~i_reset & ~i_wr & i_cl)
            flags[index] <= 1'b0;

        else if (~i_reset & i_wr & ~i_cl) begin
            flags[index] <= 1'b1;
            tags[index]  <= tag;
            data[{index, block}] <= i_inst;
        end

    assign o_inst = data[{index, block}];
    assign o_hit = (tag == tags[index]) & flags[index] & ~i_reset & ~i_cl;

endmodule