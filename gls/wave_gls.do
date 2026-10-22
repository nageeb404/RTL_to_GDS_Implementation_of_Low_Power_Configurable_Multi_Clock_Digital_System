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
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group CLKs /SYS_TOP_tb/UUT/REF_CLK
add wave -noupdate -expand -group CLKs -radix binary /SYS_TOP_tb/UUT/M_UART_RX_CLK
add wave -noupdate -expand -group CLKs -radix binary /SYS_TOP_tb/UUT/M_UART_TX_CLK
add wave -noupdate -expand -group IN /SYS_TOP_tb/UUT/UART_RX_IN
add wave -noupdate -expand -group OUT -color {Steel Blue} -radix binary /SYS_TOP_tb/UART_TX_O
add wave -noupdate -expand -group OUT -color {Steel Blue} -radix binary /SYS_TOP_tb/parity_error
add wave -noupdate -expand -group OUT -color {Steel Blue} -radix binary /SYS_TOP_tb/framing_error
add wave -noupdate -expand -group SYNC_OUT -radix binary /SYS_TOP_tb/UUT/UART_RX_V_SYNC
add wave -noupdate -expand -group Operands /SYS_TOP_tb/UUT/Operand_A
add wave -noupdate -expand -group Operands /SYS_TOP_tb/UUT/Operand_B
add wave -noupdate -expand -group CONFG /SYS_TOP_tb/UUT/UART_Config
add wave -noupdate -expand -group CONFG /SYS_TOP_tb/UUT/DIV_RATIO
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
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
WaveRestoreZoom {2373872984 ps} {3323872984 ps}
