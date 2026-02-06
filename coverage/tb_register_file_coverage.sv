package tb_register_file_coverage_pkg;
  class tb_register_file_coverage;
    virtual register_file_intf.monitor vif;

    covergroup cg_reg_file @(vif.cb_monitor);
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
