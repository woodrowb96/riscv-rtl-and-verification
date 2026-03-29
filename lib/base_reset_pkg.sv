/*
    Base reset class for the verification library.

    Users extend this class to implement mid-test resetting.

    Pure Virtual Tasks:
        - run()
            - Users use this task to interface into the main testing loop and
              implement their mid-test reset injection logic.
            - This task is forked off from the main testing loop and run concurrently
            - Users should write this task in such a way that it returns after asserting
              the reset (See WARNING below).
            - See base_test::rst_aware_test() for more details.

    Virtual Tasks:
        - pre_run()
            - Automatically runs once before the main testing loop starts.
            - Empty by default. Users can override to set up pre_test reset logic.
        - post_run()
            - Automatically runs once after the main testing loop ends.
            - Empty by default. Users can override to set up post test reset logic.
        - rst()
            - Wrapper around run()
            - It is this task that is called inside base_test::rst_aware_test().
            - By default just calls run(), but users can override to add any additional
              logic that should run outside run()

    For more details on how base_test handles resets, see:
        - base_test::rst_aware_test()
        - base_test::reset_recovery()
        - base_test::handle_reset()

   WARNING:
    - The base_test uses the returning of base_reset::run() to detect when a reset
      has occurred. The base_test does not directly monitor the interface or look for
      a flag or anything. When base_reset::run() returns the base_test will initiate
      its reset recovery logic.

    - It is up to the users to make sure they write their base_reset::run() implementations
      in such a way that it blocks when a reset is not being asserted and that it returns
      as soon as a reset is asserted.

    - If users are done resetting for the remainder of testing then they need to make sure
      they leave base_reset::run() in a blocked state so that it will not return.

    - The following is an example implementation. This task will assert 3 resets, then
      it will block and leave the reset_n deasserted for the rest of testing

                task run();
                  @(vif.cb_drv)                     //Make sure reset is deasserted
                  vif.cb_drv.reset_n <= 1;

                  if(count < 3) begin               //If we still have more resets to do
                    repeat(10) @(vif.cb_drv);       //wait 10 clk cycles
                    vif.cb_drv.reset_n <= 0;        //then assert the reset
                    count++;                        //increment count
                                                    //AND RETURN
                  end
                  else begin                        //If we are done with resetting
                    wait(0);                        //block indefinitely so we don't return
                  end
                endtask //Once we return, base_test will handle the reset then call base_reset::run() again
*/
package base_reset_pkg;

  virtual class base_reset;
    string tag;

    function new(string tag);
      this.tag = tag;
    endfunction

    pure virtual task run();

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask

    virtual task rst();
      run();
    endtask
  endclass

endpackage
