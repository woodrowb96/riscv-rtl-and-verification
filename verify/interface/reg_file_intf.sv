import rv32i_defs_pkg::*;

interface reg_file_intf(input clk);
  //DUT input
  logic wr_en;
  rf_addr_t rd_reg_1;
  rf_addr_t rd_reg_2;
  rf_addr_t wr_reg;
  word_t wr_data;
  //DUT output
  word_t rd_data_1;
  word_t rd_data_2;

  bit valid; //sim only

  clocking cb_drv @(posedge clk);
    default output #1;
    output wr_en, rd_reg_1, rd_reg_2, wr_reg, wr_data, valid;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input wr_en, rd_reg_1, rd_reg_2, wr_reg, wr_data, rd_data_1, rd_data_2, valid;
  endclocking

  function void print(string msg = "");
    $display("[%s] t=%0t wr_en:%0b wr_reg:%0d wr_data:%0h rd_reg_1:%0d rd_reg_2:%0d rd_data_1:%0h rd_data_2:%0h",
             msg, $time, wr_en, wr_reg, wr_data, rd_reg_1, rd_reg_2, rd_data_1, rd_data_2);
  endfunction

endinterface
