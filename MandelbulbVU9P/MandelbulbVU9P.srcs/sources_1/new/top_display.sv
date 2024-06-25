`timescale 1ns / 1ps

module top_display(
  input logic clk, // for now 100MHz clock
  input logic btnc, btnd, btnl, btnr, btnu, sw0, sw1
);

  logic pix_clk;  // pixel clock
  logic clk_lock;  // clock locked?

  // Display Timings
  logic signed [15:0] sx; // horizontal screen position (signed)
  logic signed [15:0] sy; // vertical screen position (signed)

  // 24 bit color --> output VGA or HDMI
  logic [7:0] red;
  logic [7:0] green;
  logic [7:0] blue;

  logic en_write_framebuffer;
  logic [5:0] framebuffer_data;
  logic [19:0] framebuffer_addr;

  /*test_card_drawToScreen #(
    .H_RES(1280), 
    .V_RES (720)
  ) 
  test_draw (
    .clk(CLK),
    .en_write_framebuffer(en_write_framebuffer),
    .framebuffer_data(framebuffer_data),
    .framebuffer_addr(framebuffer_addr)
  );*/
    
  ray_march raymarcher (
    .clk(clk), 
    .BTNC(btnc), 
    .BTNU(btnu), 
    .BTND(btnd), 
    .BTNR(btnr), 
    .BTNL(btnl), 
    .sw0(sw0),
    .sw1(sw1),
    .wea(en_write_framebuffer), 
    .mem_addr(framebuffer_addr),
    .rgb(framebuffer_data)
  );
    
  BRAM_to_HDMI # (
    .H_RES(1280), 
    .V_RES(720)
  ) 
  bth (
    .clk(clk),
    .pix_clk(pix_clk),
    .lock(!clk_lock),
    .i_x(sx),
    .i_y(sy),
    .en_write_framebuffer(en_write_framebuffer),
    .framebuffer_data(framebuffer_data),
    .framebuffer_addr(framebuffer_addr),
    .o_red(red),
    .o_green(green),
    .o_blue(blue)
  );

endmodule
