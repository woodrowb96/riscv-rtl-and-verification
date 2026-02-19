package riscv_32i_config_pkg;
  parameter int unsigned DATA_MEM_DEPTH = 1024;
  parameter int unsigned DATA_MEM_MIN_ADDR = 0;
  parameter int unsigned DATA_MEM_MAX_ADDR = (DATA_MEM_DEPTH * 4) - 1;

endpackage
