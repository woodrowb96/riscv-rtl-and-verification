package reg_file_ref_model_pkg;
  import tb_reg_file_stimulus_pkg::*;
  import riscv_32i_defs_pkg::*;

  //struct so we can return both outputs at the same time
  typedef struct {
    word_t rd_data_1;
    word_t rd_data_2;
  } reg_file_output;

  class reg_file_ref_model;
    word_t expected [0:RF_DEPTH-1];

    //write expected values into the expected array
    function void write(rf_addr_t index, word_t data);
    //protect against x0 overwritted
    //check with an assertion that the expected x0 still equals 0
      if(index != X0) begin
        expected[index] = data;
      end
      exp_x0_wr_check: assert(expected[X0] === 0)
        else $fatal(1, "REF_REG_FILE::write(): expected x0 != 0");
    endfunction

    //Read expected values out of expected array
    function word_t read(rf_addr_t index);
    //always return 0 from expected x0
      if(index == X0) begin
        return '0;
      end
      return expected[index];
    endfunction

    function reg_file_output process_trans(reg_file_trans trans);
      reg_file_output expected_out;

      //make sure we read first to model the fact that reads are combinatorial
      expected_out.rd_data_1 = read(trans.rd_reg_1);
      expected_out.rd_data_2 = read(trans.rd_reg_2);

      if(trans.wr_en)
        write(trans.wr_reg, trans.wr_data);

      return expected_out;
    endfunction

    function new();
      expected[X0] = 0;  //initialize x0 to 0
    endfunction
  endclass
endpackage
