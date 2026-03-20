# Class Based Concurrent Verification Library

A reusable verification library for writing class-based concurrent SystemVerilog testbenches.

This library provides users a set of reusable base classes they can use to implement
transactions, generators, drivers, monitors, predictors, scoreboards and tests.

Testbench components run as concurrent testing loops forked by the `base_test` class.
Interprocess communication and data passing is done through a series of mailboxes.
Users can interface into the built-in test loops and implement their DUT
specific testing logic through a series of pure virtual functions and tasks.

See [`verify/`](../verify/) for example implementations written using the library.

## Architecture

<img width="1768" height="772" alt="diagram" src="https://github.com/user-attachments/assets/3e51f2a6-ee10-47ff-819a-a61489cbdc1b" />

## Classes

Users are provided the following virtual base classes to implement their tests:

- **base_test:**
    - Bundles a generator, driver, monitor, predictor and scoreboard and orchestrates concurrent testing.
    - Users are provided the built-in `base_test::run(int num_tests)` function which they can call to start the concurrent test loop.
    - Users can interface into the `run()` function through a set of pure virtual functions
        which they use to implement test and DUT-specific logic.
    - Users are provided `pre_run()` and `post_run()` virtual tasks in each component.
      These are called concurrently across all components immediately before and after the
      main test loop within `base_test::run()`.
- **base_transaction:**
    - Collection of DUT signals sent between components.
- **base_generator:**
    - Generates a sequence of transactions and sends them to the driver.
    - Users are provided the pure virtual `base_generator::gen_trans()` function which
        they can use to write sequence generation logic for their tests.
    - Sequences typically implement a single directed or constrained-random test targeting
      a specific part of the DUT's functional coverage model.
- **base_driver:**
    - Drives transactions into the DUT.
    - Users are provided the pure virtual `base_driver::drive()` function which
        they can use to implement DUT-specific driving logic.
- **base_monitor:**
    - Samples DUT inputs and outputs to construct a single transaction snapshot sent to the scoreboard.
    - Users are provided the pure virtual `base_monitor::monitor()` function which
        they can use to implement DUT-specific monitoring logic.
- **base_predictor:**
    - Sample the DUT inputs and use them to predict the expected outputs, then sends the expected transaction to the scoreboard.
    - Users are provided the pure virtual `base_predictor::predict()` function which
        they can use to implement DUT-specific prediction logic.
- **base_scoreboard:**
    - Compares actual transactions (from the monitor) against expected transactions (from the predictor)
        and scores each for correctness.
    - Users are provided the pure virtual `base_scoreboard::score()` function which
        they can use to implement test-specific scoring.

See the source files for full API implementation details.
