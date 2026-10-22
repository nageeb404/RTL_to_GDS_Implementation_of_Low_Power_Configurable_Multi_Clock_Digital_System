
########################### Define Top Module ############################
                                                   
set top_module SYS_TOP

######################### Formality Setup File ###########################

set synopsys_auto_setup true

set_svf "../../DFT/$top_module.svf"


set SSLIB "/home/ICer/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "/home/ICer/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "/home/ICer/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

######################### Reference Container ############################

## Read Reference technology libraries

read_db -container Ref [list $SSLIB $TTLIB $FFLIB]

## Read Reference Design Files

set fh [open system.lst r+]
set rtl [read $fh]
set designs ""
regsub -all "\n" $rtl " " designs

read_verilog -container Ref $designs

## set the top Reference Design 

set_reference_design $top_module
set_top $top_module 


######################## Implementation Container #########################

## Read Implementation technology libraries

read_db -container Imp [list $SSLIB $TTLIB $FFLIB]

## Read Implementation Design Files

read_verilog -container Imp "/home/ICer/SYSTEM_WORK/SYSTEM_FINAL/pnr/export/SYS_TOP.v" 

## set the top Implementation Design

set_implementation_design $top_module
set_top $top_module


############################### Don't verify #################################

# do not verify scan in & scan out ports as a compare point as it is existed only after synthesis and not existed in the RTL

#scan in

set_dont_verify_points -type port Ref:/WORK/*/SI*

set_dont_verify_points -type port Imp:/WORK/*/SI*

#scan_out
set_dont_verify_points -type port Ref:/WORK/*/SO*

set_dont_verify_points -type port Imp:/WORK/*/SO*

############################### constants #####################################

# all atpg enable(test_mode, scan_enable) are zero during formal compare

#test_mode

set_constant -type port Ref:/WORK/*/test_mode* 0

set_constant -type port Imp:/WORK/*/test_mode* 0

#scan_enable

set_constant -type port Ref:/WORK/*/SE* 0

set_constant -type port Imp:/WORK/*/SE* 0
########################### matching Compare points ##########################

match

################################# verify #####################################

set successful [verify]
if {!$successful} {
diagnose
analyze_points -failing
}

report_passing_points > "reports/passing_points.rpt"
report_failing_points > "reports/failing_points.rpt"
report_aborted_points > "reports/aborted_points.rpt"
report_unverified_points > "reports/unverified_points.rpt"


start_gui
