package tb_inst_mem_transaction_pkg;
  import riscv_32i_defs_pkg::*;
  import riscv_32i_config_pkg::*;

  class inst_mem_trans;
    //DUT input
    rand word_t inst_addr;
    //DUT output
    word_t inst;

    constraint legal_addr_range {
      inst_addr inside { [INST_MEM_FIRST_ADDR : INST_MEM_LAST_ADDR] };
    }
    constraint word_aligned {
      inst_addr[1:0] == 2'b00;
    }

    function bit compare(inst_mem_trans other);
      return (this.inst_addr === other.inst_addr && this.inst === other.inst);
    endfunction

    function void print(string msg = "");
      $display("[%s] t=%0t inst_addr:%0d inst:%0h", msg, $time, inst_addr, inst);
    endfunction
  endclass
endpackage

