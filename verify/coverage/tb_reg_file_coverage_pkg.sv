package tb_reg_file_coverage_pkg;
  import rv32i_defs_pkg::*;
  import verify_const_pkg::*;

  class tb_reg_file_coverage;
    virtual reg_file_intf.monitor vif;

    covergroup cg @(posedge vif.clk);
      //cover writting and not writting
      cov_wr_en: coverpoint vif.wr_en{
        bins write = {1'b1};
        bins no_write = {1'b0};
      }

      cov_wr_reg: coverpoint vif.wr_reg;
      cov_rd_reg_1: coverpoint vif.rd_reg_1;
      cov_rd_reg_2: coverpoint vif.rd_reg_2;

      //we want to write and not write to each register
      cross_wr_en_wr_reg: cross cov_wr_en, cov_wr_reg;

      //we want to write some corners, and non corners
      //we want to actually write this data into the reg file, so
      //ensure write is enabled, and we are not pointing to x0
      cov_wr_data: coverpoint vif.wr_data
        iff(vif.wr_en && vif.wr_reg != X0) {
          bins zeros      = {WORD_ALL_ZEROS};
          bins all_ones   = {WORD_ALL_ONES};
          bins non_corner = {[WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]};
        }

      //we want to try and write non_zero data into x0
      //it will not be written (tb should test that), but
      //we want to make sure we tried at least once
      cov_x0_write: coverpoint vif.wr_data
        iff(vif.wr_en && vif.wr_reg == X0) {
          bins non_zero = {[WORD_ALL_ZEROS + 1 : WORD_ALL_ONES]};
        }

      //We want to cover reading these values out from non x0 read regs
      cov_rd_data_1: coverpoint vif.rd_data_1
        iff(vif.rd_reg_1 != X0) {
        bins zeros      = {WORD_ALL_ZEROS};
        bins all_ones   = {WORD_ALL_ONES};
        bins non_corner = {[WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]};
      }
      cov_rd_data_2: coverpoint vif.rd_data_2
        iff(vif.rd_reg_2 != X0) {
          bins zeros      = {WORD_ALL_ZEROS};
          bins all_ones   = {WORD_ALL_ONES};
          bins non_corner = {[WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]};
        }

      //we want to cover reading from a register that is getting written to
      //during the same clock cycle
      cov_read_during_write_reg_1: coverpoint (vif.wr_reg == vif.rd_reg_1)
        iff(vif.wr_en) {
          bins hit = {1};
        }
      cov_read_during_write_reg_2: coverpoint (vif.wr_reg == vif.rd_reg_2)
        iff(vif.wr_en) {
          bins hit = {1};
        }

    endgroup

    function new(virtual reg_file_intf.monitor vif);
      this.vif = vif;
      this.cg = new();
    endfunction

    function void start();
      cg.start();
    endfunction

    function void stop();
      cg.stop();
    endfunction
  endclass
endpackage
