/*
    Base driver class for the verification library.

    Pure Virtual Functions:
        - run()
            - User defined interface into the main testing loop (initiated by base_test::run(num_tests))
            - Users use this function to write DUT driving logic
            - This function will run once per run() (base_drive::drv() is being looped in the testing loop)

    Virtual tasks:
        - pre_run()
            - automatically runs once before the main base_test::run() loop starts
            - by default its empty, but users can override this and add their own logic
        - post_run()
            - automatically runs once after the main base_test::run() loop ends
            - by default its empty, but users can override this and add their own logic
        - drv()
            - Wrapper around base_driver::run().
            - Called and looped in the main testing loop.
            - By default there is no additional wrapping logic around base_driver::run(),
              but users can overload this function and implement any if needed
*/
package base_driver_pkg;

  virtual class base_driver #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t gen_to_drv_mbx;

    string tag;

    protected function new(string tag, mailbox_t gen_to_drv_mbx);
      this.tag = tag;
      this.gen_to_drv_mbx = gen_to_drv_mbx;
    endfunction

    pure virtual task run();

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask

    virtual task drv();
      run();
    endtask
  endclass

endpackage
