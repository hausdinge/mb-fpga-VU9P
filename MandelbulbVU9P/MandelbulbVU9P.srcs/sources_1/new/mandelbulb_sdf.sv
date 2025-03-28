`timescale 1ns / 1ps

// latency: 815 clock cycles
module mandelbulb_sdf (
input logic in_valid, 
input logic clk, 
input fixedpoint::message data_in, 
output fixedpoint::message data_out, 
output logic out_valid
);
  
  // specify here the mandelbulb iteration count
  localparam iter = 4;

  // num latency + 1 of distance_estimator
  localparam delay = 56;
  
  fixedpoint::message msg_out[iter-1:0];
  fixedpoint::message res [0:delay-1];
  
  logic [iter:0] valid;
  logic end_valid;
  
  fixedpoint::number logdist;
  
  // specify the number of pipelined Mandelbulb SDF iterations.
  mb_sdf_iteration msdi_init (in_valid, clk, data_in, msg_out[0], valid[0]);

  genvar i;
  generate
    for (i = 0; i < iter-1; i = i + 1) begin : gen_block
      mb_sdf_iteration msdi (valid[i], clk, msg_out[i], msg_out[i + 1], valid[i + 1]);
    end
  endgenerate

  mb_log_dist ld (valid[iter - 1], clk, msg_out[iter - 1].r, msg_out[iter - 1].dr, logdist, valid[iter]);
  
  always_ff @(posedge clk) begin
    if(valid[iter - 1]) begin
      res[0] <= msg_out[iter - 1];
      for(int i = 0; i < delay - 2; i++) begin
        res[i+1] <= res[i];
      end
    end
    if(valid[iter]) begin
      res[delay-1].pos_x <= res[delay-2].pos_x;
      res[delay-1].pos_y <=  res[delay-2].pos_y;
      res[delay-1].pos_z <= res[delay-2].pos_z;
        
      res[delay-1].x_iter <= res[delay-2].x_iter;
      res[delay-1].y_iter <= res[delay-2].y_iter;
      res[delay-1].z_iter <= res[delay-2].z_iter;
        
      res[delay-1].steps <= res[delay-2].steps;
      res[delay-1].r <= res[delay-2].r;
      res[delay-1].dr <= res[delay-2].dr;
      res[delay-1].zr <= res[delay-2].zr;
        
      res[delay-1].theta <= res[delay-2].theta;
      res[delay-1].phi <= res[delay-2].phi;
        
      res[delay-1].mem_addr <= res[delay-2].mem_addr;
      res[delay-1].march_iter <= res[delay-2].march_iter;
      res[delay-1].march_depth <= res[delay-2].march_depth;
        
      res[delay-1].rayd_x <= res[delay-2].rayd_x;
      res[delay-1].rayd_y <= res[delay-2].rayd_y;
      res[delay-1].rayd_z <= res[delay-2].rayd_z;
        
      res[delay-1].logdist <= logdist;
      res[delay-1].epsilon <= res[delay-2].epsilon;
      res[delay-1].mb_iter <= res[delay-2].mb_iter;
        
      res[delay-1].threshold <= res[delay-2].threshold;
      
      end_valid <= 1'b1;
    end
  end
  
  always_comb begin
    data_out = '{default:0};
    out_valid = 1'b0;
    if(end_valid) begin
      data_out = res[delay-1];
      out_valid = 1'b1;
    end
  end 
endmodule












