/*
  Note: Out Of Bounds Access
    - The rtl silently wraps out of bounds reads/writes to the start of memory.
      This reference model mirrors that behavior.
*/
package data_mem_ref_model_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import tb_data_mem_transaction_pkg::*;
  import lut_ram_ref_model_pkg::*;

  class data_mem_ref_model;
    localparam REF_MEM_DEPTH = DATA_MEM_DEPTH * 4;
    typedef logic [$clog2(REF_MEM_DEPTH)-1:0] ref_mem_addr_t;

    //Model the data_mem using a single lane byte wide lut_ram_ref_model that
    //is 4 times the depth. We will do all the necessary reads and writes
    //on multiple accesses to this model.
    lut_ram_ref_model #(BYTE_LEN, REF_MEM_DEPTH) ref_mem;

    function new();
      ref_mem = new();
    endfunction

    function word_t read(word_t addr);
      //Add the byte offset to each byte
      //use % to wrap the addresses to the front of mem if needed
      //then cast the type to truncate it into the ref_mem_addr_t size
      ref_mem_addr_t byte_3 = ref_mem_addr_t'((addr + 'd3) % REF_MEM_DEPTH);
      ref_mem_addr_t byte_2 = ref_mem_addr_t'((addr + 'd2) % REF_MEM_DEPTH);
      ref_mem_addr_t byte_1 = ref_mem_addr_t'((addr + 'd1) % REF_MEM_DEPTH);
      ref_mem_addr_t byte_0 = ref_mem_addr_t'((addr + 'd0) % REF_MEM_DEPTH);

      //read a whole word from the ref_mem
      return {ref_mem.read(byte_3), ref_mem.read(byte_2), ref_mem.read(byte_1), ref_mem.read(byte_0)};
    endfunction

    function void update(data_mem_trans trans);
      ref_mem_addr_t byte_3 = ref_mem_addr_t'((trans.addr + 'd3) % REF_MEM_DEPTH);
      ref_mem_addr_t byte_2 = ref_mem_addr_t'((trans.addr + 'd2) % REF_MEM_DEPTH);
      ref_mem_addr_t byte_1 = ref_mem_addr_t'((trans.addr + 'd1) % REF_MEM_DEPTH);
      ref_mem_addr_t byte_0 = ref_mem_addr_t'((trans.addr + 'd0) % REF_MEM_DEPTH);

      //look at wr_sel and write the proper bytes
      if(trans.wr_sel[3]) begin
        ref_mem.write(byte_3, trans.wr_data[31:24]);
      end
      if(trans.wr_sel[2]) begin
        ref_mem.write(byte_2, trans.wr_data[23:16]);
      end
      if(trans.wr_sel[1]) begin
        ref_mem.write(byte_1, trans.wr_data[15:8]);
      end
      if(trans.wr_sel[0]) begin
        ref_mem.write(byte_0, trans.wr_data[7:0]);
      end
    endfunction
  endclass

endpackage
