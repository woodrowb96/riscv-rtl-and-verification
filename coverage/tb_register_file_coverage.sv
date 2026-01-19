module tb_register_file_coverage(
  input logic clk,

  input logic wr_en,

  input logic [4:0] rd_reg_1,
  input logic [4:0] rd_reg_2,

  input logic [4:0] wr_reg,
  input logic [31:0] wr_data,

  input logic [31:0] rd_data_1,
  input logic [31:0] rd_data_2
);
  covergroup cg @(posedge clk);
    cov_wr: coverpoint wr_en {
      bins en = {1};
      bins dis = {0};
    }

    cov_rd_reg_1: coverpoint rd_reg_1;

    cov_rd_reg_2: coverpoint rd_reg_2;

    cov_wr_reg: coverpoint wr_reg;

    cov_wr_data: coverpoint wr_data iff (wr_en) {
      bins zero = {'0};
      bins non_zero = {[1:0]};
    }

    cov_rd_data_1: coverpoint rd_data_1 {
      bins zero = {'0};
      bins non_zero = {[1:0]};
    }

    cov_rd_data_2: coverpoint rd_data_2 {
      bins zero = {'0};
      bins non_zero = {[1:0]};
    }
  endgroup

  cg cov = new();
endmodule
