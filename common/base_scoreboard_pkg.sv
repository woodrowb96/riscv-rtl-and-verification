package base_scoreboard_pkg;
  import base_transaction_pkg::*;

  virtual class base_scoreboard;
    typedef mailbox #(base_transaction) mailbox_t;
    mailbox_t mon_to_scb_mbx;

    int num_tests = 0;
    int num_fails = 0;

    protected function new(mailbox_t mon_to_scb_mbx);
      this.mon_to_scb_mbx = mon_to_scb_mbx;
    endfunction

    pure virtual function bit compare(input base_transaction actual_trans);

    task run();
      base_transaction actual_trans;
      mon_to_scb_mbx.get(actual_trans);

      if(!compare(actual_trans)) begin
        num_fails++;
      end

      num_tests++;
    endtask

    function void print_results(string tag = "", string msg = "");
      $display("----------------");
      if(tag != "") $display("[%s]:", tag);
      if(msg != "") $display("%s", msg);
      $display("Test results:");
      $display("Total tests ran: %0d", num_tests);
      $display("Total tests failed: %0d", num_fails);
      $display("----------------");
    endfunction
  endclass

endpackage
