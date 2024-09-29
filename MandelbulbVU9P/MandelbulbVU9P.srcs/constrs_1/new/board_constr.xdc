# System clocks
# 300 MHz
set_property -dict {PACKAGE_PIN G31  IOSTANDARD DIFF_SSTL12} [get_ports clk]
set_property -dict {PACKAGE_PIN F31  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_n]
create_clock -period 3.333 -name clk [get_ports clk]

# Push buttons
set_property -dict {PACKAGE_PIN BB24 IOSTANDARD LVCMOS18} [get_ports btnu]
set_property -dict {PACKAGE_PIN BF22 IOSTANDARD LVCMOS18} [get_ports btnl]
set_property -dict {PACKAGE_PIN BE22 IOSTANDARD LVCMOS18} [get_ports btnd]
set_property -dict {PACKAGE_PIN BE23 IOSTANDARD LVCMOS18} [get_ports btnr]
set_property -dict {PACKAGE_PIN BD23 IOSTANDARD LVCMOS18} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# DIP switches
set_property -dict {PACKAGE_PIN B17  IOSTANDARD LVCMOS12} [get_ports {sw0}]
set_property -dict {PACKAGE_PIN G16  IOSTANDARD LVCMOS12} [get_ports {sw1}]

set_false_path -from [get_ports {sw0 sw1}]
set_input_delay 0 [get_ports {sw0 sw1}]

# PMOD0
# (dummy pins) This should be changed. PMOD0 is not suited for highspeed data
# We have some ideas which pins are suited like some pins of the PCIe or UART or the GTY Transceivers
set_property -dict {PACKAGE_PIN AY14 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {o_pix_clk}]
set_property -dict {PACKAGE_PIN AY15 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {o_pix_clk_5x}]
set_property -dict {PACKAGE_PIN AW15 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {TMDS_shift_red0}]
set_property -dict {PACKAGE_PIN AV15 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {TMDS_shift_red1}]
set_property -dict {PACKAGE_PIN AV16 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {TMDS_shift_green0}]
set_property -dict {PACKAGE_PIN AU16 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {TMDS_shift_green1}]
set_property -dict {PACKAGE_PIN AT15 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {TMDS_shift_blue0}]
set_property -dict {PACKAGE_PIN AT16 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {TMDS_shift_blue1}]