/*
  This module contains typedef and param definitions concerning the rv32i specification.
*/
package rv32i_defs_pkg;
  /*****************  REGISTERS *****************************/
  parameter int unsigned XLEN = 32;   //registers are 32 bits wide

  /*********************  WORD  *****************************/
  typedef logic [XLEN-1:0] word_t;    //words are 32 bit wide

  /*********************  BYTE  *****************************/
  parameter int unsigned BYTE_LEN = 8;
  typedef logic [7:0] byte_t;

  /*****************  REGISTER FILE  *****************************/
  parameter int unsigned RF_DEPTH = 32;
  parameter int unsigned RF_ADDR_WIDTH = 5;

  typedef logic [RF_ADDR_WIDTH-1:0] rf_addr_t;

  parameter rf_addr_t X0 = 5'd0;  //x0 is a special register that always holds '0

  /***************  INSTRUCTION FIELDS ***************************/
  typedef enum logic [6:0] {
    OP_REG    = 7'b0110011,  // R-type ALU
    OP_IMM    = 7'b0010011,  // I-type ALU
    OP_LOAD   = 7'b0000011,  // I-type loads
    OP_STORE  = 7'b0100011,  // S-type stores
    OP_BRANCH = 7'b1100011,  // B-type branches
    OP_LUI    = 7'b0110111,  // U-type
    OP_AUIPC  = 7'b0010111,  // U-type
    OP_JAL    = 7'b1101111,  // J-type
    OP_JALR   = 7'b1100111   // I-type
  } opcode_t;

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
