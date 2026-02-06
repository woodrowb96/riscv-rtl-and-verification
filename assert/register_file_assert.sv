module register_file_assert(
  register_file_intf.assertion intf
);
  //immediate assertions inside of always_comb so that they are contantly asserted
  always_comb begin
    //ensure rd_reg_1 always reads 0 from x0
    x0_read_check_1:
      if(intf.rd_reg_1 == '0) begin
        assert(intf.rd_data_1 == '0) else begin
          $fatal("ERROR REG FILE: Read non zero x0 val from rd_reg_1");
        end
      end

    //ensure rd_reg_2 always reads 0 from x0
    x0_read_check_2:
      if(intf.rd_reg_2 == '0) begin
        assert(intf.rd_data_2 == '0) else begin
          $fatal("ERROR REG FILE: Read non zero x0 val from rd_reg_2");
        end
      end
  end
endmodule
