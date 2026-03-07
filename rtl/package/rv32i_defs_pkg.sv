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
endpackage
