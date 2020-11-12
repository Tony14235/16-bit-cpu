onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab8_check_tb/DUT/CLOCK_50
add wave -noupdate {/lab8_check_tb/DUT/KEY[1]}
add wave -noupdate {/lab8_check_tb/DUT/LEDR[8]}
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /lab8_check_tb/DUT/CPU/SM/state
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/curr_addr
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/next_addr
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/N
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/V
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/Z
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/instruction
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/sximm8
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/eq
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/ne
add wave -noupdate /lab8_check_tb/DUT/CPU/U1/lt
add wave -noupdate /lab8_check_tb/DUT/CPU/next_pc
add wave -noupdate /lab8_check_tb/DUT/CPU/PC
add wave -noupdate /lab8_check_tb/DUT/CPU/SM/opcode
add wave -noupdate {/lab8_check_tb/DUT/MEM/mem[21]}
add wave -noupdate {/lab8_check_tb/DUT/MEM/mem[20]}
add wave -noupdate {/lab8_check_tb/DUT/MEM/mem[19]}
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1480 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 286
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1343 ps} {1599 ps}
