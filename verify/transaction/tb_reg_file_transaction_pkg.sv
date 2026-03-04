package tb_reg_file_transaction_pkg;
  import rv32i_defs_pkg::*;

  class reg_file_trans;
    rand logic wr_en;
    rand rf_addr_t rd_reg_1;
    rand rf_addr_t rd_reg_2;
    rand rf_addr_t wr_reg;
    rand word_t wr_data;

    word_t rd_data_1;
    word_t rd_data_2;

    function bit compare(reg_file_trans other);
      return (this.wr_en === other.wr_en         &&
              this.wr_reg === other.wr_reg       &&
              this.wr_data === other.wr_data     &&
              this.rd_reg_1 === other.rd_reg_1   &&
              this.rd_reg_2 === other.rd_reg_2   &&
              this.rd_data_1 === other.rd_data_1 &&
              this.rd_data_2 === other.rd_data_2);
    endfunction

    function void print(string msg = "");
      $display("[%s] t=%0t wr_en:%0b wr_reg:%0d wr_data:%0h rd_reg_1:%0d rd_reg_2:%0d rd_data_1:%0h rd_data_2:%0h",
               msg, $time, wr_en, wr_reg, wr_data, rd_reg_1, rd_reg_2, rd_data_1, rd_data_2);
    endfunction

    /******** NOTE ********/
    //Manually using the post_rand function to randomize the msb is
    //a workaround for a bug in xsim.
    //
    //SEE: tb_lut_ram_transaction_pkg.sv NOTE for a full explination
    /***********************/
    function void post_randomize();
      if(!(wr_data inside {WORD_ALL_ZEROS, WORD_ALL_ONES})) begin
        randcase
          1: wr_data[XLEN-1] = 1'b0;
          1: wr_data[XLEN-1] = 1'b1;
        endcase
      end
    endfunction
  endclass
endpackage
