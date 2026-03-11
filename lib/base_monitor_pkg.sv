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

    NOTE:
      - base_monitor::run() is not called at the VERY START of the BASE_TEST::run() loop like
        the other classes' runs are. base_monitor::run() is called AFTER THE FIRST DRIVE transaction
        has been driven into the DUT. 

      - For example in a 1 clk cycle drive:
          - (the exact timing of events depends on driver/monitor implementation and how they
            block and sample using the clk, so this is just a rough illustrative sketch of 
            possible timing)
          - (and just to be clear base_test::run() does not depend directly on the clk 
            I'm just using it here to sketch out a possible timing)

              TEST_START      //base_test::run() is called
              drv.run()       //the first drv.run is called
              @(posedge clk)  //FIRST CLK OF TEST, drives are driven
              mon.run()       //the first mon.run is called  (in parallel with drv.run)
              drv.run()       //the second drv.run is called (in parallel with mon.run)
              @(posedge clk)  //THE SECOND CLK OF TEST, monitor the first drive, drive the second drive
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
