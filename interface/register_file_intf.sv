interface register_file_intf(input clk);
  logic wr_en;
  logic [4:0] rd_reg_1;
  logic [4:0] rd_reg_2;
  logic [4:0] wr_reg;
  logic [31:0] wr_data;
  logic [31:0] rd_data_1;
  logic [31:0] rd_data_2;

  clocking cb_drive @ (posedge clk);
    default output #2;
    output wr_en, wr_reg, wr_data, rd_reg_1, rd_reg_2;
  endclocking

  clocking cb_monitor @ (posedge clk);
    default input #1;
    input wr_en, wr_reg, wr_data, rd_reg_1, rd_reg_2, rd_data_1, rd_data_2;
  endclocking

  modport monitor(
    clocking cb_monitor
  );

  function print(string msg = "");
    $display("-----------------------");
    $display("REG_FILE INTERFACE:%s\n",msg);
    $display("time: %t", $time);
    $display("-----------------------");
    $display("wr_en: %b", wr_en);
    $display("-----------------------");
    $display("wr_reg: %d", wr_reg);
    $display("wr_data: %h", wr_data);
    $display("rd_reg_1: %d", rd_reg_1);
    $display("rd_reg_2: %d", rd_reg_2);
    $display("-----------------------");
    $display("rd_reg_1: %h", rd_data_1);
    $display("rd_reg_2: %h", rd_data_2);
    $display("-----------------------");
  endfunction

endinterface
