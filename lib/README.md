# Class Based Concurrent Verification Library

A reusable verification library for writing class-based concurrent SystemVerilog testbenches.

This library provides users a set of reusable base classes they can use to implement
transactions, generators, drivers, monitors, predictors, scoreboards, mid-test resetting and tests.

Testbench components run as concurrent testing loops forked by the `base_test` class.
Interprocess communication and data passing is done through a series of mailboxes.
Users can interface into the built-in test loops and implement their DUT
specific testing logic through a series of pure virtual tasks.

This library has support for optional mid-test reset injection that users can implement
using the `base_reset` class.

See [`verify/`](../verify/) for example implementations written using the library.

See [`verify/tests/tb_if_stage_tests_pkg.sv`](../verify/tests/tb_if_stage_tests_pkg.sv)
for an example implementation that integrates mid-test resetting.

## Architecture

<img width="1500" height="1000" alt="block_diagram" src="https://github.com/user-attachments/assets/9ead8f98-b576-437e-a7c5-33a862dc020b" />


## Classes

Users are provided the following virtual base classes to implement their tests:

- **base_transaction:**
    - Collection of DUT signals sent between components.
- **base_generator:**
    - Generates a sequence of transactions and sends them to the driver via `gen_to_drv_mbx`.
    - Users implement the pure virtual `run()` task to write sequence generation logic for
      their tests.
    - Sequences typically implement a single directed or constrained-random test targeting
      a specific part of the DUT's functional coverage model.
- **base_driver:**
    - Drives transactions into the DUT.
    - Users implement the pure virtual `run()` task to write DUT-specific driving logic.
- **base_monitor:**
    - Samples DUT outputs to construct a single transaction snapshot sent to the scoreboard
      via `mon_to_scb_mbx`.
    - Users implement the pure virtual `run()` task to write DUT-specific monitoring logic.
- **base_predictor:**
    - Samples DUT inputs and predicts the expected outputs, then sends the expected
      transaction to the scoreboard via `pred_to_scb_mbx`.
    - Users implement the pure virtual `run()` task to write DUT-specific prediction logic.
- **base_scoreboard:**
    - Compares actual transactions (from the monitor) against expected transactions
      (from the predictor) and scores each for correctness.
    - Users implement the pure virtual `run()` task to write test-specific scoring logic.
- **base_test:**
    - Bundles a generator, driver, monitor, predictor and scoreboard and orchestrates
      concurrent testing.
    - Users call `base_test::run(int num_tests)` to start the concurrent test loop.
    - `pre_run()` and `post_run()` virtual tasks are provided in each component. These are
      forked concurrently across all components immediately before and after the main test
      loop.
    - Supports optional mid-test reset injection (see below).

## Mid-Test Reset Injection

The library supports optional mid-test reset injection through the `base_reset` class and
reset-aware infrastructure built into `base_test`.

- **base_reset:**
    - Users use this class to implement reset injection logic.
    - Users use the pure virtual `run()` task to implement their mid-test reset aware logic.
    - This class is optional, so users need to hook it up manually to the `base_test::rst`
      member variable when constructing their tests (see [`verify/tests/tb_if_stage_tests_pkg.sv`](../verify/tests/tb_if_stage_tests_pkg.sv)
      for more details).

- **base_test mid-test reset infrastructure:**
    - If users implement and hook up a `base_reset` class then `base_test::run()` will
      automatically run the `base_test::rst_aware_test()` version of the main testing loop.
    - `base_test::rst_aware_test()` has additional infrastructure to detect a reset,
       recover from a reset and then resume testing after a reset.
    - When `base_reset::run()` asserts a mid-test reset, `base_test` will
        - Kill all currently running testing components.
        - Flush everything currently sitting in the mailboxes.
        - Call the user defined `base_test::handle_reset()` task.
        - Once the reset has been handled it will then restart the testing components
          and resume testing.

See the source files for full API and implementation details.
