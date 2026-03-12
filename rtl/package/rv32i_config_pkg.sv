/*
  This module contains configuration parameters specific to my own rv32i implementation.
*/
package rv32i_config_pkg;
  import rv32i_defs_pkg::*;

  /*********************** DATA MEM ************************/
  parameter int unsigned DATA_MEM_DEPTH = 1024;

  parameter int unsigned DATA_MEM_FIRST_ADDR = 0;                          //first address in mem (also the first byte and first word)
  parameter int unsigned DATA_MEM_LAST_ADDR = (DATA_MEM_DEPTH * 4) - 1;    //the last address in memory (so the last byte)
  parameter int unsigned DATA_MEM_LAST_WORD_ADDR = DATA_MEM_LAST_ADDR - 4; //the last full word stored in memory

  /******************* INSTRUCTION MEM ************************/
  parameter int unsigned INST_MEM_DEPTH = 256;

  parameter int unsigned INST_MEM_LAST_ADDR = (INST_MEM_DEPTH * 4) - 4;   //last word in inst_mem
  parameter int unsigned INST_MEM_FIRST_ADDR = 0;

  /***************** INSTRUCTION MEM PROGRAMS ****************/
  parameter string NO_PROGRAM = "NO_INST_MEM_PROGRAM_SPECIFIED";

  /******************** PROGRAM COUNTER ***********************/
  parameter word_t PC_RESET = '0;
endpackage
