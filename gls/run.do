vlib work
vmap work

# Compile Standard Cell Library
vlog -sv /home/ICer/Labs/Lab_GLS_1.0/std_cells/tsmc13_m.v

# Compile Gate-Level Netlist
vlog -sv /home/ICer/SYSTEM_WORK/SYSTEM_FINAL/SYS_GLS/SYS_TOP.v

# Compile Testbench
vlog -sv SYS_TOP_tb.v

# Start Simulation
vsim -sdfmax SYS_TOP_tb/UUT=/home/ICer/SYSTEM_WORK/SYSTEM_FINAL/SYS_GLS/SYS_TOP.sdf -sdfnoerror work.SYS_TOP_tb

# Load waveform 
do wave_gls.do

# Run
run -all
