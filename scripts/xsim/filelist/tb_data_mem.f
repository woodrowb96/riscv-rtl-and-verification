#LIB
lib/base_transaction_pkg.sv
lib/base_generator_pkg.sv
lib/base_driver_pkg.sv
lib/base_monitor_pkg.sv
lib/base_scoreboard_pkg.sv
lib/base_test_pkg.sv

# RTL
rtl/common/rv32i_defs_pkg.sv
rtl/common/rv32i_control_pkg.sv
rtl/common/rv32i_config_pkg.sv
rtl/lut_ram.sv
rtl/data_mem.sv

# Verification
verify/common/verify_const_pkg.sv
verify/interface/data_mem_intf.sv
verify/assert/lut_ram_assert.sv
verify/assert/data_mem_assert.sv
verify/transaction/tb_lut_ram_transaction_pkg.sv
verify/transaction/tb_data_mem_transaction_pkg.sv
verify/ref_model/lut_ram_ref_model_pkg.sv
verify/ref_model/data_mem_ref_model_pkg.sv
verify/coverage/tb_data_mem_coverage_pkg.sv
verify/generator/tb_data_mem_generator_pkg.sv
verify/driver/tb_data_mem_driver_pkg.sv
verify/monitor/tb_data_mem_monitor_pkg.sv
verify/scoreboard/tb_data_mem_scoreboard_pkg.sv
verify/tests/tb_data_mem_tests_pkg.sv
