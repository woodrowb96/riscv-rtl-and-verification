/*
    Reset detection class for the verification library.

    This library lets users implement the logic that the base_test needs to be able to
    detect when a reset is being asserted and deasserted.

    Pure Virtual Tasks:

      - detect_reset_assert():
          - This task blocks until a reset assertion is detected, it then
            unblocks and returns to indicate a reset assertion was detected.
          - Users write their own logic to block the task until reset assertion
            is detected.

        - detect_reset_deassert():
          - This task blocks until a reset deassertion is detected, it then
            unblocks and returns to indicate a reset deassertion was detected.
          - Users write their own logic to block the task until reset deassertion
            is detected.

    NOTE:
      - Detection for both tasks is indicated by returning from the tasks. This means
        users need to block the task until the assertion/deassertion happens, then
        they need to let the task return. There are no flags/events to indicate detection.

*/
package base_reset_detector_pkg;
  virtual class base_reset_detector;
    pure virtual task detect_reset_assert();
    pure virtual task detect_reset_deassert();
  endclass
endpackage
