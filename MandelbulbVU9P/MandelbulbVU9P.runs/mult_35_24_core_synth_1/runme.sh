#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/shares/nct-opt/software/xilinx/Vivado/2021.2/ids_lite/ISE/bin/lin64:/shares/nct-opt/software/xilinx/Vivado/2021.2/bin
else
  PATH=/shares/nct-opt/software/xilinx/Vivado/2021.2/ids_lite/ISE/bin/lin64:/shares/nct-opt/software/xilinx/Vivado/2021.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/shares/zitipoolhome/ol233/mb-fpga-VU9P/MandelbulbVU9P/MandelbulbVU9P.runs/mult_35_24_core_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log mult_35_24_core.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source mult_35_24_core.tcl