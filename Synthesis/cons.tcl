
####################################################################################
# Constraints
# ----------------------------------------------------------------------------
#
# 0. Design Compiler variables
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. #set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

####################################################################################
           #########################################################
                  #### Section 0 : DC Variables ####
           #########################################################
#################################################################################### 

# Prevent assign statements in the generated netlist (must be applied before compile command)
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### 
# 1. Master Clock Definitions 
# 2. Generated Clock Definitions
# 3. Clock Latencies
# 4. Clock Uncertainties
# 4. Clock Transitions
####################################################################################

#1. Master Clocks

###### REF CLK ##################################################################

create_clock -name "REF_CLK" -period 10 -waveform "0 5" [get_ports REF_CLK]
set_clock_uncertainty -setup 0.2  [get_clocks REF_CLK]
set_clock_uncertainty -hold 0.1   [get_clocks REF_CLK]
set_clock_transition  -rise 0.05  [get_clocks REF_CLK]
set_clock_transition  -fall 0.05  [get_clocks REF_CLK]

###### UART CLK ##################################################################

create_clock -name "UART_CLK" -period 271.27 [get_ports UART_CLK]
set_clock_uncertainty -setup 0.2  [get_clocks UART_CLK]
set_clock_uncertainty -hold 0.1   [get_clocks UART_CLK]
set_clock_transition  -rise 0.05  [get_clocks UART_CLK]
set_clock_transition  -fall 0.05  [get_clocks UART_CLK]

#2. Generated clocks

###### GATED CLK ##################################################################

create_generated_clock -master_clock REF_CLK -source [get_ports REF_CLK] \
                       -name "ALU_CLK" [get_pin U0_CLK_GATE/GATED_CLK] \
                       -divide_by 1 -add
set_clock_uncertainty -setup 0.2 [get_clocks ALU_CLK]
set_clock_uncertainty -hold 0.1  [get_clocks ALU_CLK]

###### RX CLK ##################################################################

create_generated_clock -master_clock UART_CLK -source [get_ports UART_CLK] \
                       -name "RX_CLK" [get_pin U1_ClkDiv/o_div_clk] \
                       -divide_by 1 -add
set_clock_uncertainty -setup 0.2 [get_clocks RX_CLK]
set_clock_uncertainty -hold 0.1  [get_clocks RX_CLK]

###### TX CLK ##################################################################

create_generated_clock -master_clock UART_CLK -source [get_ports UART_CLK] \
                       -name "TX_CLK" [get_pin U0_ClkDiv/o_div_clk] \
                       -divide_by 32 -add
set_clock_uncertainty -setup 0.2 [get_clocks TX_CLK]
set_clock_uncertainty -hold 0.1  [get_clocks TX_CLK]



####################################################################################
           #########################################################
             #### Section 2 : Clocks Relationship ####
           #########################################################
####################################################################################

set_clock_groups -asynchronous -group [get_clocks {REF_CLK ALU_CLK}] \
                               -group [get_clocks {UART_CLK RX_CLK TX_CLK}]

set_dont_touch_network {REF_CLK ALU_CLK UART_CLK RX_CLK TX_CLK}

####################################################################################
           #########################################################
             #### Section 3 : set input/output delay on ports ####
           #########################################################
####################################################################################

#Constrain Input Paths
set_input_delay 54.254 -clock RX_CLK [get_port UART_RX_IN]


#Constrain Output Paths
set_output_delay 1.695 -clock TX_CLK [get_port UART_TX_O]
set_output_delay 54.254 -clock RX_CLK [get_port parity_error]
set_output_delay 54.254 -clock RX_CLK [get_port framing_error]


####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M [get_port UART_RX_IN]

####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################

set_load 0.1 [get_port UART_TX_O]
set_load 0.1 [get_port parity_error]
set_load 0.1 [get_port framing_error]

####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################


####################################################################################
           #########################################################
                  #### Section 8 : premapped cells ####
           #########################################################
####################################################################################


####################################################################################

