package riscv_32i_defs_pkg;
  /*****************  REGISTERS *****************************/
  parameter int unsigned XLEN = 32;   //registers are 32 bits wide

  /*****************  WORD  *****************************/
  typedef logic [XLEN-1:0] word_t;    //words are 32 bit wide

  /*****************  BYTE  *****************************/
  parameter int unsigned BYTE_LEN = 8;
  typedef logic [7:0] byte_t;

  /*****************  REGISTER FILE  *****************************/
  parameter int unsigned RF_DEPTH = 32;        //reg file depth
  parameter int unsigned RF_ADDR_WIDTH = 5;

  typedef logic [RF_ADDR_WIDTH-1:0] rf_addr_t;

  parameter rf_addr_t X0 = 5'd0;                  //x0 is a special reg that always returns 0


  /*****************  WORD CONSTANTS  *****************************/
  //some logical patterns
  parameter int unsigned WORD_ALL_ONES = 32'hffff_ffff;
  parameter int unsigned WORD_ALL_ZEROS = 32'h0000_0000;
  parameter int unsigned WORD_ALT_ONES_AA = 32'haaaa_aaaa;
  parameter int unsigned WORD_ALT_ONES_55 = 32'h5555_5555;
  //some unsigned numbers
  parameter int unsigned WORD_MAX_UNSIGNED = WORD_ALL_ONES;
  parameter int unsigned WORD_UNSIGNED_ONE = 32'h0000_0001;
  parameter int unsigned WORD_UNSIGNED_ZERO = WORD_ALL_ZEROS;
  //signed params
  parameter int WORD_MAX_SIGNED_POS = 32'sh7fff_ffff;
  parameter int WORD_MIN_SIGNED_NEG = 32'sh8000_0000;
  parameter int WORD_SIGNED_POS_ONE = 32'sh0000_0001;
  parameter int WORD_SIGNED_NEG_ONE = 32'shffff_ffff;
  parameter int WORD_SIGNED_ZERO = 32'sh0000_0000;

endpackage
