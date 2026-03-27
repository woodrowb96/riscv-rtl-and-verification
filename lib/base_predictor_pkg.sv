/*
  Base predictor class for the verification library.

  This class is basically the mirror of the base_monitor. Base_monitor monitors the DUT
  I/O and sends  the actual transaction to the scoreboard. Base_predictor monitors just
  the DUT Input and then predicts the expected output and sends the expected transaction
  to the scoreboard.

  Pure Virtual Functions:
    - run()
        - User defined interface into the main testing loop (initiated by base_test::run(num_tests))
        - Users use this function to logic needed to sample DUT inputs and predict expected output
        - This function will run once per run() (base_drive::drv() is being looped in the testing loop)

    Virtual tasks:
        - pre_run()
            - automatically runs once before the main base_test::run() loop starts
            - by default its empty, but users can override this and add their own logic
        - post_run()
            - automatically runs once after the main base_test::run() loop ends
            - by default its empty, but users can override this and add their own logic
        - pred()
            - Wrapper around base_predictor::run().
            - Called and looped in the main testing loop.
            - By default there is no additional wrapping logic around base_predictor::run(),
              but users can overload this function and implement any if needed
*/
package base_predictor_pkg;

  virtual class base_predictor #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t pred_to_scb_mbx;

    string tag;

    protected function new(string tag, mailbox_t pred_to_scb_mbx);
      this.tag = tag;
      this.pred_to_scb_mbx = pred_to_scb_mbx;
    endfunction

    pure virtual task run();

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask

    virtual task pred();
      run();
    endtask
  endclass

endpackage
