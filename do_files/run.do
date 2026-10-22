vlib work
vlog ../rtl/*/*.*v
vlog ../rtl/*/*/*.*v
vsim -voptargs=+acc work.SYS_TOP_tb
do wave.do
run -all