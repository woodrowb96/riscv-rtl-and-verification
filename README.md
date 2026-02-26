# RISCV RTL and Verification

RTL Design and Verification of a RISC-V RV32I implementation.

A specific emphasis has been put on verification.
My goal is to not only design and implement an RV32I Core, but to also fully and professionally verify that implementation.

Each RTL module is being developed alongside a full coverage-driven verification environment consisting of:
- Functional coverage
- Constrained random stimulus
- Behavioral reference models
- SVA assertions

Note: I am actively developing this project.
Current development can be viewed on the single_cycle branch.

## Project Structure

```
├── rtl/
│   ├── package/        # Type definitions, config, control enumerations
│   ├── alu.sv          # Arithmetic logic unit
│   ├── reg_file.sv     # 32x32 register file
│   ├── lut_ram.sv      # Generic parameterized LUT-RAM
│   └── data_mem.sv     # Byte-addressable data memory
│
├── verify/
│   ├── tb/             # Top-level testbenches
│   ├── transaction/    # Transaction classes (randomizable stimulus)
│   ├── generator/      # Constrained random generators
│   ├── ref_model/      # Behavioral reference models used to score tests
│   ├── coverage/       # Functional coverage
│   ├── assert/         # SVA assertion modules (bound into RTL)
│   └── interface/      # SystemVerilog interfaces
│
├── scripts/xsim/
│   ├── filelist/       # Compilation dependencies
│   └── *.tcl           # Waveform and simulation TCL scripts
│
├── xsim_comp.sh        # Compile script (Xilinx xvlog)
└── xsim_sim.sh         # Simulate script (Xilinx xsim)
```

## RTL Modules
These are the current RTL modules implemented:
- ALU
- Register File
- LUT RAM
- Data Memory

## Verification

Every RTL module is paired with an accompanying coverage-driven verification environment, a testbench, functional coverage model and SVA assertions.

### Testbench

Testbenches consist of sequential generate-drive-monitor-score loops.

Transactions are generated, driven into the DUT, monitored, and scored against the DUT's reference model.

- **Transactions** — randomizable stimulus/response pair
- **Generator** — Randomize transactions using constraints. Constraints are chosen to hit full coverage.
- **Driver** — Drive the randomized transaction into the DUT through the interface
- **Monitor** — Capture the DUT's output through the interface
- **Scoreboard** — Use the DUT's reference model to score the DUT's output

Note: I intentionally decided to not introduce parallel processes into my testbenches.
I want to keep my custom verification environment relatively simple in that regard,
so intentionally limited myself to not using forked classes for generate, drive, monitor and score.

### Functional Coverage

Each module is accompanied by a functional coverage model.
Coverage is defined inside SystemVerilog covergroups using coverpoints and crosses.

A large part of the verification process for each module consists of going back and forth
between looking at the coverage and rewriting constraints in the generator. That loop continues
until the testbench is hitting 100% coverage.

### SVA Assertions

Each RTL module is paired with an assertion module that is bound directly into the RTL.

Once bound, assertions run alongside the RTL during simulation, providing a passive secondary check
of individual functionality within the RTL itself.

Assertions can be used hierarchically just like the RTL — child module assertions can be bound inside parent
assertion modules. For example, my data_mem assertions include the assertions for lut_ram inside them.

## How to Compile and Run Simulations

I've two bash scripts that are used to compile and run simulations using Xilinx Vivado.

You only need to call the sim script on the top-level module and the script will use the
filelists to compile all the testbench dependencies.

### Compile and Simulate

```bash
# Compile a testbench and its dependencies
./xsim_comp.sh verify/tb/tb_data_mem.sv

# Run simulation (CLI mode)
./xsim_sim.sh verify/tb/tb_data_mem.sv

# Run simulation with GUI waveform viewer
./xsim_sim.sh -g verify/tb/tb_data_mem.sv
```

## Next Steps

- Short Term:
    - Continue implementing and verifying RTL.
    - Currently working towards the implementation and verification of a single-cycle version of the RV32I Core.

- Long Term:
    - Implement 5-stage pipelining with forwarding, hazard detection and branch prediction.
    - Implement memory hierarchy with an L1 cache.
    - Build UVM versions of each module's verification.
    - Get a version of the core running on an FPGA.

I am actively developing the project.
Current work can be seen on the single_cycle branch.

