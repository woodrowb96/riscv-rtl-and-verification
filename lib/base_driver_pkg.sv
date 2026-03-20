/*
    Base driver class for the verification library.

    Pure Virtual Functions:
        - drive()
            - User defined interface into the run() function
            - Users use this function to write DUT driving logic
            - This function will run once per run() (drv.run() is being looped in the base_test)

    Virtual tasks:
        - pre_run()
            - automatically runs once before the main base_test::run() loop starts
            - by defualt its empty, but users can override this and add there own logic
        - post_run()
            - automatically runs once after the main base_test::run() loop ends
            - by defualt its empty, but users can override this and add there own logic

    Member Functions:
        - run()
            - Gets trans from generator, passes trans to drive(), calls drive()
            - Called and looped in the base_test
*/
package base_driver_pkg;

  virtual class base_driver #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t gen_to_drv_mbx;

    string tag;

    //used by base_test to call base_monitor::run() only after the first drive has happened
    bit drv_started = 0;

    protected function new(string tag, mailbox_t gen_to_drv_mbx);
      this.tag = tag;
      this.gen_to_drv_mbx = gen_to_drv_mbx;
    endfunction

    pure virtual task drive(input TRANS_T trans);

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask

    task run();
      TRANS_T trans;
      gen_to_drv_mbx.get(trans);
      drive(trans);
      drv_started = 1;  //make sure drv_started is set after the first drive
    endtask
  endclass

endpackage
