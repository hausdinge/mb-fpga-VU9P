onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib clk_wiz_720p_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {clk_wiz_720p.udo}

run -all

quit -force
