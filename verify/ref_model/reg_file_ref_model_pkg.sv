package reg_file_ref_model_pkg;
  import tb_reg_file_transaction_pkg::*;
  import riscv_32i_defs_pkg::*;

  class reg_file_ref_model;
    word_t ref_mem [0:RF_DEPTH-1];

    function void write(rf_addr_t index, word_t data);
      if(index != X0) begin
        ref_mem[index] = data;
      end

      //terminate the sim, if x0 ever gets set
      ref_x0_wr_check: assert(ref_mem[X0] === 0)
        else $fatal(1, "REF_REG_FILE::write(): expected x0 != 0");
    endfunction

    function word_t read(rf_addr_t index);
      if(index == X0) begin
        return '0;
      end
      return ref_mem[index];
    endfunction

    function void update(reg_file_trans inpt);
      if(inpt.wr_en) begin
        write(inpt.wr_reg, inpt.wr_data);
      end
    endfunction

    function new();
      ref_mem[X0] = 0;  //initialize x0 to 0
    endfunction
  endclass
endpackage
