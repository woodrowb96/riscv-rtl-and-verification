package lut_ram_verify_pkg;
  import riscv_32i_defs_pkg::*;

  parameter LUT_DEPTH = 256;
  parameter LUT_WIDTH = XLEN;   //just use the xlen to verify the ram

  typedef logic [$clog2(LUT_DEPTH)-1:0] lut_addr_t;
endpackage
