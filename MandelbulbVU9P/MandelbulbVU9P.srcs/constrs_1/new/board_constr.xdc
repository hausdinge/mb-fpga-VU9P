
set_property IOSTANDARD LVDS [get_ports dclk_p]
set_property IOSTANDARD LVDS [get_ports dclk_n]

set_property PACKAGE_PIN AY24 [get_ports dclk_p]
set_property PACKAGE_PIN AY23 [get_ports dclk_n]


set_property PACKAGE_PIN W8 [get_ports gt_refclk_n]
set_property PACKAGE_PIN W9 [get_ports gt_refclk_p]

set_property PACKAGE_PIN Y2 [get_ports {gt_rxp_in[0]}]
set_property PACKAGE_PIN Y1 [get_ports {gt_rxn_in[0]}]
set_property PACKAGE_PIN V7 [get_ports {gt_txp_out[0]}]
set_property PACKAGE_PIN V6 [get_ports {gt_txn_out[0]}]

set_property PACKAGE_PIN W4 [get_ports {gt_rxp_in[1]}]
set_property PACKAGE_PIN W3 [get_ports {gt_rxn_in[1]}]
set_property PACKAGE_PIN T7 [get_ports {gt_txp_out[1]}]
set_property PACKAGE_PIN T6 [get_ports {gt_txn_out[1]}]

set_property PACKAGE_PIN V2 [get_ports {gt_rxp_in[2]}]
set_property PACKAGE_PIN V1 [get_ports {gt_rxn_in[2]}]
set_property PACKAGE_PIN P7 [get_ports {gt_txp_out[2]}]
set_property PACKAGE_PIN P6 [get_ports {gt_txn_out[2]}]

set_property PACKAGE_PIN U4 [get_ports {gt_rxp_in[3]}]
set_property PACKAGE_PIN U3 [get_ports {gt_rxn_in[3]}]
set_property PACKAGE_PIN M7 [get_ports {gt_txp_out[3]}]
set_property PACKAGE_PIN M6 [get_ports {gt_txn_out[3]}]

# CPU_RESET
set_property PACKAGE_PIN L19 [get_ports sys_reset]
set_property IOSTANDARD LVCMOS12 [get_ports sys_reset]

###Board constraints to be added here
### Below XDC constraints are for VCU108 board with xcvu095-ffva2104-2-e-es2 device
### Change these constraints as per your board and device
#### Push Buttons
#button center
set_property PACKAGE_PIN BD23 [get_ports btnc]
set_property IOSTANDARD LVCMOS18 [get_ports btnc]

#button south
set_property PACKAGE_PIN BE22 [get_ports btnd]
set_property IOSTANDARD LVCMOS18 [get_ports btnd]

#button west
set_property PACKAGE_PIN BF22 [get_ports btnr]
set_property IOSTANDARD LVCMOS18 [get_ports btnr]

#button north
set_property PACKAGE_PIN BB24 [get_ports btnu]
set_property IOSTANDARD LVCMOS18 [get_ports btnu]

#button east
set_property PACKAGE_PIN BE23 [get_ports btnl]
set_property IOSTANDARD LVCMOS18 [get_ports btnl]

### LEDs
set_property PACKAGE_PIN AT32 [get_ports rx_gt_locked_led]
set_property IOSTANDARD LVCMOS12 [get_ports rx_gt_locked_led]
##
set_property PACKAGE_PIN AV34 [get_ports rx_block_lock_led]
set_property IOSTANDARD LVCMOS12 [get_ports rx_block_lock_led]
##
set_property PACKAGE_PIN AY30 [get_ports {completion_status[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {completion_status[0]}]
##
set_property PACKAGE_PIN BB32 [get_ports {completion_status[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {completion_status[1]}]
##
set_property PACKAGE_PIN BF32 [get_ports {completion_status[2]}]
set_property IOSTANDARD LVCMOS12 [get_ports {completion_status[2]}]
##
set_property PACKAGE_PIN AU37 [get_ports {completion_status[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {completion_status[3]}]
##
set_property PACKAGE_PIN AV36 [get_ports {completion_status[4]}]
set_property IOSTANDARD LVCMOS12 [get_ports {completion_status[4]}]


##
## Switches
##
set_property PACKAGE_PIN D21 [get_ports {sw0}]
set_property PACKAGE_PIN J16 [get_ports {sw1}]
set_property PACKAGE_PIN G16 [get_ports {sw2}]
set_property PACKAGE_PIN B17 [get_ports {sw3}]
set_property IOSTANDARD LVCMOS12 [get_ports {sw0}]
set_property IOSTANDARD LVCMOS12 [get_ports {sw1}]
set_property IOSTANDARD LVCMOS12 [get_ports {sw2}]
set_property IOSTANDARD LVCMOS12 [get_ports {sw3}]



create_clock -period 8.000 -name dclk_clk [get_pins dclk_BUFG_inst/O]



set_property IOSTANDARD LVDS [get_ports uclk_p]
set_property IOSTANDARD LVDS [get_ports uclk_n]

set_property PACKAGE_PIN AW23 [get_ports uclk_p]
set_property PACKAGE_PIN AW22 [get_ports uclk_n]

create_clock -period 6.400 -name uclk_clk [get_pins uclk_BUFG_inst/O]



set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */channel_inst/*_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */channel_inst/*_CHANNEL_PRIM_INST/TXOUTCLK}]] 6.400
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */channel_inst/*_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */channel_inst/*_CHANNEL_PRIM_INST/RXOUTCLK}]] 6.400


set_max_delay -datapath_only -from [get_clocks dclk_clk] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */channel_inst/*_CHANNEL_PRIM_INST/TXOUTCLK}]] 8.000
set_max_delay -datapath_only -from [get_clocks dclk_clk] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */channel_inst/*_CHANNEL_PRIM_INST/RXOUTCLK}]] 8.000


set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */channel_inst/*_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks dclk_clk] 6.400
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */channel_inst/*_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks dclk_clk] 6.400