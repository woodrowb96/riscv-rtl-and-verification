package tb_data_mem_transaction_pkg;
  import riscv_32i_defs_pkg::*;
  import riscv_32i_config_pkg::*;
  import riscv_32i_control_pkg::*;

  class data_mem_trans;
    rand byte_sel_t wr_sel;
    rand word_t addr;
    rand word_t wr_data;

    word_t rd_data;

    constraint legal_addr_range {
      addr inside { [DATA_MEM_MIN_ADDR : DATA_MEM_MAX_ADDR] };
    }

    function bit compare(data_mem_trans other);
      return (this.wr_sel  === other.wr_sel  &&
              this.addr    === other.addr    &&
              this.wr_data === other.wr_data &&
              this.rd_data === other.rd_data);
    endfunction

    function void print(string msg = "");
      $display("[%s] t=%0t wr_sel:%0b addr:%0d wr_data:%h rd_data:%h",
               msg, $time, wr_sel, addr, wr_data, rd_data);
    endfunction

    /******** NOTE ********/
    //Manually using the post_rand function to randomize the msb is
    //a workaround for a bug in xsim.
    //
    //SEE: tb_lut_ram_transaction_pkg.sv NOTE for a full explination
    /***********************/
    function void post_randomize();
      if(!(wr_data inside {WORD_ALL_ZEROS, WORD_ALL_ONES})) begin
        randcase
          1: wr_data[XLEN-1] = 1'b0;
          1: wr_data[XLEN-1] = 1'b1;
        endcase
      end
    endfunction
  endclass
endpackage
