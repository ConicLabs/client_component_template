//
// Copyright 2014 Ettus Research LLC
//
(*KEEP_HIERARCHY = "TRUE"*)
module noc_block_axi_fifo_loopback_reg #(
  parameter NOC_ID = 64'hF1F0_0000_0000_0000,
  parameter STR_SINK_FIFOSIZE = 11)
(
  input bus_clk, input bus_rst,
  input ce_clk, input ce_rst,
  input  [63:0] i_tdata, input  i_tlast, input  i_tvalid, 
  output i_tready,
  output [63:0] o_tdata, output o_tlast, output o_tvalid, 
  input  o_tready,
  output [63:0] debug
);

  //making things registered because
wire [63:0] i_tdata_reg;
wire [63:0] o_tdata_unreg;
wire i_tlast_reg;
wire i_tvalid_reg;
wire i_tready_unreg;
wire o_tlast_unreg;
wire o_tvalid_unreg;
wire o_tready_reg;

greasy_mod greasy_mod_in(
.clk(bus_clk), 
.rst(bus_rst),
.i_valid(i_tvalid),
.i_last(i_tlast),
.i_data(i_tdata),
.i_ready(i_tready),
.o_valid(i_tvalid_reg),
.o_last(i_tlast_reg),
.o_data(i_tdata_reg),
.o_ready(i_tready_reg)
);

greasy_mod greasy_mod_out(
.clk(bus_clk), 
.rst(bus_rst),
.i_valid(o_tvalid_unreg),
.i_last(o_tlast_unreg),
.i_data(o_tdata_unreg),
.i_ready(o_tready_unreg),
.o_valid(o_tvalid),
.o_last(o_tlast),
.o_data(o_tdata),
.o_ready(o_tready)
);


  ////////////////////////////////////////////////////////////
  //
  // RFNoC Shell
  //
  ////////////////////////////////////////////////////////////
  wire [31:0] set_data;
  wire [7:0]  set_addr;
  wire        set_stb;

  wire [63:0] cmdout_tdata, ackin_tdata;
  wire        cmdout_tlast, cmdout_tvalid, cmdout_tready, ackin_tlast, ackin_tvalid, ackin_tready;

  wire [63:0] str_sink_tdata, str_src_tdata;
  wire        str_sink_tlast, str_sink_tvalid, str_sink_tready, str_src_tlast, str_src_tvalid, str_src_tready;

  noc_shell #(
    .NOC_ID(NOC_ID),
    .STR_SINK_FIFOSIZE(STR_SINK_FIFOSIZE))
  inst_noc_shell (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .i_tdata(i_tdata_reg), .i_tlast(i_tlast_reg), .i_tvalid(i_tvalid_reg), .i_tready(i_tready_reg),
    .o_tdata(o_tdata_unreg), .o_tlast(o_tlast_unreg), .o_tvalid(o_tvalid_unreg), .o_tready(o_tready_unreg),
    // Computer Engine Clock Domain
    .clk(ce_clk), .reset(ce_rst),
    // Control Sink
    .set_data(set_data), .set_addr(set_addr), .set_stb(set_stb), .rb_data(64'd0),
    // Control Source
    .cmdout_tdata(cmdout_tdata), .cmdout_tlast(cmdout_tlast), .cmdout_tvalid(cmdout_tvalid), .cmdout_tready(cmdout_tready),
    .ackin_tdata(ackin_tdata), .ackin_tlast(ackin_tlast), .ackin_tvalid(ackin_tvalid), .ackin_tready(ackin_tready),
    // Stream Sink
    .str_sink_tdata(str_sink_tdata), .str_sink_tlast(str_sink_tlast), .str_sink_tvalid(str_sink_tvalid), .str_sink_tready(str_sink_tready),
    // Stream Source
    .str_src_tdata(str_src_tdata), .str_src_tlast(str_src_tlast), .str_src_tvalid(str_src_tvalid), .str_src_tready(str_src_tready),
    .debug(debug));

  ////////////////////////////////////////////////////////////
  //
  // AXI Wrapper
  // Convert RFNoC Shell interface into AXI stream interface
  //
  ////////////////////////////////////////////////////////////
  wire [31:0] m_axis_data_tdata;
  wire        m_axis_data_tlast;
  wire        m_axis_data_tvalid;
  wire        m_axis_data_tready;
  
  wire [31:0] s_axis_data_tdata;
  wire        s_axis_data_tlast;
  wire        s_axis_data_tvalid;
  wire        s_axis_data_tready;

  localparam AXI_WRAPPER_BASE    = 128;
  localparam SR_NEXT_DST         = AXI_WRAPPER_BASE;
  localparam SR_AXI_CONFIG_BASE  = AXI_WRAPPER_BASE + 1;

  axi_wrapper #(
    .SR_NEXT_DST(SR_NEXT_DST),
    .SR_AXI_CONFIG_BASE(SR_AXI_CONFIG_BASE))
  inst_axi_wrapper (
    .clk(ce_clk), .reset(ce_rst),
    .set_stb(set_stb), .set_addr(set_addr), .set_data(set_data),
    .i_tdata(str_sink_tdata), .i_tlast(str_sink_tlast), .i_tvalid(str_sink_tvalid), .i_tready(str_sink_tready),
    .o_tdata(str_src_tdata), .o_tlast(str_src_tlast), .o_tvalid(str_src_tvalid), .o_tready(str_src_tready),
    .m_axis_data_tdata(m_axis_data_tdata),
    .m_axis_data_tlast(m_axis_data_tlast),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tready(m_axis_data_tready),
    .s_axis_data_tdata(s_axis_data_tdata),
    .s_axis_data_tlast(s_axis_data_tlast),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tready(s_axis_data_tready),
    .m_axis_config_tdata(),
    .m_axis_config_tlast(),
    .m_axis_config_tvalid(), 
    .m_axis_config_tready());

  ////////////////////////////////////////////////////////////
  //
  // User code
  //
  ////////////////////////////////////////////////////////////

  // Control Source Unused
  assign cmdout_tdata = 64'd0;
  assign cmdout_tlast = 1'b0;
  assign cmdout_tvalid = 1'b0;
  assign ackin_tready = 1'b1;

  axi_fifo #(
    .WIDTH(33), .SIZE(2))
  inst_axi_fifo (
    .clk(ce_clk), .reset(ce_rst), .clear(1'b0),
    .i_tdata({m_axis_data_tlast,m_axis_data_tdata}), .i_tvalid(m_axis_data_tvalid), .i_tready(m_axis_data_tready),
    .o_tdata({s_axis_data_tlast,s_axis_data_tdata}), .o_tvalid(s_axis_data_tvalid), .o_tready(s_axis_data_tready),
    .space(), .occupied());

endmodule
