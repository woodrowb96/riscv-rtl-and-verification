package alu_ref_model_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;

  //import the .cpp reference model using dpi-c, with the type translations
  import "DPI-C" function void dpi_alu_compute(
      input  byte unsigned alu_op, //alu_op_t(4 bits) -> byte unsigned -> uint8_t
      input  int unsigned  in_a,   //word_t(32 bits)  -> int unsigned  -> uint32_t
      input  int unsigned  in_b,
      output int unsigned  result, //uint32_t  -> int unsigned  -> word_t(32 bits)
      output byte unsigned zero    //uint8_t  -> byte unsigned -> logic(1 bit)
  );

  typedef struct {
    word_t result;
    logic zero;
  } alu_out_t;

  class alu_ref_model;
    function alu_out_t compute(alu_op_t alu_op, word_t in_a, word_t in_b);
      int unsigned result = 32'h00BADBAD;
      byte unsigned zero = 1'b0;

      dpi_alu_compute(alu_op, in_a, in_b, result, zero);

      return '{result, zero};
    endfunction
  endclass

endpackage
