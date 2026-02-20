package tb_data_mem_coverage_pkg;

  class tb_data_mem_coverage;
    virtual data_mem_intf.monitor vif;

    covergroup cg @(posedge vif.clk);
      //TO DO
    endgroup

    function new(virtual data_mem_intf.monitor vif);
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
