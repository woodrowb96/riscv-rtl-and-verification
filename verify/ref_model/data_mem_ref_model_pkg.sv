package data_mem_ref_model_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import tb_data_mem_transaction_pkg::*;
  import lut_ram_ref_model_pkg::*;

  class data_mem_ref_model;
    //use the lut_ram reference model to store the memory
    //as a single byte wide, directly byte addressable memory
    lut_ram_ref_model #(BYTE_LEN, (DATA_MEM_DEPTH * 4)) mem;

    //NOTE: OUT OF BOUNDS READS AND WRITES
    //  Out of bound access wrap around to the start of memory.
    //  This mirrors the intended behavior of my rtl, which silently wraps
    //  out of bound addresses to the start of memory.
    function word_t read(word_t addr);
      //read a word_t starting from byte at addr
      return {mem.read(addr + 3), mem.read(addr + 2), mem.read(addr + 1), mem.read(addr)};
    endfunction

    function void update(data_mem_trans trans);
      //look at the trans.wr_sel bits and write to the proper bytes
      if(trans.wr_sel[0]) begin
        mem.write(trans.addr,     trans.wr_data[7:0]);
      end
      if(trans.wr_sel[1]) begin
        mem.write(trans.addr + 1, trans.wr_data[15:8]);
      end
      if(trans.wr_sel[2]) begin
        mem.write(trans.addr + 2, trans.wr_data[23:16]);
      end
      if(trans.wr_sel[3]) begin
        mem.write(trans.addr + 3, trans.wr_data[31:24]);
      end
    endfunction

    function new();
      mem = new();
    endfunction
  endclass
endpackage
