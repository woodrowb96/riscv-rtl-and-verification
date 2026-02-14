package lut_ram_ref_model_pkg;
  import tb_lut_ram_stimulus_pkg::*;

  class lut_ram_ref_model #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256);
    //define the correct addres, data and transaction types based on our params
    typedef logic [$clog2(LUT_DEPTH)-1:0] addr_t;
    typedef logic [LUT_WIDTH-1:0] data_t;
    typedef lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) trans_t;

    //our reference memory array
    data_t mem [LUT_DEPTH-1:0];

    //read, with an out of bounds warning
    function data_t read(addr_t rd_addr);
      if(rd_addr >= LUT_DEPTH) begin
        $warning("LUT_REF_MODEL: out of bound read\ndepth: %d ,rd_addr: %d", LUT_DEPTH, rd_addr);
      end
      return mem[rd_addr];
    endfunction

    //write, with an out of bounds warning
    function void write(addr_t wr_addr, data_t wr_data);
      mem[wr_addr] = wr_data;
      if(wr_addr >= LUT_DEPTH) begin
        $warning("LUT_REF_MODEL: out of bound write\ndepth: %d ,wr_addr: %d", LUT_DEPTH, wr_addr);
      end
    endfunction

    //process an input transaction:
    //  predict expected outputs
    //  update reference memory state
    //  output the prediction
    function trans_t process_trans(trans_t inpt);
      trans_t expected;

      //expected input should match the inpts input
      expected.wr_en = inpt.wr_en;
      expected.wr_addr = inpt.wr_addr;
      expected.rd_addr = inpt.rd_addr;
      expected.wr_data = inpt.wr_data;

      //predict the output
      //we read before write, because our reads are async
      expected.rd_data = read(inpt.rd_addr);

      //update the ref_model mem state
      if(inpt.wr_en) begin
        write(inpt.wr_addr, inpt.wr_data);
      end

      return expected;
    endfunction
  endclass
endpackage
