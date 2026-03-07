/*
  Some constants shared between verification components
*/
package verify_const_pkg;
  import rv32i_defs_pkg::*;

  /*********************** IMM_GEN *********************************/
  localparam logic[10:0] IMM_11_ALL_ZEROS = '0;
  localparam logic[10:0] IMM_11_ALL_ONES  = '1;
  localparam logic[10:0] IMM_11_ALT_55    = 11'b01010101010;
  localparam logic[10:0] IMM_11_ALT_AA    = 11'b10101010101;

  localparam logic[19:0] IMM_20_ALL_ZEROS = '0;
  localparam logic[19:0] IMM_20_ALL_ONES  = '1;

  localparam logic[18:0] IMM_19_ALL_ZEROS = '0;
  localparam logic[18:0] IMM_19_ALL_ONES  = '1;
  localparam logic[18:0] IMM_19_ALT_55    = 19'b0101010101010101010;
  localparam logic[18:0] IMM_19_ALT_AA    = 19'b1010101010101010101;

  /******************* WORDS ****************************************/
  //logical patterns
  localparam word_t WORD_ALL_ONES    = 32'hffff_ffff;
  localparam word_t WORD_ALL_ZEROS   = 32'h0000_0000;
  localparam word_t WORD_ALT_ONES_55 = 32'h5555_5555;  //the pattern 0101 repeated
  localparam word_t WORD_ALT_ONES_AA = 32'haaaa_aaaa;  //the pattern 1010 repeated
  //unsigned numbers
  localparam word_t WORD_MAX_UNSIGNED  = WORD_ALL_ONES;
  localparam word_t WORD_UNSIGNED_ONE  = 32'h0000_0001;
  localparam word_t WORD_UNSIGNED_ZERO = WORD_ALL_ZEROS;
  //signed corner bit patterns (stored as word_t to avoid signed/unsigned mismatch in constraints)
  localparam word_t WORD_MAX_SIGNED_POS = 32'h7fff_ffff;
  localparam word_t WORD_MIN_SIGNED_NEG = 32'h8000_0000;
  localparam word_t WORD_SIGNED_POS_ONE = 32'h0000_0001;
  localparam word_t WORD_SIGNED_NEG_ONE = 32'hffff_ffff;
  localparam word_t WORD_SIGNED_ZERO    = 32'h0000_0000;
endpackage
