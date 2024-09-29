`timescale 1ns / 1ps


/*
This is the top module for displaying the Mandelbulb.
In order to display the Mandelbulb over HDMI, it was 
required to reduce the frequency of the output signal
from the HDMI-TMDS serializer. Instead of an output 
frequency of 10x the pix_clk, we have now an output
frequency of 5x the pix_clk by using double data rate 
(DDR) signals.

The output of this Module must be connected to some 
output pins of the FPGA and the output pins should
than be connected to some other device or circuid
that implements the TMDS_ODDR_converter module.
*/


module top_display(
input logic clk,                                      // 300 MHz
input logic btnc, btnd, btnl, btnr, btnu, sw0, sw1,   // Buttons to move the Mandelbulb
output logic o_pix_clk, o_pix_clk_5x,                 // Output clks needed for the TMDS_ODDR_converter module
output logic TMDS_shift_red0, TMDS_shift_red1,        // Splitted colore data -> only 5x the pix_clk. This data
output logic TMDS_shift_green0, TMDS_shift_green1,    // needs to be merged on the other device using TMDS_ODDR_converter module
output logic TMDS_shift_blue0, TMDS_shift_blue1       // or something else that implements an ODDR.
);
  
////////////////////////////////////////////////////////////////////////

                               // 640x480 1280x720
  localparam H_RES = 1280;     // 640     1280
  localparam V_RES = 720;      // 480     720
  
  localparam H_FP = 110;       // 16      110
  localparam H_SYNC = 40;      // 96      40
  localparam H_BP = 220;       // 48      220
  
  localparam V_FP = 5;         // 10      5
  localparam V_SYNC = 5;       // 2       5
  localparam V_BP = 20;        // 33      20
  
  // pix_clk (HD) = 1650x750x60 = 74.25 MHz
  // clk_TDMS = 5 x pix_clk = 371.25 MHz

////////////////////////////////////////////////////////////////////////

  logic clk_100MHz;

  logic locked;

  logic pix_clk;    // 25MHz or 74.25 MHz
  logic pix_clk_5x; // 125 MHz or 371.25 MHz
   
  logic [12:0] CounterX = 0, CounterY = 0, x, y;
  logic hSync, vSync, DrawArea;
  
  always_ff @(posedge pix_clk) begin
    DrawArea <= (CounterX<H_RES) && (CounterY<V_RES);
    CounterX <= (CounterX==H_RES+H_FP+H_SYNC+H_BP-1) ? 0 : CounterX+1;
    if(CounterX==H_RES+H_FP+H_SYNC+H_BP-1) CounterY <= (CounterY==V_RES+V_FP+V_SYNC+V_BP-1) ? 0 : CounterY+1;
    hSync <= (CounterX>=H_RES+H_FP) && (CounterX<H_RES+H_FP+H_SYNC); 
    vSync <= (CounterY>=V_RES+V_FP) && (CounterY<V_RES+V_FP+V_SYNC);
  end
  
  assign x = CounterX;
  assign y = CounterY;
  
  logic [7:0] red, green, blue;
  
////////////////////////////////////////////////////////////////////////

  // Draw something on the screen, simple test
  
  /*logic [23:0] pix_color;
  assign {red, green, blue} = pix_color;
  
  always_ff @(posedge pix_clk) begin
    if (x <= 400 && x >= 240 && y >= 200 && y <= 280) begin 
      pix_color <= 24'h999999;
    end else begin
      pix_color <= 24'h000000;
    end
  end*/

////////////////////////////////////////////////////////////////////////

  logic [9:0] TMDS_red, TMDS_green, TMDS_blue;
  TMDS_encoder encode_R(.clk(pix_clk), .VD(red  ), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_red));
  TMDS_encoder encode_G(.clk(pix_clk), .VD(green), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_green));
  TMDS_encoder encode_B(.clk(pix_clk), .VD(blue ), .CD({vSync,hSync}), .VDE(DrawArea), .TMDS(TMDS_blue));

////////////////////////////////////////////////////////////////////////
  
  // Uncomment when 480p is used, comment out if 720p is used
  /*clk_wiz_480p serial_and_pix_clk(
    .clk_out_25MHz(pix_clk),    
    .clk_out_125MHz(pix_clk_5x),
    .clk_out_100MHz(clk_100MHz),      
    .clk(clk),    
    .locked(locked)
  );*/
  
  // Uncomment when 720p is used, comment out if 480p is used
  clk_wiz_720p serial_and_pix_clks(
    .clk_out_74_25MHz(pix_clk),     
    .clk_out_371_25MHz(pix_clk_5x), 
    .clk_out_100MHz(clk_100MHz),    
    .clk(clk),
    .locked(locked)  
  );
////////////////////////////////////////////////////////////////////////

  // In this section the TMDS serializer with a 5x pix_clk frequency is implemented instead of 10x the pix_clk.
  // The basic idea is that we serialize the every even and odd bit of the TMDS data seperately in the 
  // falling and rising edge og the pix_clk_5x. Later the output of this module needs to be merged with for 
  // example an oddr module (or the TMDS_ODDR_converter) to get a 10x pix_clk freq for HDMI input.

  logic [2:0] TMDS_mod5 [0:1] = '{default:0};  // modulus 5 counter
  logic [9:0] TMDS_shift_red [0:2] = '{default:0}, TMDS_shift_green [0:2] = '{default:0}, TMDS_shift_blue [0:2] = '{default:0};
  logic [1:0] TMDS_shift_load = 0;
  
  logic [1:0] shift_odd [0:4] = {1,2,2,2,2};
  logic [9:0] TMDS_red_next, TMDS_green_next, TMDS_blue_next;
  
  // serialize every odd bit
  always_ff @(posedge pix_clk_5x) begin
    TMDS_shift_load[0] <= (TMDS_mod5[0]==3'd4);
    TMDS_shift_red[0]   <= TMDS_shift_load[0] ? TMDS_red   : (TMDS_shift_red[0]  >> shift_odd[TMDS_mod5[0]]);
    TMDS_shift_green[0] <= TMDS_shift_load[0] ? TMDS_green : (TMDS_shift_green[0] >> shift_odd[TMDS_mod5[0]]);
    TMDS_shift_blue[0]  <= TMDS_shift_load[0] ? TMDS_blue  : (TMDS_shift_blue[0] >> shift_odd[TMDS_mod5[0]]);	
    TMDS_mod5[0] <= (TMDS_mod5[0]==3'd4) ? 3'd0 : TMDS_mod5[0]+3'd1;
    
    TMDS_red_next <= TMDS_red;
    TMDS_green_next <= TMDS_green;
    TMDS_blue_next <= TMDS_blue;
  end
  
  // serialize every even bit
  always_ff @(negedge pix_clk_5x) begin
    TMDS_shift_load[1] <= (TMDS_mod5[1]==3'd4);
    TMDS_shift_red[1]   <= TMDS_shift_load[1] ? TMDS_red_next   : (TMDS_shift_red[0]  >> 1);
    TMDS_shift_green[1] <= TMDS_shift_load[1] ? TMDS_green_next : (TMDS_shift_green[0] >> 1);
    TMDS_shift_blue[1]  <= TMDS_shift_load[1] ? TMDS_blue_next  : (TMDS_shift_blue[0] >> 1);	
    TMDS_mod5[1] <= (TMDS_mod5[1]==3'd4) ? 3'd0 : TMDS_mod5[1]+3'd1;
  end
  
  // output all data
  OBUF hdmi_pix_clk (.I(pix_clk), .O(o_pix_clk));
  OBUF hdmi_serial_clk (.I(pix_clk_5x), .O(o_pix_clk_5x));
  
  assign TMDS_shift_red0   = TMDS_shift_red[0][0]; 
  assign TMDS_shift_red1   = TMDS_shift_red[1][0];    
  assign TMDS_shift_green0 = TMDS_shift_green[0][0];
  assign TMDS_shift_green1 = TMDS_shift_green[1][0];
  assign TMDS_shift_blue0  = TMDS_shift_blue[0][0]; 
  assign TMDS_shift_blue1  = TMDS_shift_blue[1][0];  
  
  // Example instance
  /*TMDS_ODDR_converter toc (
    .pix_clk(pix_clk),
    .pix_clk_5x(pix_clk_5x),
    .TMDS_shift_red0(TMDS_shift_red[0][0]), 
    .TMDS_shift_red1(TMDS_shift_red[1][0]),     
    .TMDS_shift_green0(TMDS_shift_green[0][0]), 
    .TMDS_shift_green1(TMDS_shift_green[1][0]), 
    .TMDS_shift_blue0(TMDS_shift_blue[0][0]), 
    .TMDS_shift_blue1(TMDS_shift_blue[1][0]),   
    .TMDSp(TMDSp),
    .TMDSn(TMDSn),
    .TMDSp_clock(TMDSp_clock),
    .TMDSn_clock(TMDSn_clock)                      
  );*/
  
////////////////////////////////////////////////////////////////////////
  
  logic en_write_framebuffer;
  logic [5:0] framebuffer_data;
  logic [19:0] framebuffer_addr;
    
  ray_march raymarcher (
    .clk(clk_100MHz), 
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
    .clk(clk_100MHz),
    .pix_clk(pix_clk),
    .lock(!locked),
    .i_x(x),
    .i_y(y),
    .en_write_framebuffer(en_write_framebuffer),
    .framebuffer_data(framebuffer_data),
    .framebuffer_addr(framebuffer_addr),
    .o_red(red),
    .o_green(green),
    .o_blue(blue)
  );
endmodule

////////////////////////////////////////////////////////////////////////

// This module could be implemented on an other device receiving the Data
// from the VU9P and converts it back to an valid HDMI signal
module TMDS_ODDR_converter (
input logic pix_clk, pix_clk_5x,
input logic TMDS_shift_red0, TMDS_shift_red1,
input logic TMDS_shift_green0, TMDS_shift_green1,
input logic TMDS_shift_blue0, TMDS_shift_blue1,
output logic [2:0] TMDSp, TMDSn,
output logic TMDSp_clock, TMDSn_clock
);

  logic TMDS_shift_red, TMDS_shift_green, TMDS_shift_blue;

  ODDR #(
    .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
    .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
     ) ODDR_inst_red (
    .Q(TMDS_shift_red),   // 1-bit DDR output
    .C(pix_clk_5x),   // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D1(TMDS_shift_red0), // 1-bit data input (positive edge)
    .D2(TMDS_shift_red1), // 1-bit data input (negative edge)
    .R(1'b0),   // 1-bit reset
    .S(1'b0)    // 1-bit set
  );
  
  ODDR #(
    .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
    .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
     ) ODDR_inst_gren (
    .Q(TMDS_shift_green),   // 1-bit DDR output
    .C(pix_clk_5x),   // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D1(TMDS_shift_green0), // 1-bit data input (positive edge)
    .D2(TMDS_shift_green1), // 1-bit data input (negative edge)
    .R(1'b0),   // 1-bit reset
    .S(1'b0)    // 1-bit set
  );
  
  ODDR #(
    .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
    .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
     ) ODDR_inst_blue (
    .Q(TMDS_shift_blue),   // 1-bit DDR output
    .C(pix_clk_5x),   // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D1(TMDS_shift_blue0), // 1-bit data input (positive edge)
    .D2(TMDS_shift_blue1), // 1-bit data input (negative edge)
    .R(1'b0),   // 1-bit reset
    .S(1'b0)    // 1-bit set
  );
  
  OBUFDS OBUFDS_red  (.I(TMDS_shift_red), .O(TMDSp[2]), .OB(TMDSn[2]));
  OBUFDS OBUFDS_green(.I(TMDS_shift_green), .O(TMDSp[1]), .OB(TMDSn[1]));
  OBUFDS OBUFDS_blue (.I(TMDS_shift_blue), .O(TMDSp[0]), .OB(TMDSn[0]));
  OBUFDS OBUFDS_clock(.I(pix_clk), .O(TMDSp_clock), .OB(TMDSn_clock));
endmodule


module TMDS_encoder(
input logic clk,
input logic [7:0] VD,  // video data (red, green or blue)
input logic [1:0] CD,  // control data
input logic VDE,       // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
output logic [9:0] TMDS
);

  logic [3:0] Nb1s, balance_acc = 0, balance, balance_acc_inc, balance_acc_new;
  logic XNOR, balance_sign_eq, invert_q_m;
  logic [8:0] q_m;
  logic [9:0] TMDS_data, TMDS_code;

  always_comb begin
    Nb1s = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7];
    XNOR = (Nb1s>4'd4) || (Nb1s==4'd4 && VD[0]==1'b0);
    q_m = {~XNOR, q_m[6:0] ^ VD[7:1] ^ {7{XNOR}}, VD[0]};
    
    balance = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4;
    balance_sign_eq = (balance[3] == balance_acc[3]);
    invert_q_m = (balance==0 || balance_acc==0) ? ~q_m[8] : balance_sign_eq;
    balance_acc_inc = balance - ({q_m[8] ^ ~balance_sign_eq} & ~(balance==0 || balance_acc==0));
    balance_acc_new = invert_q_m ? balance_acc-balance_acc_inc : balance_acc+balance_acc_inc;
    TMDS_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};
    TMDS_code = CD[1] ? (CD[0] ? 10'b1010101011 : 10'b0101010100) : (CD[0] ? 10'b0010101011 : 10'b1101010100);
  end

  always_ff @(posedge clk) begin
    TMDS <= VDE ? TMDS_data : TMDS_code;
    balance_acc <= VDE ? balance_acc_new : 4'h0;
  end
endmodule