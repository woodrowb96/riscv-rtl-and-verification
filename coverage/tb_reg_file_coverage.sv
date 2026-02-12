package tb_reg_file_coverage_pkg;
  import riscv_32i_defs_pkg::*;

  class tb_reg_file_coverage;
    virtual reg_file_intf.monitor vif;

    covergroup cg_reg_file;
      //cover writting and not writting
      cov_wr_en: coverpoint vif.wr_en{
        bins write = {1'b1};
        bins no_write = {1'b0};
      }

      //cover all our registers
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
          bins zeros = {32'h0000_0000};
          bins all_ones = {32'hffff_ffff};
          bins non_corner = {[32'h0000_0001 : 32'hffff_fffe]};
        }

      //we want to try and write non_zero data into x0
      //it will not be written (tb should test that), but
      //we want to make sure we tried at least once
      cov_x0_write: coverpoint vif.wr_data
        iff(vif.wr_en && vif.wr_reg == X0) {
          bins non_zero = {[32'h0000_0001 : 32'hffff_ffff]};
        }

      //We want to cover reading these values out from non x0 read regs
      cov_rd_data_1: coverpoint vif.rd_data_1
        iff(vif.rd_reg_1 != X0) {
        bins zeros = {32'h0000_0000};
        bins all_ones = {32'hffff_ffff};
        bins non_corner = {[32'h0000_0001 : 32'hffff_fffe]};
      }
      cov_rd_data_2: coverpoint vif.rd_data_2
        iff(vif.rd_reg_2 != X0) {
          bins zeros = {32'h0000_0000};
          bins all_ones = {32'hffff_ffff};
          bins non_corner = {[32'h0000_0001 : 32'hffff_fffe]};
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
      this.cg_reg_file = new();
    endfunction

    function void sample();
      cg_reg_file.sample();
    endfunction
  endclass
endpackage
