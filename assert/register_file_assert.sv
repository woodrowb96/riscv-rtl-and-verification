module register_file_assert(
  input logic clk,

  //control
  input logic wr_en,

  //input
  input logic [4:0] rd_reg_1,
  input logic [4:0] rd_reg_2,

  input logic [4:0] wr_reg,
  input logic [31:0] wr_data,

  //output
  input logic [31:0] rd_data_1,
  input logic [31:0] rd_data_2
);
  //immediate assertions inside of always_comb so that they are contantly asserted
  always_comb begin
    //ensure rd_reg_1 always reads 0 from x0
    x0_read_check_1:
      if(rd_reg_1 == '0) begin
        assert(rd_data_1 == '0) else begin
          $fatal("ERROR REG FILE: Read non zero x0 val from rd_reg_1");
        end
      end

    //ensure rd_reg_2 always reads 0 from x0
    x0_read_check_2:
      if(rd_reg_2 == '0) begin
        assert(rd_data_2 == '0) else begin
          $fatal("ERROR REG FILE: Read non zero x0 val from rd_reg_2");
        end
      end
  end
endmodule
