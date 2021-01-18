// -----------------------------------------------------------------------
//
//       Via de cache
//
//       Parametres:
//            DATA_WIDTH : Amplada en bits de les dades
//            ADDR_WIDTH : Amplada en bits de les d'adresses
//            SIZE       : Nombre d'entrades en el cache
//
//       Entrada:
//            i_clock   : Senyal de rellotge
//            i_reset   : Senyal de reset
//            i_addr    : Adressa
//            i_write   : Habilita l'excriptura
//            l_clear   : Habilita la neteja
//            i_data    : Dades per escriure
//
//       Sortides:
//            o_data    : Dades de lectura
//            o_hit     : Coincidencia
//
// -----------------------------------------------------------------------

module CacheSet
#(
    parameter DATA_WIDTH  = 32,
    parameter ADDR_WIDTH  = 32,
    parameter SIZE        = 128)
(
    input  logic                  i_clock, // Clock
    input  logic                  i_reset, // Reset
    input  logic [ADDR_WIDTH-1:0] i_addr,  // Adressa
    input  logic                  i_wr,    // Habilita escriptura
    input  logic                  i_cl,    // Habiliaa invalidacio
    input  logic [DATA_WIDTH-1:0] i_data,  // Dades per escriure
    output logic [DATA_WIDTH-1:0] o_data,  // Dades lleigides
    output logic                  o_hit);  // Indica coincidencia i dades recuperades


    localparam INDEX_WIDTH = $clog2(SIZE);
    localparam TAG_WIDTH   = ADDR_WIDTH-INDEX_WIDTH;


    logic [INDEX_WIDTH-1:0] index = i_addr[INDEX_WIDTH-1:0];
    logic [TAG_WIDTH-1:0]   tag   = i_addr[TAG_WIDTH+INDEX_WIDTH-1:INDEX_WIDTH];


    // -------------------------------------------------------------------
    // Memoria de dades
    // -------------------------------------------------------------------

    CacheMem #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (INDEX_WIDTH))
    dataMem (
        .i_clock (i_clock),
        .i_wr    (i_wr & ~i_cl),
        .i_addr  (index),
        .i_data  (i_data),
        .o_data  (o_data));


    // -------------------------------------------------------------------
    // Memoria de tags
    // -------------------------------------------------------------------

    logic [TAG_WIDTH-1:0] tagMem_tag;

    CacheMem #(
        .DATA_WIDTH (TAG_WIDTH),
        .ADDR_WIDTH (INDEX_WIDTH))
    tagMem (
        .i_clock (i_clock),
        .i_wr    (i_wr & ~i_cl),
        .i_addr   (index),
        .i_data  (tag),
        .o_data  (tagMem_tag));


    // -------------------------------------------------------------------
    // Memoria de flags
    // -------------------------------------------------------------------

    logic flagMem_data;

    CacheMem #(
        .DATA_WIDTH (1),
        .ADDR_WIDTH (INDEX_WIDTH))
    flagMem (
        .i_clock (i_clock),
        .i_wr    (i_wr | i_cl),
        .i_addr  (index),
        .i_data  (i_cl ? 1'b0 : 1'b1),
        .o_data  (flagMem_data));

    assign o_hit  = (tagMem_tag == tag) & flagMem_data & ~i_reset & ~i_cl & ~i_wr;

endmodule