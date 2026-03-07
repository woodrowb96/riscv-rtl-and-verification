/*
  This module contains typedefs and params related to implementation specific control.
*/
package rv32i_control_pkg;
  /*********************** BYTE SELECT ************************/
  //select sub bytes in a word
  //for example in data_mem we use it to select which bytes to write
  //i.e: 4'b0000 -> no bytes being written
  //     4'b0010 -> only byte 2 being written
  //     4'b1111 -> the whole word being written
  /***********************************************************/
  typedef logic [3:0] byte_sel_t;

  /***************** ALU CONTROL *******************************/
  //alu operations
  typedef enum logic[3:0] {
    ALU_AND = 4'b0000,
    ALU_OR  = 4'b0001,
    ALU_ADD = 4'b0010,
    ALU_SUB = 4'b0110
  } alu_op_t;
endpackage
