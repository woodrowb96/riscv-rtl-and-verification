/*
  Base predictor class for the verification library.

  This class is basically the mirror of the base_monitor. Base_monitor monitors the DUT
  I/O and sends  the actual transaction to the scoreboard. Base_predictor monitors just
  the DUT Input and then predicts the expected output and sends the expected transaction
  to the scoreboard.

  Pure Virtual Functions:
    - predict(output TRANS_T trans)
        - User defined interface into the run() function
        - Users use this function to sample the DUT input, then predict the expected
          output and store the expected transaction in the output trans.
        - This function will run once per run() (pred.run() is being looped in the base_test)

    Virtual tasks:
        - pre_run()
            - automatically runs once before the main base_test::run() loop starts
            - by default its empty, but users can override this and add their own logic
        - post_run()
            - automatically runs once after the main base_test::run() loop ends
            - by default its empty, but users can override this and add their own logic

  Member Functions:
    - run()
        - Calls predict(), then sends the predicted transaction to the scoreboard
        - Called and looped in the base_test

  NOTE:
    - base_predictor::run() is not called at the VERY START of the BASE_TEST::run() loop,
      it is called AFTER THE FIRST DRIVE transaction has been driven into the DUT.
    - See the note in base_monitor_pkg.sv for a deeper explanation.
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

    pure virtual task predict(output TRANS_T trans);

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask

    task run();
      TRANS_T trans;
      predict(trans);
      pred_to_scb_mbx.put(trans);
    endtask
  endclass

endpackage
