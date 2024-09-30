# mb-fpga-VU9P

This project implements the Mandelbulb on the AMD Virtex UltraScale+ FPGA (XCVU9P) VCU118. It works almost the same as our other project implemented on the Nexys Video: 

https://github.com/hausdinge/mb-fpga/tree/main

On this board it is possible to utilize 10x more LUTs and FFs compared to the FPGA on the Nexys Video Board. So we think that we can get a performace (fps) bost of a factor of 10 to 15 (we still try some things out).

## Display output

Unlike the Nexys Video, the VCU118 does not have a dedicated HDMI output, requiring us to find an alternative method to transmit data. To send an HD (1280x720) image from the FPGA to an HDMI port, we first need to encode each 8-bit color value into a 10-bit TMDS signal, which operates at a pixel clock frequency (`pix_clk`) of 74.25 MHz. This signal must then be serialized at 10 times the `pix_clk` frequency, reaching 742.5 MHz. 

However, most pins on the VCU118 cannot handle such a high frequency, so we reduced the serialization frequency using double data rate (DDR) signaling. With DDR, we successfully lowered the serialization frequency to 371.25 MHz. The diagram below illustrates how this process was implemented:

![img-TMDS-Serializer](https://raw.githubusercontent.com/hausdinge/mb-fpga-VU9P/refs/heads/main/assets/serializer.svg)

> The diagram above is an overview of this [code-block]( https://github.com/hausdinge/mb-fpga-VU9P/blob/main/MandelbulbVU9P/MandelbulbVU9P.srcs/sources_1/new/top_display.sv), line 119-146.

The basic idea is to serialize every even and odd bit of the TMDS data separately on the falling and rising edges of the `pix_clk_5x`. Later, the output of this module needs to be merged, for example, using an ODDR module (or the TMDS_ODDR_converter) to achieve the 10x `pix_clk` frequency required for HDMI input.

The design of the TDMS-Encoder is from:

https://www.fpga4fun.com/HDMI.html

Good candidates for output pins on this board include some pins from the PCIe interface, UART, or the GTY transceivers. The VCU118 has High-Speed I/O (HSIO) banks with GTY transceivers, which are high-speed differential I/Os. Currently, we are using the PMOD pins (only for testing), but this will need to be changed in the future.

Now that we can transmit data from the FPGA using only `pix_clk_5x`, we also need to receive the data and convert it back into a valid HDMI signal. This conversion can be handled by a simple circuit or another FPGA. In the following section, we will describe a design for another (Xilinx) FPGA with HDMI output:

![img-TMDS-ODDR-Converter](https://raw.githubusercontent.com/hausdinge/mb-fpga-VU9P/refs/heads/main/assets/toc.svg)

> The diagram above is an overview of this [code-block]( https://github.com/hausdinge/mb-fpga-VU9P/blob/main/MandelbulbVU9P/MandelbulbVU9P.srcs/sources_1/new/top_display.sv), line 218-275.

The TMDS serializer splits the color data into `TMDS_shift_<r|g|b>_<0|1>`, allowing each bit to be sent with `pix_clk_5x`. To generate an `pix_clk_10x` HDMI signal, we need to merge each color channel, for example:

`TMDS_shift_red0 + TMDS_shift_red1 --> TMDS_shift_red`

In a Xilinx FPGA, we can use the ODDR primitive to combine serialized data generated on both the rising and falling clock edges. This effectively doubles the output frequency of the color data, as two data lanes operating at `pix_clk_5x` are combined into one data lane.

For a valid HDMI signal, we also need differential channels for both the `pix_clk` and the color data. This can be achieved using the OBUFDS primitive.

And that's it! For a simple standalone example on the Nexys Video, see the following link to our project:

https://github.com/hausdinge/fpga-simple-hdmi

In this example, a basic texture is drawn onto the screen.