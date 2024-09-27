-makelib xcelium_lib/xpm -sv \
  "/shares/nct-opt/software/xilinx/Vivado/2021.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/shares/nct-opt/software/xilinx/Vivado/2021.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "/shares/nct-opt/software/xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../MandelbulbVU9P.gen/sources_1/ip/clk_wiz_480p/clk_wiz_480p_clk_wiz.v" \
  "../../../../MandelbulbVU9P.gen/sources_1/ip/clk_wiz_480p/clk_wiz_480p.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

