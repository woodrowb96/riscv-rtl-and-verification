package tb_lut_ram_coverage_pkg;

  class tb_lut_ram_coverage #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256);
    typedef lut_ram_intf #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) intf_t;
    virtual intf_t.monitor vif;

    covergroup cg_lut_ram;
    endgroup

    function new(virtual intf_t.monitor vif);
      this.vif = vif;
      this.cg_lut_ram = new();
    endfunction

    function void sample();
      cg_lut_ram.sample();
    endfunction
  endclass
endpackage
