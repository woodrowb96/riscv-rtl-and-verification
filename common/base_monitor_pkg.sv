/*
    A base monitor class users can use to derive there module specific monitors from.
*/
package base_monitor_pkg;

  virtual class base_monitor #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t mon_to_scb_mbx;

    string tag;
    int num_transactions = 0;

    protected function new(string tag, mailbox_t mon_to_scb_mbx);
      this.tag = tag;
      this.mon_to_scb_mbx = mon_to_scb_mbx;
    endfunction

    pure virtual task monitor(output TRANS_T trans);

    task run();
      TRANS_T trans;
      monitor(trans);
      num_transactions++;
      mon_to_scb_mbx.put(trans);
    endtask
  endclass

endpackage
