add wave sim:/tb_alu/alu_op
#add wave -divider
add wave -radix hexadecimal sim:/tb_alu/in_a
add wave -radix hexadecimal sim:/tb_alu/in_b
#add wave -divider
add wave -radix hexadecimal sim:/tb_alu/result
add wave sim:/tb_alu/zero

config wave -signalnamewidth 1
run -all
