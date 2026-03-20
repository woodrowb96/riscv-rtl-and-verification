# RISCV RTL and Verification

RTL Design and Verification of a RISC-V RV32I implementation.

A special emphasis has been put on verification.
My goal is to not only design and implement an RV32I Core, but to also fully and professionally verify that implementation.

Each RTL module is being developed alongside a full coverage-driven class-based, concurrent verification environment consisting of:
- Functional coverage
- Constrained random stimulus
- Behavioral reference models (SystemVerilog and C++ via DPI-C)
- SystemVerilog assertions
- Directed and constrained-random tests (written with my custom verification library)

To aid in verification I have also developed a class-based concurrent verification
library (located in `lib/`), providing a reusable base class infrastructure (transaction, generator, driver, monitor, scoreboard, test) for writing module-specific directed and constrained-random tests. 
See [lib/README.md](lib/) for more details.

Note: I am actively developing this project.

## Project Structure

```
├── rtl/
│   ├── common/         # Typedefs, config, control enumerations
│   ├── alu.sv          # Arithmetic logic unit
│   ├── reg_file.sv     # 32x32 register file
│   ├── lut_ram.sv      # Generic parameterized LUT-RAM
│   ├── data_mem.sv     # Byte-addressable data memory
│   ├── inst_mem.sv     # Read-only instruction memory (ROM)
│   └── imm_gen.sv      # Immediate generation unit
│
├── lib/                # Class-based concurrent verification library
│
├── verify/
│   ├── tb/             # Top-level testbenches
│   ├── tests/          # Directed/Constrained-Random tests
│   ├── transaction/    # Transaction classes (randomizable stimulus)
│   ├── generator/      # Directed/Constrained-Random generators
│   ├── driver/         # Drivers
│   ├── monitor/        # Monitors
│   ├── predictor/      # Predictors
│   ├── scoreboard/     # Test scoring
│   ├── ref_model/      # Behavioral reference models (SV and C++ via DPI-C)
│   ├── coverage/       # Functional coverage
│   ├── assert/         # SVA assertion modules (bound into RTL)
│   ├── interface/      # Interfaces with clocking blocks
│   ├── common/         # Verification constants and utility functions
│   └── programs/       # Hex memory files used in testing
│
├── scripts/
│   ├── xsim/
│   │   ├── filelist/   # Compilation dependencies
│   │   └── *.tcl       # Waveform and simulation TCL scripts
│   └── gen/            # Python scripts for test data generation
│
├── xsim_comp.sh        # Compile script (Xilinx xvlog)
└── xsim_sim.sh         # Simulate script (Xilinx xsim)
```

## RTL Modules
I've currently implemented and verified the following modules with 100% coverage:
- ALU
- Register File
- LUT RAM
- Data Memory
- Instruction Memory
- Immediate Generator

## Verification

Each RTL module is paired with an accompanying coverage-driven verification environment,
consisting of:
- Functional Coverage Models
- Behavioral Reference Models (SystemVerilog and C++ via DPI-C)
- Assertions (SVA)
- Tests (directed or constrained-random) targeting different coverage elements
- Testbenches to run and coordinate tests

### Testbenches

Testbenches instantiate and connect the DUTs, interfaces, coverages, assertions and tests.

### Tests

Tests are class-based concurrent verification environments bundling a generator, driver, monitor, predictor and scoreboard
which together implement a single directed or constrained-random test.

Test components:
- **Generator** — Generates a sequence of transactions which implement a constrained-random or directed test.
- **Driver** — Drives generated transactions into the DUT (typically done through interface clocking blocks)
- **Monitor** — Monitors the DUT I/O ports to sample a single transaction (also typically through interface clocking blocks)
- **Predictor** — Samples the DUT inputs and uses them to predict the expected output using a reference model.
- **Scoreboard** — Scores the acual transactions from the monitor against the expected transactions from the predictor, tracks total pass/fails, adds passing transactions to functional coverage

Each testbench contains one or more tests, each targeting a different part of coverage.

Tests are implemented using the custom verification library (see [lib/README.md](lib/) for details).

