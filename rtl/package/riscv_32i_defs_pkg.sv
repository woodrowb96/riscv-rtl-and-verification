package riscv_32i_defs_pkg;
  //register and word defs
  parameter int XLEN = 32;                //registers are 32 bits wide
  typedef logic [XLEN-1:0] word_t;    //words are 32 bit wide
  //misc words
  parameter word_t WORD_ALL_ONES = 32'hffff_ffff;
  parameter word_t WORD_ALL_ZEROS = 32'h0000_0000;
  parameter word_t WORD_ALT_ONES_AA = 32'haaaa_aaaa;
  parameter word_t WORD_ALT_ONES_55 = 32'h5555_5555;
  //unsigned params
  parameter word_t WORD_MAX_UNSIGNED = WORD_ALL_ONES;
  parameter word_t WORD_UNSIGNED_ONE = 32'h0000_0001;
  parameter word_t WORD_UNSIGNED_ZERO = WORD_ALL_ZEROS;
  //signed params
  parameter word_t WORD_MAX_SIGNED_POS = 32'h7fff_ffff;
  parameter word_t WORD_MIN_SIGNED_NEG = 32'h8000_0000;
  parameter word_t WORD_SIGNED_POS_ONE = WORD_UNSIGNED_ONE;
  parameter word_t WORD_SIGNED_NEG_ONE = WORD_ALL_ONES;
  parameter word_t WORD_SIGNED_ZERO = WORD_ALL_ZEROS;

  //reg file defs
  parameter int RF_DEPTH = 32;        //reg file is 32 registers deep
  parameter int RF_ADDR_WIDTH = 5;    //A reg_file address are 5 bits wide, so we can address all 32 regs
  typedef logic [RF_ADDR_WIDTH-1:0] rf_addr_t;
  parameter rf_addr_t X0 = 5'd0;
endpackage
