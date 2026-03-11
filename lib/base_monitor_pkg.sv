/*
    Base monitor class for the verification library.

    Pure Virtual Functions:
      - monitor()
          - User defined interface into the run() function
          - Users use this function to write the DUT sampling logic.
          - Users sample the DUT into a transaction
          - This function will run once per run() (mon.run() is being looped in the base_test)
    Member Functions:
        - run()
            - Calls monitor to read a trans from the DUT, passes the trans to the scoreboard, increments num_transactions
            - Called and looped in the base_test
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
