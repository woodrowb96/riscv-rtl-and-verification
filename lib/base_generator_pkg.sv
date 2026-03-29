/*
    Base generator class for the verification library.

    This class is used to generate transactions for a specific test.

    Pure Virtual Tasks:
        - run()
            - User defined interface into the main testing loop (initiated by base_test::run(num_tests)).
            - Users use this task to write their transaction generation logic.
            - By default this task will run once per iteration of the main testing loop.
            - Users can set the finished flag to 1 to signal to base_test that the
              generation of transactions is done.
            - The base_test::run(num_tests) testing loop will run until either
              gen.num_transactions == num_tests or until the finished flag is set.

    Virtual Tasks:
        - pre_run()
            - Automatically runs once before the main base_test::run() loop starts.
            - Empty by default. Users can override this and add their own logic.
        - post_run()
            - Automatically runs once after the main base_test::run() loop ends.
            - Empty by default. Users can override this and add their own logic.
        - gen()
            - Wrapper around base_generator::run().
            - Called and looped when users call base_test::run(num_tests).
            - By default it will increment num_transactions after each base_generator::run() call.
            - Users can override the default behavior and implement their own wrapping logic.

    WARNING:
        The base_test.run() function uses this class to determine when to end the test.
        base_test.run() will leave the main fork when either:
            - the number of transactions generated reaches num_tests (num_tests is set
              when users call base_test.run) OR
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

    //this is incremented once per each call of run
    //(By default the lib assumes one transaction is generated per run() call)
    int num_transactions = 0;

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

    virtual task gen();
      run();
      num_transactions++;
    endtask
  endclass

endpackage
