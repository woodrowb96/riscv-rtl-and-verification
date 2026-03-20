/*
    Base generator class for the verification library.

    This class is used to generate transaction for a specific test.

    Pure Virtual tasks:
        - gen_trans(output TRANS_T trans)
            - User defined interface into the run() function
            - Users use this function to write their transaction generation logic
            - This function will run once per run() (gen.run() is being looped in the base_test)
            - Users can set the finished flag to 1 to signal to base_test that the
              generation of transactions is done.

    Virtual tasks:
        - pre_run()
          - automatically runs once before the main base_test::run() loop starts
          - by defualt its empty, but users can override this and add there own logic
        - post_run()
            - automatically runs once after the main base_test::run() loop ends
            - by defualt its empty, but users can override this and add there own logic

    Member Functions:
        - run()
            - Calls gen_trans(), sends generated trans to the driver, keeps track of the
              num_transactions generated.
            - Called and looped in the base_test

    WARNING:
      The base_test.run() function uses this class to determine when to end the test.
      base_test.run() will leave the main fork when either:
        - the number of transactions generated reaches num_tests (num_tests is set when users call base_test.run) OR
        - finished is set to 1
      If base_test.run() is called without a positive num_test then the test
      will look for the finished flag being set to stop the test.
      Make sure you set finished if you are not planning on calling base_test.run(num_tests)
      with a set number of tests.
*/
package base_generator_pkg;

  virtual class base_generator #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t gen_to_drv_mbx;

    string tag;

    int finished = 0;

    int num_transactions = 0;

    protected function new(string tag, mailbox_t gen_to_drv_mbx);
      this.tag = tag;
      this.gen_to_drv_mbx = gen_to_drv_mbx;
    endfunction

    pure virtual task gen_trans(output TRANS_T trans);

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask

    task run();
      TRANS_T trans;
      gen_trans(trans);
      num_transactions++;
      gen_to_drv_mbx.put(trans);
    endtask
  endclass

endpackage
