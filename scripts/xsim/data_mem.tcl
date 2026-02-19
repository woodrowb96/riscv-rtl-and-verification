add_wave tb_data_mem/clk
add_wave_divider
add_wave -radix binary tb_data_mem/intf/wr_sel
add_wave_divider
add_wave -radix hex tb_data_mem/intf/addr
add_wave -radix hex tb_data_mem/intf/wr_data
add_wave -radix hex tb_data_mem/intf/rd_data
add_wave_divider

run all

# write_xsim_coverage
# export_xsim_coverage -output_dir ./coverage_reports/tb_data_mem
