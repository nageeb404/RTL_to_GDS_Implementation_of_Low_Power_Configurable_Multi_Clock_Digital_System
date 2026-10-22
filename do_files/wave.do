onerror {resume}
radix define SYS_STATES {
    "0" "IDLE" -color "white",
    "1" "WR_ADD" -color "cyan",
    "2" "RD_ADD" -color "cyan",
    "3" "WR_DATA" -color "cyan",
    "4" "WR_OP_B" -color "yellow",
    "5" "WR_OP_A" -color "yellow",
    "6" "RD_DATA" -color "cyan",
    "7" "WR_FIFO" -color "green",
    "12" "ALU_FUNC" -color "magenta",
    "13" "ALU_WR1" -color "magenta",
    "15" "ALU_WR2" -color "magenta",
    -default hexadecimal
}
quietly virtual function -install /SYS_TOP_tb/UUT/U0_RegFile -env /SYS_TOP_tb/#INITIAL#127 { &{/SYS_TOP_tb/UUT/U0_RegFile/Reg_File[15], /SYS_TOP_tb/UUT/U0_RegFile/Reg_File[14], /SYS_TOP_tb/UUT/U0_RegFile/Reg_File[13], /SYS_TOP_tb/UUT/U0_RegFile/Reg_File[12], /SYS_TOP_tb/UUT/U0_RegFile/Reg_File[11], /SYS_TOP_tb/UUT/U0_RegFile/Reg_File[10], /SYS_TOP_tb/UUT/U0_RegFile/Reg_File[9], /SYS_TOP_tb/UUT/U0_RegFile/Reg_File[8], /SYS_TOP_tb/UUT/U0_RegFile/Reg_File[7], /SYS_TOP_tb/UUT/U0_RegFile/Reg_File[4] }} NOT_USED
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group CLKs /SYS_TOP_tb/REF_CLK
add wave -noupdate -expand -group CLKs -radix binary /SYS_TOP_tb/UUT/U0_UART/RX_CLK
add wave -noupdate -expand -group CLKs -radix binary /SYS_TOP_tb/UUT/U0_UART/TX_CLK
add wave -noupdate -expand -group IN -color Wheat /SYS_TOP_tb/UART_RX_IN
add wave -noupdate -expand -group OUT -color {Steel Blue} -radix binary /SYS_TOP_tb/UART_TX_O
add wave -noupdate -expand -group OUT -color {Steel Blue} -radix binary /SYS_TOP_tb/parity_error
add wave -noupdate -expand -group OUT -color {Steel Blue} -radix binary /SYS_TOP_tb/framing_error
add wave -noupdate -expand -group FSM -radix SYS_STATES /SYS_TOP_tb/UUT/U0_SYS_CTRL/CS
add wave -noupdate -expand -group FSM -radix SYS_STATES /SYS_TOP_tb/UUT/U0_SYS_CTRL/NS
add wave -noupdate -expand -group SYNC_OUT -radix binary /SYS_TOP_tb/UUT/U0_SYS_CTRL/UART_RX_VLD
add wave -noupdate -expand -group {FIFO FULL} /SYS_TOP_tb/UUT/U0_SYS_CTRL/FIFO_FULL
add wave -noupdate -group {Operands} {/SYS_TOP_tb/UUT/U0_RegFile/Reg_File[0]}
add wave -noupdate -group {Operands} {/SYS_TOP_tb/UUT/U0_RegFile/Reg_File[1]}
add wave -noupdate -group {USED REGs} {/SYS_TOP_tb/UUT/U0_RegFile/Reg_File[5]}
add wave -noupdate -group {USED REGs} {/SYS_TOP_tb/UUT/U0_RegFile/Reg_File[6]}
add wave -noupdate -group CONFG {/SYS_TOP_tb/UUT/U0_RegFile/Reg_File[2]}
add wave -noupdate -group CONFG {/SYS_TOP_tb/UUT/U0_RegFile/Reg_File[3]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1306291337 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 189
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {706230272 ps}
