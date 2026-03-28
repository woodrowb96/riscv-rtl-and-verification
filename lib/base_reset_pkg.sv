package base_reset_pkg;

  virtual class base_reset;
    string tag;

    function new(string tag);
      this.tag = tag;
    endfunction

    pure virtual task rst_assert();

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask
  endclass

endpackage
