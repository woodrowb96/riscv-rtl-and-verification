package tb_reg_file_generator_pkg;
  import rv32i_defs_pkg::*;
  import verify_const_pkg::*;
  import tb_reg_file_transaction_pkg::*;

  /********* NOTE  ************/
  //Im using classes for all the contraints as a workaround for a vivado bug.
  //
  //I would just inline constrain this stuff in the generator if I could.
  //
  //SEE THE NOTE IN: tb_lut_ram_generator_pkg.sv for more details
  /*****************************/
  class reg_file_trans_corners extends reg_file_trans;
    constraint wr_data_corners {
      wr_data dist {
        WORD_ALL_ZEROS                            := 1,
        WORD_ALL_ONES                             := 1,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 10
      };
    }
  endclass

  /************************** GENERATOR *********************************/
  class tb_reg_file_generator;
    function reg_file_trans gen_trans();
      reg_file_trans_corners trans = new();

      assert(trans.randomize()) else
        $fatal(1, "TB_REG_FILE_GENERATOR: gen_trans() randomization failed");

      return trans;
    endfunction
  endclass
endpackage
