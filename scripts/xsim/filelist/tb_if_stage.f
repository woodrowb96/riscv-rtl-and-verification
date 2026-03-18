#LIB
lib/base_transaction_pkg.sv
lib/base_generator_pkg.sv
lib/base_driver_pkg.sv
lib/base_monitor_pkg.sv
lib/base_scoreboard_pkg.sv
lib/base_test_pkg.sv

# RTL
rtl/common/rv32i_defs_pkg.sv
rtl/common/rv32i_config_pkg.sv
rtl/inst_mem.sv
rtl/if_stage.sv

#VERIFICATION
verify/common/verify_const_pkg.sv
verify/common/verify_config_pkg.sv
verify/interface/if_stage_intf.sv
verify/coverage/tb_if_stage_coverage_pkg.sv
verify/transaction/tb_if_stage_transaction_pkg.sv
verify/ref_model/inst_mem_ref_model_pkg.sv
verify/ref_model/if_stage_ref_model_pkg.sv
verify/generator/tb_if_stage_generator_pkg.sv
verify/driver/tb_if_stage_driver_pkg.sv
verify/monitor/tb_if_stage_monitor_pkg.sv
verify/scoreboard/tb_if_stage_scoreboard_pkg.sv
verify/tests/tb_if_stage_tests_pkg.sv
