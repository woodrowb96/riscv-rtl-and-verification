package imm_gen_ref_model_pkg;
  import rv32i_defs_pkg::*;

  //import the .cpp reference model using dpi-c
  import "DPI-C" function int unsigned dpi_imm_gen_compute(input int unsigned inst);

  class imm_gen_ref_model;
    function word_t compute(word_t inst);
      return dpi_imm_gen_compute(inst);
    endfunction
  endclass
endpackage
