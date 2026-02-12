package tb_reg_file_stimulus_pkg;
  import riscv_32i_defs_pkg::*;

  class reg_file_trans;
    rand logic wr_en;
    rand rf_addr_t rd_reg_1;
    rand rf_addr_t rd_reg_2;
    rand rf_addr_t wr_reg;
    rand word_t wr_data;

    word_t rd_data_1;
    word_t rd_data_2;

    //We want to make sure we hit the corners
    //but want to hit non_corners most of the time
    constraint wr_data_corners {
      wr_data dist {
        32'h0000_0000 := 1,
        32'hffff_ffff := 1,
        [32'h0000_0001 : 32'hffff_fffe] :/ 10
      };
    }

    function void print(string msg = "");
      $display("-----------------------");
      $display("REG_FILE_TRANS:%s\n",msg);
      $display("time: %t", $time);
      $display("-----------------------");
      $display("wr_en: %b", wr_en);
      $display("wr_reg: %d", wr_reg);
      $display("wr_data: %h", wr_data);
      $display("-----------------------");
      $display("rd_reg_1: %d", rd_reg_1);
      $display("rd_reg_2: %d", rd_reg_2);
      $display("rd_data_1: %h", rd_data_1);
      $display("rd_data_2: %h", rd_data_2);
      $display("-----------------------");
    endfunction
  endclass
endpackage



