# Class Based Concurrent Verification Library

A reusable verification library for writing class-based concurrent SystemVerilog testbenches.

This library provides users a set of reusable base classes they can use to implement
transactions, generators, drivers, monitors, predictors, scoreboards and tests.

Testbench components run as concurrent testing loops forked by the `base_test` class.
Interprocess communication and data passing is done through a series of mailboxes.
Users can interface into the built-in test loops and implement their DUT
specific testing logic through a series of pure virtual tasks.

See [`verify/`](../verify/) for example implementations written using the library.

## Architecture

<img width="1500" height="1000" alt="block_diagram" src="https://github.com/user-attachments/assets/9ead8f98-b576-437e-a7c5-33a862dc020b" />


## Classes

Users are provided the following virtual base classes to implement their tests:

- **base_transaction:**
    - Collection of DUT signals sent between components.
    - Users implement the pure virtual `print()` function to display transaction contents.
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
    - Optionally supports mid-test reset injection (see below).

## Mid-Test Reset Injection

The library supports optional mid-test reset injection through `base_reset` and
reset-aware infrastructure built into `base_test`.

- **base_reset:**
    - Users extend this class to implement reset injection logic.
    - Users implement the pure virtual `run()` task to assert the DUT reset signal.
    - When `run()` returns, `base_test` interprets it as a reset event. When there are
      no more resets to inject, `run()` must block indefinitely (e.g. `wait(0)`) so
      that the test completes normally.

### How it works

1. Users construct their `base_reset` extension in their test's `new()` and assign it
   to `base_test::rst`.
2. When `rst` is set, `base_test::run()` automatically wraps the main testing loop with
   `rst_aware_test()`, which races `test()` against `rst.rst()` via `fork/join_any`.
3. If `rst.rst()` returns first (reset detected), all concurrent component threads are
   killed via `disable fork`.
4. `reset_recovery()` runs: flushes all mailboxes, reconciles `gen.num_transactions`
   with `scb.num_tests`, then calls `handle_reset()`.
5. Users override `handle_reset()` to implement their DUT/test specific cleanup
   (e.g. reference model reset, generator state reset).
6. The test loop restarts from where it left off and repeats until `test()` wins the race.

See the source files for full API and implementation details.
