package tb_reg_file_generator_pkg;
  import base_generator_pkg::*;
  import rv32i_defs_pkg::*;
  import verify_const_pkg::*;
  import tb_reg_file_transaction_pkg::*;

  /********* NOTE  ************/
  //I would just inline the constraint in the generator, but wrapping it in
  //a class is workaround for a bug in Vivado.
  //SEE THE NOTE IN: tb_lut_ram_generator_pkg.sv for more details
  /*****************************/
  class reg_file_trans_corners extends reg_file_trans;
    constraint wr_data_corners {
      wr_data inside {
        WORD_ALL_ZEROS,
        WORD_ALL_ONES
      };
    };
  endclass

  /*==============================================================================*/
  /*------------------------------ GENERATOR -------------------------------------*/
  /*==============================================================================*/

  class reg_file_full_rand_gen extends base_generator #(reg_file_trans);

    function new(mailbox_t gen_to_drv_mbx);
      super.new("REG_FILE_FULL_RAND_GEN", gen_to_drv_mbx);
    endfunction

    function reg_file_trans gen_trans();
      reg_file_trans trans;

      //Generate with a bias towards corner wr_data values, but also generate
      //fully random wr_data values too
      randcase

        //gen corner wr_data values
        5: begin
          reg_file_trans_corners trans_corners = new();

          assert(trans_corners.randomize()) else
            $fatal(1, "TB_REG_FILE_GENERATOR: gen_trans() randomization failed, corners");

          trans = trans_corners;
        end

        //gen full range wr_data values
        1: begin
          reg_file_trans trans_full_range = new();

          assert(trans_full_range.randomize()) else
            $fatal(1, "TB_REG_FILE_GENERATOR: gen_trans() randomization failed, full range");

          trans = trans_full_range;
        end
      endcase

      return trans;
    endfunction

  endclass

endpackage
