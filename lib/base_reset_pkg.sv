/*
    Base reset class for the verification library.

    Users extend this class to implement mid-test resetting.

    Pure Virtual Tasks:
        - assert_rst()
            - Users use this task to implement their mid-test reset assertion logic.
            - During testing this task is forked off to run concurently with the main
              testing loop.
            - Users should write this task in such a way that it blocks when a reset
              is not being asserted and returns as soon as a reset is asserted.
              (base_test uses the fact that it returned to detect when the reset is asserted)
            - Users should make sure they leave this task in a blocked state if they
              are done asserting resets for the remainder of the test.
            - See base_test::rst_aware_test() for more details.

        - deassert_rst()
            - Users use this task to implement their reset deassertion logic.
            - During testing this task will be called after the test does its reset handling
              inside base_test::reset_recovery()
            - Users should write this task in such a way that it blocks while the
              reset is being asserted and returns as soon as reset is deasserted.
              (base_test uses the fact that it returned to detect when the reset has been deasserted)
            - The testing loop will restart as soon as we return from this task.
            - See base_test::rst_aware_test() for more details.

    Virtual Tasks:
        - pre_run()
            - Automatically runs once before the main testing loop starts.
            - Empty by default. Users can override to set up pre-test reset logic.
        - post_run()
            - Automatically runs once after the main testing loop ends.
            - Empty by default. Users can override to set up post-test reset logic.

    For more details on how base_test handles resets, see:
        - base_test::rst_aware_test()
        - base_test::reset_recovery()
        - base_test::handle_reset()

    WARNING:
      - Detection of reset assertion and deassertion is completly implicit. Base_test
        does not actually monitor the reset line directly to detect when an assertion
        or deassertion has happened.

      - This means that it is up to the users to make sure they write their assert_rst()
        and deassert_rst() task in such a way that they block when not asserting/deasserting
        and that they return as soon as they assert/deassert

      - If users are done resetting for the remainder of testing then they need to make sure
        they leave assert_rst() in a blocked state so that it will not return.

      - The following is an example implementation. This task will assert 3 resets, then
        it will block and leave the reset_n deasserted for the rest of testing

                task assert_rst();
                  if(count < 3) begin               //If we still have more resets to do
                    repeat(10) @(vif.cb_drv);       //wait 10 clk cycles
                    vif.cb_drv.reset_n <= 0;        //then assert the reset
                    count++;                        //increment count
                                                    //AND RETURN
                  end
                  else begin                        //If we are done with resetting
                    wait(0);                        //block indefinitely so we don't return
                  end
                endtask

                task deassert_rst();
                  repeat(5) @(vif.cb_drv);          //Hold reset for 5 cycles
                  vif.cb_drv.reset_n <= 1;          //Deassert reset
                                                    //AND RETURN
                endtask
*/
package base_reset_pkg;

  virtual class base_reset;
    string tag;

    function new(string tag);
      this.tag = tag;
    endfunction

    pure virtual task assert_rst();

    pure virtual task deassert_rst();

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask
  endclass

endpackage
