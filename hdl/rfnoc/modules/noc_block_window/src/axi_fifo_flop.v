//
// Copyright 2014 Ettus Research LLC
//


//
// Single FIFO (register) with AXI4-STREAM interface
//

module axi_fifo_flop
  #(parameter WIDTH=32)
   (input clk, 
    input reset, 
    input clear,
    input [WIDTH-1:0] i_tdata,
    input i_tvalid,
    output i_tready,
    output reg [WIDTH-1:0] o_tdata,
    output reg o_tvalid,
    input o_tready,
    output space,
    output occupied);

   assign i_tready = ~o_tvalid | o_tready;

   always @(posedge clk)
     if(reset | clear)
       o_tvalid <= 1'b0;
     else
       o_tvalid <= (i_tready & i_tvalid) | (o_tvalid & ~o_tready);

   always @(posedge clk)
     if(i_tvalid & i_tready)
       o_tdata <= i_tdata;

   // These aren't terribly useful, but include them for consistency
   assign space = i_tready;
   assign occupied = o_tvalid;
   
endmodule // axi_fifo_flop
