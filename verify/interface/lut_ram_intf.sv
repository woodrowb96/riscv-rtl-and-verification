import lut_ram_verify_pkg::*;
import riscv_32i_defs_pkg::*;

interface lut_ram_intf(input logic clk);
  logic wr_en;
  lut_addr_t wr_addr;
  lut_addr_t rd_addr;
  word_t wr_data;
  word_t rd_data;

  modport monitor(input wr_en, wr_addr, rd_addr, wr_data, rd_data);

  function print(string msg = "");
    $display("-----------------------");
    $display("LUT_RAM_INTERFACE:%s\n",msg);
    $display("time: %t", $time);
    $display("-----------------------");
    $display("wr_en: %b", wr_en);
    $display("-----------------------");
    $display("wr_addr: %d", wr_addr);
    $display("wr_data: %h", wr_data);
    $display("-----------------------");
    $display("rd_addr: %d", rd_addr);
    $display("rd_data: %h", rd_data);
    $display("-----------------------");
  endfunction
endinterface
