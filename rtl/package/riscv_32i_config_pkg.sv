package riscv_32i_config_pkg;
  parameter int unsigned DATA_MEM_DEPTH = 1024;
  parameter int unsigned DATA_MEM_FIRST_ADDR = 0;                          //first address in mem (also the first byte and first word)
  parameter int unsigned DATA_MEM_LAST_ADDR = (DATA_MEM_DEPTH * 4) - 1;    //the last address in memory (so the last byte)
  parameter int unsigned DATA_MEM_LAST_WORD_ADDR = DATA_MEM_LAST_ADDR - 4; //the last full word stored in memory

  parameter int unsigned INST_MEM_DEPTH = 256;
  parameter int unsigned INST_MEM_LAST_ADDR = (INST_MEM_DEPTH * 4) - 4;   //last word in inst_mem
  parameter int unsigned INST_MEM_FIRST_ADDR = 0;
endpackage
