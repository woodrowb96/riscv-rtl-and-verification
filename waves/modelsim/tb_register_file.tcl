add wave sim:/tb_register_file/clk
add wave -divider
add wave sim:/tb_register_file/wr_en
add wave -divider
add wave -radix unsigned sim:/tb_register_file/rd_reg_1
add wave -radix unsigned sim:/tb_register_file/rd_reg_2
add wave -radix unsigned sim:/tb_register_file/wr_reg
add wave -radix hexadecimal sim:/tb_register_file/wr_data
add wave -divider
add wave -radix hexadecimal sim:/tb_register_file/rd_data_1
add wave -radix hexadecimal sim:/tb_register_file/rd_data_2
add wave -divider
add wave -radix hexadecimal sim:/tb_register_file/dut/reg_file

config wave -signalnamewidth 1
run -all
