/*
    Base test class for the verification library.

    Optional Functionality:
          - Mid-test Resetting:
                - Users can integrate mid-test resetting into their tests by
                  extending the base_reset, constructing it in their child tests
                  new() and hooking it up to the base_test::rst.

                - When base_test::rst is set, base_test will automatically run the test with the
                  additional infrastructure needed to be reset aware.
                  (see base_test::rst_aware_test())

                - When a mid-test reset is detected base_test will in order:
                    - Kill all currently running concurrent processes.
                    - Call base_test::reset_recovery() which will
                       - Flush the mailboxes
                       - Make sure the scoreboard and generator are in sync
                       - Call base_test::handle_reset(), which is where users can write
                         their DUT/test specific reset handling.
                    - Call rst.deassert_rst(), which will block until the rst has been deasserted
                    - Once reset has been deasserted base_test will then resume the normal testing loop

               - For more details see:
                    - base_test::rst_aware_test()
                    - base_test::reset_recovery()
                    - base_test::handle_reset()
                    - base_reset_pkg.sv


    Pure Virtual Functions:
      - NONE

    Virtual Tasks:
      reset_recovery() [OPTIONAL]:
        - Called after a mid-test reset is detected. 
        - By default flushes mailboxes, reconciles counters, then calls handle_reset().
        - Users can override this if they need custom mailbox/counter handling.

      handle_reset() [OPTIONAL]:
        - Called at the end of reset_recovery().
        - Users use this task to interface into reset_recovery() and implement their
          test/DUT specific reset handling logic.

      pre_run() / post_run():
        - Runs once before/after the main testing loop.
        - By default these tasks fork each component's pre/post_run() tasks and run them
          concurrently.
        - Users can override this behavior and implement their own custom test level
          pre/post_run logic.

    Member Functions:
      - run(int num_tests = -1)
            - Users call this to start testing.
            - Testing completes when all generated transactions have been scored.
            - Generation stops when num_tests transactions have been generated,
              or when gen.finished is set.

        - print_results(string msg = "")
              - print total number of tests ran and total number of failed tests

    Protected Tasks:
        - test(int num_tests = -1)
              - The main testing loop.
              - Forks all component's testing tasks (gen, drv, mon, pred, scb) concurrently.
              - Waits for gen to finish
              - Then waits until scb has scored all generated transactions.

        - rst_aware_test(int num_tests = -1)
              - Wraps test() with mid-test reset infrastructure needed to detect and
                recover from mid-test resets.
              - Only called when base_test::rst is set.
*/
package base_test_pkg;
  import base_reset_pkg::*;

  virtual class base_test #(parameter type TRANS_T, GEN_T, DRV_T, MON_T, PRED_T, SCB_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t gen_to_drv_mbx;
    mailbox_t mon_to_scb_mbx;
    mailbox_t pred_to_scb_mbx;

    string tag;
    int timeout;
    bit test_running = 0; //test doesn't start running until run() is called


    /************ MANDATORY TESTING COMPONENTS ************************/
    //  - Users must implement each of these components
    //  - When written base_test extensions users need to set type params, then call new
    //    for each component
    //
    //        class my_test extends base_test #(my_trans, my_gen, my_drv, my_mon, my_pred, my_scb);
    //          function new(...);
    //            super.new(tag);
    //            gen  = new(gen_to_drv_mbx);
    //            drv  = new(..., gen_to_drv_mbx);
    //            mon  = new(..., mon_to_scb_mbx);
    //            pred = new(..., pred_to_scb_mbx);
    //            scb  = new(..., mon_to_scb_mbx, pred_to_scb_mbx);
    //          endfunction
    //        endclass
    /******************************************************************/
    GEN_T  gen;
    DRV_T  drv;
    MON_T  mon;
    PRED_T pred;
    SCB_T  scb;


    /**************** OPTIONAL TESTING COMPONENTS ************************/
    //  -If users need any of the following components they need to make them
    //  in their new() functions then connect them manually
    //            my_reset my_rst = new(...);
    //            rst = my_rst;
    /********************************************************************/
    base_reset rst = null;  //users can extend base_reset to implement mid-test resetting


    /*========================= NEW ====================================*/

    protected function new(string tag, int timeout = 1000000);
      this.tag = tag;
      this.timeout = timeout;
      gen_to_drv_mbx  = new(1); //Bounded by 1. Mid-test reset handling only works correctly when the
                                //generator can only generate one transaction at a time
      mon_to_scb_mbx  = new();
      pred_to_scb_mbx = new();
    endfunction


    /*======================= RESET HANDLING  ================================*/
    //If users implement a base_reset for mid-test resetting, then we need to
    //be able to recover from that. reset_recovery() is called after
    //a mid-test reset is detected. By default this task will flush the
    //mailboxes, reconcile gen.num_trans with scb.num_tests, then it will call
    //the handle_reset() where users will implement their test/DUT specific
    //reset handling. reset_recovery() is virtual so if users need more
    //control they can implement their own version.

    virtual task reset_recovery();
      TRANS_T flush;                            //Flush everything that's in the mailboxes
      while(mon_to_scb_mbx.try_get(flush));
      while(pred_to_scb_mbx.try_get(flush));
      while(gen_to_drv_mbx.try_get(flush));

      gen.num_transactions = scb.num_tests;    //Reconcile the num_trans generated with the num_test scored
                                               // - After a reset we should have generated exactly the
                                               //   same amount of tests that were scored.

      handle_reset();                          //Call the users handle_reset implementation
    endtask

    virtual task handle_reset();
      //Empty by default. Users can implement additional reset handling logic here.
    endtask


    /*=================== PRE_RUN and POST_RUN =========================*/
    //By default pre_run and post_run fork each component's pre/post_run task
    //to run concurrently, but these are virtual so users can override and do
    //their own thing if needed.

    virtual task pre_run();
      fork
        if(rst != null) rst.pre_run();
        gen.pre_run();
        drv.pre_run();
        mon.pre_run();
        pred.pre_run();
        scb.pre_run();
      join
    endtask

    virtual task post_run();
      fork
        if(rst != null) rst.post_run();
        gen.post_run();
        drv.post_run();
        mon.post_run();
        pred.post_run();
        scb.post_run();
      join
    endtask


    /*======================= PRINT_RESULTS =================================*/

    function void print_results(string msg = "");
      scb.print_results(this.tag, msg);
    endfunction


    /*========================== RUN =================================*/
    //Users call this to start testing

    task run(int num_tests = -1);
      pre_run();

      test_running = 1;
      if(rst != null) begin        //If we have mid-test resetting, then
        rst_aware_test(num_tests); //we need to wrap the test in some extra infrastructure
      end
      else begin                   //If there is no reset detection, then
        test(num_tests);           //we just run the test directly
      end
      test_running = 0;

      post_run();
    endtask


    /*=========================== TEST ====================================*/
    //The main testing loop.
    //  - The testing loop will terminate AFTER BOTH num_test transactions
    //    have been generated (or gen.finished is set) AND the scb has scored
    //    each transaction generated by the gen

    protected task test(int num_tests = -1);
      fork begin
        fork
          if(num_tests >= 0) while(gen.num_transactions < num_tests) gen.gen();
          else               while(!gen.finished)                    gen.gen();
          forever drv.drv();
          forever mon.mon();
          forever pred.pred();
          forever scb.scb();

          #timeout $fatal(1, "[%s]: Timeout during base_test.run(), scb.num_tests=%0d, gen.num_transactions=%0d, gen.finished=%0d, gen_to_drv_mbx=%0d",
                          tag, scb.num_tests, gen.num_transactions, gen.finished, gen_to_drv_mbx.num());
        join_any

        fork
          wait(scb.num_tests >= gen.num_transactions);

          #timeout $fatal(1, "[%s]: Timeout waiting for scoreboard drain, scb.num_tests=%0d, gen.num_transactions=%0d",
                          tag, scb.num_tests, gen.num_transactions);
        join_any

        disable fork; //terminate testing
      end join

      //If we scored too many transactions then something went wrong
      if(scb.num_tests > gen.num_transactions) begin
        $fatal(1, "[%s]: scb scored too many tests!, scb.num_tests=%0d, gen.num_transactions=%0d",
                          tag, scb.num_tests, gen.num_transactions);
      end
    endtask


    /*======================  RESET_AWARE_TEST ======================*/
    //Run the test with some extra infrastructure to handle mid-test resetting

    protected task rst_aware_test(int num_tests = -1);
      while(test_running) begin   //Repeat the following until the test is done:

        fork begin                      //Fork the main testing loop and the resetting to run concurrently
          fork
            begin
              test(num_tests);          //If test returns first -> then testing is done
              test_running = 0;
            end
            begin
              rst.assert_rst();         //If we asserted a reset first -> then test is still running
            end
          join_any
          disable fork;                 //Regardless of which it is, kill all currently running forks
        end join

        if(test_running) begin          //If test is still running, then a reset was detected
          reset_recovery();             //handle the reset
          rst.deassert_rst();           //block until we deassert the reset, then loop around and resume testing
        end
      end                       //Repeat until the test is done running
    endtask
  endclass

endpackage
