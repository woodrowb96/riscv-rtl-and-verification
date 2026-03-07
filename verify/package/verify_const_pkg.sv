package verify_const_pkg;
  /************** IMM GEN VERIFICATION CONST ******************/
  localparam logic[10:0] IMM_11_ALL_ZEROS = '0;
  localparam logic[10:0] IMM_11_ALL_ONES  = '1;
  localparam logic[10:0] IMM_11_ALT_55    = 11'b01010101010;
  localparam logic[10:0] IMM_11_ALT_AA    = 11'b10101010101;

  localparam logic[19:0] IMM_20_ALL_ZEROS = '0;
  localparam logic[19:0] IMM_20_ALL_ONES  = '1;

  localparam logic[18:0] IMM_19_ALL_ZEROS = '0;
  localparam logic[18:0] IMM_19_ALL_ONES  = '1;
  localparam logic[18:0] IMM_19_ALT_55    = 19'b0101010101010101010;
  localparam logic[18:0] IMM_19_ALT_AA    = 19'b1010101010101010101;

endpackage
