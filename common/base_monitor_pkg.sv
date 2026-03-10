/*
    A base monitor class users can use to derive there module specific monitors from.
*/
package base_monitor_pkg;
  import base_transaction_pkg::*;

  virtual class base_monitor;
    typedef mailbox #(base_transaction) mailbox_t;
    mailbox_t mon_to_scb_mbx;

    int num_transactions = 0;

    protected function new(mailbox_t mon_to_scb_mbx);
      this.mon_to_scb_mbx = mon_to_scb_mbx;
    endfunction

    pure virtual task monitor(output base_transaction trans);

    task run();
      base_transaction trans;
      monitor(trans);
      num_transactions++;
      mon_to_scb_mbx.put(trans);
    endtask
  endclass

endpackage
