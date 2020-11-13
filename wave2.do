onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate {/lab8_stage2_tb/DUT/KEY[1]}
add wave -noupdate /lab8_stage2_tb/DUT/CLOCK_50
add wave -noupdate {/lab8_stage2_tb/DUT/LEDR[8]}
add wave -noupdate /lab8_stage2_tb/DUT/CPU/SM/state
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/pc
add wave -noupdate /lab8_stage2_tb/DUT/CPU/U1/Rd
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate /lab8_stage2_tb/DUT/CPU/U1/curr_addr
add wave -noupdate /lab8_stage2_tb/DUT/CPU/U1/next_addr
add wave -noupdate /lab8_stage2_tb/DUT/CPU/PC
add wave -noupdate /lab8_stage2_tb/DUT/CPU/next_pc
add wave -noupdate /lab8_stage2_tb/DUT/CPU/s_sel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/temp_addr
add wave -noupdate /lab8_stage2_tb/DUT/CPU/return_addr
add wave -noupdate /lab8_stage2_tb/DUT/CPU/instruction
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/Ain
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/Bin
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/datapath_out
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate /lab8_stage2_tb/DUT/CPU/U1/eq
add wave -noupdate /lab8_stage2_tb/DUT/CPU/U1/ne
add wave -noupdate /lab8_stage2_tb/DUT/CPU/U1/lt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2427 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 268
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
WaveRestoreZoom {2380 ps} {2525 ps}
