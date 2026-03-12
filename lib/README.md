# Class Based Parallel Verification Library

A custom verification library for writing class-based parallel SystemVerilog testbenches.

This library provides a set of reusable base classes users can use to implement
transactions, generators, drivers, monitors, scoreboards and tests.

Each test component runs as a parallel process, forked concurrently during the test.
Each component executes its own loop, which users can interface into and customize through a set of
pure virtual functions provided in each component's base class.

See [`verify/`](../verify/) for example implementations using the library.

## Architecture

<img width="1768" height="772" alt="diagram" src="https://github.com/user-attachments/assets/3e51f2a6-ee10-47ff-819a-a61489cbdc1b" />

## Classes

Users are provided the following virtual base classes to implement their tests:

- **base_test:**
    - Orchestrates parallel testing.
    - Provides users the `base_test::run(int num_tests)` function which is used to start testing.
    - Users can interface into the `run()` function through a set of pure virtual functions
        they can use to implement their tests.
- **base_transaction:** 
    - Collection of DUT signals sent between components.
- **base_generator:**
    - Generates a sequence of transactions and sends them to the driver.
    - Users are provided the pure virtual `base_generator::gen_trans()` function which
        they can use to write sequence generation logic for their tests.
- **base_driver:**
    - Drives transactions into the DUT.
    - Users are provided the pure virtual `base_driver::drive()` function which
        they can use to implement DUT specific driving logic.
- **base_monitor:**
    - Samples DUT inputs and outputs to construct a single transaction snapshot sent to the scoreboard.
    - Users are provided the pure virtual `base_monitor::monitor()` function which
        they can use to implement DUT specific monitoring logic.
- **base_scoreboard:**
    - Scores each transaction for correctness.
    - Users are provided the pure virtual `base_scoreboard::score()` function which
        they can use to implement test specific scoring.

See the source files for full API implementation details.
