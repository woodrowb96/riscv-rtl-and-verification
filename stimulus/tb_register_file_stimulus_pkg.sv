package tb_register_file_stimulus_pkg;
  class transaction;
    rand logic wr_en;
    rand logic [4:0] rd_reg_1;
    rand logic [4:0] rd_reg_2;
    rand logic [4:0] wr_reg;
    rand logic [31:0] wr_data;

    logic [31:0] rd_data_1;
    logic [31:0] rd_data_2;

    function void print(string msg = "");
      $display("-----------------------");
      $display("transaction:%s\n",msg);
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