### Functional Coverage

Each module is accompanied by a functional coverage model defining the nominal
and corner-case behavior each module must exercise at some point during testing
to be considered verified.

Coverage is written using SystemVerilog coverpoints and crosses describing
key values and scenarios (transitions, boundary computations, overflows, read-after-writes ...)

For a module to be considered verified the testbench must hit 100% coverage.
A large part of the verification process involves going back and forth between
the generators and coverage, tuning the constraints until we are hitting 100%.
If needed a separate directed test may be required to hit certain coverage elements.


### Assertions (SVA)

Each RTL module is paired with an assertion module that is bound directly into the RTL.

Once bound, assertions run alongside the RTL during simulation and provide a passive
secondary check of individual properties and functionalities within the RTL.

Assertions can be used hierarchically just like the RTL — child module assertions can be bound inside parent
assertion modules. For example data_mem_assert instantiates the lut_ram's lut_ram_assert 
module directly inside itself.

### Reference Models

Each module has a behavioral reference model (written in SystemVerilog or C++ via DPI-C) used by the scoreboard to verify the DUT's output.

Reference model implementations are intentionally kept as independent as possible from the RTL.
This is done by using either a different implementation than the RTL
or by writing the reference model in a completely different language (C or C++)
and integrating it into SystemVerilog via a Programming Interface (DPI-C).

Maximizing the difference between RTL and reference model implementations helps ensure 
that we are not just duplicating the same bugs in both. 
Ideally a completely different person would write the verification for each module than 
the one who wrote the RTL, but obviously that's not possible with a personal project.

## Scripts

- `scripts/gen/gen_rand_inst_mem.py`
    - Generates weighted-random 32-bit values to fill test instruction memories for testing.
- `xsim_comp.sh`
    - Compiles SystemVerilog files
    - Looks for an optional filelist (located in `scripts/xsim/filelist/module_name.f`) listing
      dependencies and compiles those too.
    - Automatically compiles any C++ DPI-C files found in the filelist using xsc.
- `xsim_sim.sh`
    - Compiles, elaborates, and simulates a testbench.
    - Supports filelist dependencies in the same way the compilation script does.
    - Automatically compiles and links C++ DPI-C files found in the filelist using xsc.
    - By default, the script looks for a TCL script named `<testbench>.tcl` to run the sim, but a custom TCL script can be specified with `-t`.
    - Supports CLI and GUI (`-g`) modes.

## How to Compile and Run Simulations

Prerequisites
    - Xilinx Vivado (xvlog, xelab, xsim, xsc must be on PATH)

```bash
# Compile a testbench and its dependencies
./xsim_comp.sh verify/tb/tb_data_mem.sv

# Run simulation (CLI mode) (uses default tcl file scripts/xsim/tb_data_mem.tcl)
./xsim_sim.sh verify/tb/tb_data_mem.sv

# Run simulation with GUI waveform viewer (uses default tcl file scripts/xsim/tb_data_mem.tcl)
./xsim_sim.sh -g verify/tb/tb_data_mem.sv

# Run simulation with GUI and a custom TCL file
./xsim_sim.sh -g -t scripts/xsim/tb_data_mem_other.tcl verify/tb/tb_data_mem.sv

```

## Next Steps

- Short Term:
    - Continue implementing and verifying RTL modules towards a single-cycle RV32I Core.

- Long Term:
    - Implement 5-stage pipelining with forwarding, hazard detection and branch prediction.
    - Implement memory hierarchy with an L1 cache.
    - Build UVM versions of each module's verification.
    - Get a version of the core running on an FPGA.

I am actively developing the project.

## Example Verification Results

Below are example results from the ALU verification environment.

### Test Output

<img width="400" alt="alu_test_output" src="https://github.com/user-attachments/assets/de2a3af2-4959-4123-abd8-41d84298c638" />

### Functional Coverage Report

<img width="1024" height="1684" alt="alu_coverage" src="https://github.com/user-attachments/assets/0b7d0fba-8e15-43b8-ba9b-b2101dbb6e38" />


