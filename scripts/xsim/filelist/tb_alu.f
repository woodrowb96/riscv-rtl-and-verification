#LIB
lib/base_transaction_pkg.sv
lib/base_generator_pkg.sv
lib/base_driver_pkg.sv
lib/base_monitor_pkg.sv
lib/base_scoreboard_pkg.sv
lib/base_predictor_pkg.sv
lib/base_reset_detector_pkg.sv
lib/base_test_pkg.sv

# RTL
rtl/common/rv32i_defs_pkg.sv
rtl/common/rv32i_control_pkg.sv
rtl/alu.sv

#CPP
verify/ref_model/alu_ref_model.cpp

#Verification
verify/common/verify_const_pkg.sv
verify/interface/alu_intf.sv
verify/assert/alu_assert.sv
verify/transaction/tb_alu_transaction_pkg.sv
verify/coverage/tb_alu_coverage_pkg.sv
verify/generator/tb_alu_generator_pkg.sv
verify/ref_model/alu_ref_model_pkg.sv
verify/driver/tb_alu_driver_pkg.sv
verify/monitor/tb_alu_monitor_pkg.sv
verify/predictor/tb_alu_predictor_pkg.sv
verify/scoreboard/tb_alu_scoreboard_pkg.sv
verify/tests/tb_alu_tests_pkg.sv
