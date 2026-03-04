import rv32i_defs_pkg::*;
import rv32i_config_pkg::*;
import rv32i_control_pkg::*;

interface data_mem_intf(input logic clk);
  byte_sel_t wr_sel;
  word_t addr;
  word_t wr_data;
  word_t rd_data;

  modport monitor(input clk, wr_sel, addr, wr_data, rd_data);

  function void print(string msg = "");
    $display("[%s] t=%0t wr_sel:%0b addr:%0d wr_data:%h rd_data:%h",
             msg, $time, wr_sel, addr, wr_data, rd_data);
  endfunction
endinterface
