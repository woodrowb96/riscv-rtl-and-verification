/*
    Base monitor class for the verification library.

    Pure Virtual Functions:
        - run()
            - User defined interface into the main testing loop (initiated by base_test::run(num_tests))
            - Users use this function to write DUT monitoring logic
            - This function will run once per run() (base_drive::drv() is being looped in the testing loop)

    Virtual tasks:
        - pre_run()
            - automatically runs once before the main base_test::run() loop starts
            - by default its empty, but users can override this and add their own logic
        - post_run()
            - automatically runs once after the main base_test::run() loop ends
            - by default its empty, but users can override this and add their own logic
        - mon()
            - Wrapper around base_monitor::run().
            - Called and looped in the main testing loop.
            - By default there is no additional wrapping logic around base_monitor::run(),
              but users can overload this function and implement any if needed
*/
package base_monitor_pkg;

  virtual class base_monitor #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t mon_to_scb_mbx;

    string tag;

    protected function new(string tag, mailbox_t mon_to_scb_mbx);
      this.tag = tag;
      this.mon_to_scb_mbx = mon_to_scb_mbx;
    endfunction

    pure virtual task run();

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask

    virtual task mon();
      run();
    endtask
  endclass

endpackage
