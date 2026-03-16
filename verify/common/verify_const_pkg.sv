/*
  Some constants shared between verification components
*/
package verify_const_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  /*********************** DATA_MEM *******************************/
  parameter int unsigned DATA_MEM_FIRST_ADDR = 0;                          //first address in mem (also the first byte and first word)
  parameter int unsigned DATA_MEM_LAST_ADDR = (DATA_MEM_DEPTH * 4) - 1;    //the last address in memory (so the last byte)
  parameter int unsigned DATA_MEM_LAST_WORD_ADDR = DATA_MEM_LAST_ADDR - 4; //the last full word stored in memory

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
  //signed 2s compliment bit patterns
  localparam word_t WORD_MAX_SIGNED_POS = 32'h7fff_ffff;
  localparam word_t WORD_MIN_SIGNED_NEG = 32'h8000_0000;
  localparam word_t WORD_SIGNED_POS_ONE = 32'h0000_0001;
  localparam word_t WORD_SIGNED_NEG_ONE = 32'hffff_ffff;
  localparam word_t WORD_SIGNED_ZERO    = 32'h0000_0000;


  /**************** RANGE BOUNDARIES ******************************/

  //to help split the unsigned values up into lower, middle and upper thirds
  localparam int unsigned UNSIGNED_LOWER_THIRD     = WORD_MAX_UNSIGNED / 3;
  localparam int unsigned UNSIGNED_LOWER_TWO_THIRD = (WORD_MAX_UNSIGNED / 3) * 2;
  //to help split the signed values up into high and low pos and neg 4ths
  localparam word_t SIGNED_POS_LOWER_HALF = WORD_MAX_SIGNED_POS / 2;
  localparam word_t SIGNED_NEG_LOWER_HALF = 32'hC000_0000;


  /**************** UTILITY FUNCTIONS ******************************/

  //This function is a workaround for a bug in Vivado's $urandom_range function
  //  VIVADO BUG:
  //    - Vivado must use some sort of signed in for the $urandom_range function.
  //      The problem is then if the range is two unsigned ints that cross the 
  //      0x80000000 point (like UNSIGNED_LOWER_THIRD -> UNSIGNED_LOWER_TWO_THIRD)
  //      the function screws up  the internal range calculations and spits
  //      out a value in a whole different range.
  function automatic int unsigned unsigned_urandom_range(int unsigned low, int unsigned hi);
    int unsigned offset = $urandom() % (hi - low + 1);  //calc a random offset between hi and low
    return low + offset;                                //return low plus the offset, to get the rand num
  endfunction

endpackage
