# System clocks
# 300 MHz
set_property -dict {PACKAGE_PIN G31  IOSTANDARD DIFF_SSTL12} [get_ports clk]
set_property -dict {PACKAGE_PIN F31  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_n]
create_clock -period 3.333 -name clk [get_ports clk]