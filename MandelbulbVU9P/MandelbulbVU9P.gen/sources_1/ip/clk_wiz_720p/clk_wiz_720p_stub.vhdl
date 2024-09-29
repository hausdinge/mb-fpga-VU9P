-- Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2021.2 (lin64) Build 3367213 Tue Oct 19 02:47:39 MDT 2021
-- Date        : Sun Sep 29 04:15:02 2024
-- Host        : nct-epic running 64-bit Debian GNU/Linux 12 (bookworm)
-- Command     : write_vhdl -force -mode synth_stub
--               /shares/zitipoolhome/ol233/mb-fpga-VU9P/MandelbulbVU9P/MandelbulbVU9P.gen/sources_1/ip/clk_wiz_720p/clk_wiz_720p_stub.vhdl
-- Design      : clk_wiz_720p
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcvu9p-flga2104-2L-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_wiz_720p is
  Port ( 
    clk_out_74_25MHz : out STD_LOGIC;
    clk_out_371_25MHz : out STD_LOGIC;
    clk_out_100MHz : out STD_LOGIC;
    locked : out STD_LOGIC;
    clk : in STD_LOGIC
  );

end clk_wiz_720p;

architecture stub of clk_wiz_720p is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out_74_25MHz,clk_out_371_25MHz,clk_out_100MHz,locked,clk";
begin
end;
