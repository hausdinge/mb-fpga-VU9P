// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.2 (lin64) Build 3367213 Tue Oct 19 02:47:39 MDT 2021
// Date        : Sat Sep 28 22:33:26 2024
// Host        : nct-epic running 64-bit Debian GNU/Linux 12 (bookworm)
// Command     : write_verilog -force -mode synth_stub
//               /shares/zitipoolhome/ol233/mb-fpga-VU9P/MandelbulbVU9P/MandelbulbVU9P.gen/sources_1/ip/clk_wiz_480p/clk_wiz_480p_stub.v
// Design      : clk_wiz_480p
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvu9p-flga2104-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_480p(clk_out_25MHz, clk_out_125MHz, locked, clk)
/* synthesis syn_black_box black_box_pad_pin="clk_out_25MHz,clk_out_125MHz,locked,clk" */;
  output clk_out_25MHz;
  output clk_out_125MHz;
  output locked;
  input clk;
endmodule
