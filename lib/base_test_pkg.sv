/*
    Base test class for the verification library.

    Usage:
          - In your child tests new():
                1. Call super.new() first (this creates the mailboxes)
                2. Construct and assign gen, drv, mon, scb, pred (pass mailboxes from super)
                3. Do any additional wiring for custom child level stuff (events, custom mailboxes ...)

    Optional Usage:
          - Mid-test Reset Injection:
                - Users are provided the virtual inject_reset() task that they can use
                  to implement mid-test reset injection into their tests.

                - inject_reset() is forked off concurrently at the start of testing

                - There is no additional setup needed to add reset_injection into the
                  test besides overriding the virtual inject_reset() task.

          - Mid-Test Reset Detection:
                - If users plan on resetting the DUT during the middle of testing, then
                  they need to define their own base_reset_detector class and hook it
                  up directly to their tests.

                - Users will also need to implement the handle_reset() task to implement
                  their test/DUT specific reset handling.

                - Users may need to implement reset handling tasks in each of
                  their individual testing components, but that is left to the user
                  to define and call themselves in base_test::handle_reset().

                - When a mid-test reset assertion is detected (through the base_reset_detector)
                  the base_test will terminate all active component threads
                  (generate, drive, monitor, predict, score) then call the handle_reset() task.
                  After handle_reset() returns base_test will block until a reset deassertion
                  is detected (through base_reset_detector), then it will resume the main
                  test loops and restart each components thread.


    Pure Virtual Functions: NONE

    Virtual Task:
      handle_reset() [OPTIONAL]:
        - This is an optional task that users will use to implement their logic to
          handle a mid test reset.
        - See "Mid-Test Reset Detection" above for more details.

      inject_reset() [OPTIONAL]:
        - Users use this task to implement mid-test reset injection logic.
        - See "Mid-Test Reset Injection" above for more details.

    Member Functions:
          - run(int num_tests = -1)
                - run the test
                - Tests will run until:
                    - The number of transactions generated == num_tests OR
                    - gen.finished is set (if users dont specify a num_tests) OR
                    - we timeout
                - NOTE:
                  - mon.run() and pred.run() are not called at the same time as the other .run() functions.
                  - we wait until after the first drive transaction has been driven
                    into the DUT to start monitoring and predicting
          - pre_run()
                - runs once before the main run loop
                - forks each components pre_run() function and waits for them all to return
          - post_run()
                - runs once after the main run loop
                - forks each components post_run() function and waits for them all to return
          - print_results(string msg = "")
                - print total number of tests ran and total number of failed tests
*/
package base_test_pkg;
  import base_reset_detector_pkg::*;

  virtual class base_test #(parameter type TRANS_T, GEN_T, DRV_T, MON_T, PRED_T, SCB_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t gen_to_drv_mbx;
    mailbox_t mon_to_scb_mbx;
    mailbox_t pred_to_scb_mbx;

    //Users need to define their own reset_detector and hook it up manually
    //if they need mid-test reset detection/handling.
    base_reset_detector rst_detect = null;

    string tag;

    int timeout;

    bit test_running = 0;   //test doesnt start running until run() is called

    GEN_T  gen;
    DRV_T  drv;
    MON_T  mon;
    PRED_T pred;
    SCB_T  scb;

    protected function new(string tag, int timeout = 1000000);
      this.tag = tag;
      this.timeout = timeout;
      gen_to_drv_mbx  = new();
      mon_to_scb_mbx  = new();
      pred_to_scb_mbx = new();
    endfunction

    /*==================== VIRTUAL TASKS ================================*/

    virtual task handle_reset();
      //Empty, users will define their own reset handling if needed
      //  - Users will need to define reset_handling per component
      //  - Users will need to define how their tests call each components reset handling
    endtask

    virtual task inject_reset();
      //Empty by default
      //  - Users will need to implement their own reset injection logic if
      //    they need it.
    endtask


    /*========================== RUN =================================*/
    //Users call this to start testing

    task run(int num_tests = -1);
      pre_run();

      test_running = 1;
      fork begin
        fork
          inject_reset();              //fork off optional reset injection, then move onto testing
        join_none

        if(rst_detect != null) begin   //If we have reset detection, then
          reset_aware_test(num_tests); //We need to wrap the test in some extra infrastructure
        end
        else begin                     //If there is no reset detection, then
          test(num_tests);             //we just run the test directly
        end

        disable fork;                  //cleanup the inject_reset fork
      end join
      test_running = 0;

      post_run();
    endtask


    /*======================= PRINT_RESULTS =================================*/

    function void print_results(string msg = "");
      scb.print_results(this.tag, msg);
    endfunction


    /*=========================== TEST ====================================*/
    //The main testing loop.

    protected task test(int num_tests);
      fork begin

        fork
        //Fork each component
        //Join when the generator stops generating new sequences

          //Generator
          if(num_tests >= 0) repeat(num_tests)    gen.run();  //run till we gen the num_tests
          else               while(!gen.finished) gen.run();  //or finished flag is set

          //Driver
          forever drv.run();

          //Monitor
          begin
            wait(drv.drv_started); //wait until the first drv.run call has finished to start
            forever mon.run();
          end

          //Predictor
          begin
            wait(drv.drv_started); //wait until the first drv.run call has finished to start
            forever pred.run();
          end

          //Scoreboard
          forever scb.run();

          #timeout $fatal(1, "[%s]: Timeout during base_test.run(), scb.num_tests=%0d", tag, scb.num_tests);
        join_any

        fork
          //Wait until we score all the tests OR we timeout
          wait(scb.num_tests == gen.num_transactions);
          #timeout $fatal(1, "[%s]: Timeout waiting for scoreboard, scb.num_tests=%0d",tag, scb.num_tests);
        join_any

        disable fork;
      end join
    endtask

    /*======================  RESET_AWARE_TEST ======================*/
    //Run the test with some extra infrastructure to handle mid-test resetting

    protected task reset_aware_test(int num_tests);
      while(test_running) begin          //Repeat the following until the test is done:

        fork begin                               //Fork testing and reset_detection to run concurrently
          fork
            begin
              test(num_tests);                   //If test returns first -> then testing is done
              test_running = 0;
            end
            begin
              rst_detect.detect_reset_assert();  //If we detect a reset first -> then test is still running
            end
          join_any
          disable fork;                          //Regardless of which it is, kill all running concurrent processes
        end join

        if(test_running) begin                   //If test is still running, then a reset was detected
          handle_reset();                        //handle the reset
          rst_detect.detect_reset_deassert();    //block until the reset is deasserted
        end

      end                               //Repeat until the test is done running
    endtask


    /*=================== PRE_RUN and POST_RUN =========================*/

    protected task pre_run();
      fork
        gen.pre_run();
        drv.pre_run();
        mon.pre_run();
        pred.pre_run();
        scb.pre_run();
      join
    endtask

    protected task post_run();
      fork
        gen.post_run();
        drv.post_run();
        mon.post_run();
        pred.post_run();
        scb.post_run();
      join
    endtask
  endclass

endpackage
