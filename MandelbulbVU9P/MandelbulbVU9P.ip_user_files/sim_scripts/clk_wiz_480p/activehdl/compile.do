vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../ipstatic" \
"/shares/nct-opt/software/xilinx/Vivado/2021.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/shares/nct-opt/software/xilinx/Vivado/2021.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/shares/nct-opt/software/xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" \
"../../../../MandelbulbVU9P.gen/sources_1/ip/clk_wiz_480p/clk_wiz_480p_clk_wiz.v" \
"../../../../MandelbulbVU9P.gen/sources_1/ip/clk_wiz_480p/clk_wiz_480p.v" \

vlog -work xil_defaultlib \
"glbl.v"

