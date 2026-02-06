package tb_register_file_coverage_pkg;
  class tb_register_file_coverage;
    virtual register_file_intf.monitor vif;

    covergroup cg_reg_file;
      cov_wr_en: coverpoint vif.wr_en{
        bins enabled = {1'b1};
        bins disbled = {1'b0};
      }
      cov_wr_reg: coverpoint vif.wr_reg;
      cov_rd_reg_1: coverpoint vif.rd_reg_1;
      cov_rd_reg_2: coverpoint vif.rd_reg_2;

      cov_wr_data: coverpoint vif.wr_data{
        bins zeros = {32'h0000_0000};
        bins all_ones = {32'hffff_ffff};
        bins non_corner = {[32'h0000_0001 : 32'hffff_fffe]};
      }

      cov_rd_data_1: coverpoint vif.rd_data_1
        iff(vif.rd_reg_1 != '0) {
        bins zeros = {32'h0000_0000};
        bins all_ones = {32'hffff_ffff};
        bins non_corner = {[32'h0000_0001 : 32'hffff_fffe]};
      }
      cov_rd_data_2: coverpoint vif.rd_data_2
        iff(vif.rd_reg_2 != '0) {
          bins zeros = {32'h0000_0000};
          bins all_ones = {32'hffff_ffff};
          bins non_corner = {[32'h0000_0001 : 32'hffff_fffe]};
        }
    endgroup

    function new(virtual register_file_intf.monitor vif);
      this.vif = vif;
      this.cg_reg_file = new();
    endfunction

    function void sample();
      cg_reg_file.sample();
    endfunction
  endclass
endpackage

// module tb_register_file_coverage(
//   int
// );
//   covergroup cg @(posedge clk);
//     cov_wr: coverpoint wr_en {
//       bins en = {1};
//       bins dis = {0};
//     }
//
//     cov_rd_reg_1: coverpoint rd_reg_1;
//
//     cov_rd_reg_2: coverpoint rd_reg_2;
//
//     cov_wr_reg: coverpoint wr_reg;
//
//     cov_wr_data: coverpoint wr_data iff (wr_en) {
//       bins zero = {'0};
//       bins non_zero = {[1:0]};
//     }
//
//     cov_rd_data_1: coverpoint rd_data_1 {
//       bins zero = {'0};
//       bins non_zero = {[1:0]};
//     }
//
//     cov_rd_data_2: coverpoint rd_data_2 {
//       bins zero = {'0};
//       bins non_zero = {[1:0]};
//     }
//   endgroup
//
//   cg cov = new();
// endmodule
