import rv32i_defs_pkg::*;
import rv32i_config_pkg::*;
import rv32i_control_pkg::*;

interface data_mem_intf(input logic clk);
  byte_sel_t wr_sel;
  word_t addr;
  word_t wr_data;
  word_t rd_data;

  bit valid; //sim only

  clocking cb_drv @(posedge clk);
    default output #1;
    output wr_sel, addr, wr_data, valid;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input wr_sel, addr, wr_data, rd_data, valid;
  endclocking

  modport monitor(input clk, wr_sel, addr, wr_data, rd_data);

  function void print(string msg = "");
    $display("[%s] t=%0t wr_sel:%0b addr:%0d wr_data:%h rd_data:%h",
             msg, $time, wr_sel, addr, wr_data, rd_data);
  endfunction
endinterface
