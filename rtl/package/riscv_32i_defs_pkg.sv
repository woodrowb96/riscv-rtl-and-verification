package riscv_32i_defs_pkg;
  //riscv 32i registers
  parameter int XLEN = 32;                //registers are 32 bits wide
  typedef logic [XLEN-1:0] word_t;    //words are 32 bit wide

  //reg file parameters
  parameter int RF_DEPTH = 32;        //reg file is 32 registers deep
  parameter int RF_ADDR_WIDTH = 5;    //A reg_file address are 5 bits wide, so we can address all 32 regs
  typedef logic [RF_ADDR_WIDTH-1:0] rf_addr_t;
  parameter rf_addr_t X0 = 5'd0;

  //alu params
endpackage
