/*
  NOTE: Out of bounds behavior is undefined in the rtl, so the reference model
        will issue a warning then do the read/write with the undefined behavior.
*/
package lut_ram_ref_model_pkg;
  import tb_lut_ram_transaction_pkg::*;

  class lut_ram_ref_model #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256);
    typedef logic [$clog2(LUT_DEPTH)-1:0]         addr_t;
    typedef logic [LUT_WIDTH-1:0]                 data_t;
    typedef lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) trans_t;

    data_t mem [0:LUT_DEPTH-1];

    function data_t read(addr_t rd_addr);
      if(rd_addr >= LUT_DEPTH) begin
        $warning("LUT_REF_MODEL: out of bound read depth:%0d rd_addr:%0d", LUT_DEPTH, rd_addr);
      end
      return mem[rd_addr];
    endfunction

    function void write(addr_t wr_addr, data_t wr_data);
      if(wr_addr >= LUT_DEPTH) begin
        $warning("LUT_REF_MODEL: out of bound write depth:%0d wr_addr:%0d", LUT_DEPTH, wr_addr);
      end
      mem[wr_addr] = wr_data;
    endfunction

    function void update(trans_t inpt);
      if(inpt.wr_en) begin
        write(inpt.wr_addr, inpt.wr_data);
      end
    endfunction
  endclass
endpackage
