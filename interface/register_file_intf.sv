interface register_file_intf(input clk);
  logic wr_en;
  logic [4:0] rd_reg_1;
  logic [4:0] rd_reg_2;
  logic [4:0] wr_reg;
  logic [31:0] wr_data;
  logic [31:0] rd_data_1;
  logic [31:0] rd_data_2;

  modport coverage(
    input wr_en, rd_reg_1, rd_reg_2, wr_reg, wr_data, rd_data_1, rd_data_2
  );
  modport assertion(
    input wr_en, rd_reg_1, rd_reg_2, wr_reg, wr_data, rd_data_1, rd_data_2
  );

  clocking cb @ (posedge clk);
    default input #1 output #2;
    input rd_data_1, rd_data_2;
    output wr_en, wr_reg, wr_data, rd_reg_1, rd_reg_2;
  endclocking

  function print_state(string msg = "");
    $display("-----------------------");
    $display("REG_FILE_INTF STATE:%s\n",msg);
    $display("time: %t", $time);
    $display("-----------------------");
    $display("wr_en: %b", intf.wr_en);
    $display("-----------------------");
    $display("wr_reg: %d", intf.wr_reg);
    $display("wr_data: %h", intf.wr_data);
    $display("rd_reg_1: %d", intf.rd_reg_1);
    $display("rd_reg_2: %d", intf.rd_reg_2);
    $display("-----------------------");
    $display("rd_reg_1: %h", intf.rd_data_1);
    $display("rd_reg_2: %h", intf.rd_data_2);
    $display("-----------------------");
  endfunction

endinterface
