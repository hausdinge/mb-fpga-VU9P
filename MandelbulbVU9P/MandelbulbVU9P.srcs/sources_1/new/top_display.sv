`timescale 1ns / 1ps

module top_display(
input logic clk, // for now 100MHz clock
input logic btnc, btnd, btnl, btnr, btnu, sw0, sw1,
output logic hdmi_tx_clk_n,      // HDMI clock differential negative
output logic hdmi_tx_clk_p,      // HDMI clock differential positive
output logic [2:0] hdmi_tx_n,    // Three HDMI channels differential negative
output logic [2:0] hdmi_tx_p     // Three HDMI channels differential positive
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

////////////////////////////////////////////////////////////////////////

  logic locked;

  logic pix_clk; // 25MHz (640x480) or 74.25 MHz (1280x720)
  logic clk_TMDS; // 250MHz (640x480) or 742.5 MHz (1280x720)
  
  logic [2:0] TMDSp, TMDSn;
  logic TMDSp_clock, TMDSn_clock;
  
  assign hdmi_tx_p = TMDSp;
  assign hdmi_tx_n = TMDSn;
  assign hdmi_tx_clk_p = TMDSp_clock;
  assign hdmi_tx_clk_n = TMDSn_clock;
  
  
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
  logic [23:0] pix_color;
  assign {red, green, blue} = pix_color;
  
////////////////////////////////////////////////////////////////////////

  // Draw something on the screen, simple test
  
  /*always_ff @(posedge pix_clk) begin
    if (x <= 400 && x >= 240 && y >= 200 && y <= 280) begin 
      pix_color <= 24'h0000ff;
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
  
  // Uncomment when 480p (640x480) is used, comment out if 720p (1280x720) is used
  /*clk_wiz_480p serial_and_pix_clk(
    .clk_out_25MHz(pix_clk),    
    .clk_out_250MHz(clk_TMDS),      
    .clk(clk),    
    .locked(locked)
  );*/
  
  // Uncomment when 720p (1280x720) is used, comment out if 480p (640x480) is used
  clk_wiz_720p serial_and_pix_clk(
    .clk_out_74MHz(pix_clk),     
    .clk_out_742MHz(clk_TMDS),     
    .clk(clk),
    .locked(locked)  
  );     

////////////////////////////////////////////////////////////////////////

  logic [3:0] TMDS_mod10 = 0;  // modulus 10 counter
  logic [9:0] TMDS_shift_red = 0, TMDS_shift_green = 0, TMDS_shift_blue = 0;
  logic TMDS_shift_load = 0;
  
  always_ff @(posedge clk_TMDS) begin
    TMDS_shift_load <= (TMDS_mod10==4'd9);
    TMDS_shift_red   <= TMDS_shift_load ? TMDS_red   : TMDS_shift_red  [9:1];
    TMDS_shift_green <= TMDS_shift_load ? TMDS_green : TMDS_shift_green[9:1];
    TMDS_shift_blue  <= TMDS_shift_load ? TMDS_blue  : TMDS_shift_blue [9:1];	
    TMDS_mod10 <= (TMDS_mod10==4'd9) ? 4'd0 : TMDS_mod10+4'd1;
  end
  
  OBUFDS OBUFDS_red  (.I(TMDS_shift_red  [0]), .O(TMDSp[2]), .OB(TMDSn[2]));
  OBUFDS OBUFDS_green(.I(TMDS_shift_green[0]), .O(TMDSp[1]), .OB(TMDSn[1]));
  OBUFDS OBUFDS_blue (.I(TMDS_shift_blue [0]), .O(TMDSp[0]), .OB(TMDSn[0]));
  OBUFDS OBUFDS_clock(.I(pix_clk), .O(TMDSp_clock), .OB(TMDSn_clock));
  
////////////////////////////////////////////////////////////////////////
  
  logic en_write_framebuffer;
  logic [5:0] framebuffer_data;
  logic [19:0] framebuffer_addr;
    
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

module TMDS_encoder(
input clk,
input [7:0] VD,  // video data (red, green or blue)
input [1:0] CD,  // control data
input VDE,       // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
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

////////////////////////////////////////////////////////////////////////

//module TMDS_encoder_8bit(
//	input logic clk,
//	input logic [7:0] VD,  // video data (red, green or blue)
//	input logic [1:0] CD,  // control data
//	input logic VDE,  // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
//	output logic [7:0] TMDS
//);

//  logic [3:0] Nb1s = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7];
//  logic XNOR = (Nb1s>4'd4) || (Nb1s==4'd4 && VD[0]==1'b0);
//  logic [7:0] q_m = VD[7:0] ^ {8{XNOR}};  // Simplified the q_m calculation to fit 8-bit
  
//  logic [7:0] TMDS_data = q_m;  // Directly assign q_m to TMDS_data
//  logic [7:0] TMDS_code = CD[1] ? (CD[0] ? 8'b10101011 : 8'b01010100) : (CD[0] ? 8'b00101011 : 8'b11010100);
  
//  always @(posedge clk) TMDS <= VDE ? TMDS_data : TMDS_code;

//endmodule

////////////////////////////////////////////////////////////////////////

// VCU118 has High-Speed I/O (HSIO) banks with GTY transceivers, which are high-speed differential I/Os.
// Use differential pairs for TMDS signals (which HDMI uses). These connections are done via PMOD or 
// FMC connectors on the board.

// TMDS Data0+ / Data0-: GTY transceiver pins (FMC_HPC_LA_0_P / FMC_HPC_LA_0_N)
// TMDS Data1+ / Data1-: GTY transceiver pins (FMC_HPC_LA_1_P / FMC_HPC_LA_1_N)
// TMDS Data2+ / Data2-: GTY transceiver pins (FMC_HPC_LA_2_P / FMC_HPC_LA_2_N)
// TMDS CLK+ / CLK-: GTY transceiver pins (FMC_HPC_LA_3_P / FMC_HPC_LA_3_N)