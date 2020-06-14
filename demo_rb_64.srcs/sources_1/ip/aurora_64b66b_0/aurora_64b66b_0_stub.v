// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Jun 12 14:14:19 2020
// Host        : DESKTOP-J26TQC9 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               g:/QH_WORK/Demo/vivado_prj/demo_rb_64/demo_rb_64/demo_rb_64.srcs/sources_1/ip/aurora_64b66b_0/aurora_64b66b_0_stub.v
// Design      : aurora_64b66b_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "aurora_64b66b_v11_2_6, Coregen v14.3_ip3, Number of lanes = 1, Line rate is double5.0Gbps, Reference Clock is double125.0MHz, Interface is Framing, Flow Control is None and is operating in DUPLEX configuration" *)
module aurora_64b66b_0(s_axi_tx_tdata, s_axi_tx_tlast, 
  s_axi_tx_tkeep, s_axi_tx_tvalid, s_axi_tx_tready, m_axi_rx_tdata, m_axi_rx_tlast, 
  m_axi_rx_tkeep, m_axi_rx_tvalid, rxp, rxn, txp, txn, gt_refclk1_p, gt_refclk1_n, gt_refclk1_out, 
  hard_err, soft_err, channel_up, lane_up, user_clk_out, mmcm_not_locked_out, sync_clk_out, 
  reset_pb, gt_rxcdrovrden_in, power_down, loopback, pma_init, gt_pll_lock, drp_clk_in, 
  drpaddr_in, drpdi_in, drpdo_out, drprdy_out, drpen_in, drpwe_in, init_clk, link_reset_out, 
  gt_qpllclk_quad2_out, gt_qpllrefclk_quad2_out, sys_reset_out, gt_reset_out, tx_out_clk)
/* synthesis syn_black_box black_box_pad_pin="s_axi_tx_tdata[63:0],s_axi_tx_tlast,s_axi_tx_tkeep[7:0],s_axi_tx_tvalid,s_axi_tx_tready,m_axi_rx_tdata[63:0],m_axi_rx_tlast,m_axi_rx_tkeep[7:0],m_axi_rx_tvalid,rxp[0:0],rxn[0:0],txp[0:0],txn[0:0],gt_refclk1_p,gt_refclk1_n,gt_refclk1_out,hard_err,soft_err,channel_up,lane_up[0:0],user_clk_out,mmcm_not_locked_out,sync_clk_out,reset_pb,gt_rxcdrovrden_in,power_down,loopback[2:0],pma_init,gt_pll_lock,drp_clk_in,drpaddr_in[8:0],drpdi_in[15:0],drpdo_out[15:0],drprdy_out,drpen_in,drpwe_in,init_clk,link_reset_out,gt_qpllclk_quad2_out,gt_qpllrefclk_quad2_out,sys_reset_out,gt_reset_out,tx_out_clk" */;
  input [63:0]s_axi_tx_tdata;
  input s_axi_tx_tlast;
  input [7:0]s_axi_tx_tkeep;
  input s_axi_tx_tvalid;
  output s_axi_tx_tready;
  output [63:0]m_axi_rx_tdata;
  output m_axi_rx_tlast;
  output [7:0]m_axi_rx_tkeep;
  output m_axi_rx_tvalid;
  input [0:0]rxp;
  input [0:0]rxn;
  output [0:0]txp;
  output [0:0]txn;
  input gt_refclk1_p;
  input gt_refclk1_n;
  output gt_refclk1_out;
  output hard_err;
  output soft_err;
  output channel_up;
  output [0:0]lane_up;
  output user_clk_out;
  output mmcm_not_locked_out;
  output sync_clk_out;
  input reset_pb;
  input gt_rxcdrovrden_in;
  input power_down;
  input [2:0]loopback;
  input pma_init;
  output gt_pll_lock;
  input drp_clk_in;
  input [8:0]drpaddr_in;
  input [15:0]drpdi_in;
  output [15:0]drpdo_out;
  output drprdy_out;
  input drpen_in;
  input drpwe_in;
  input init_clk;
  output link_reset_out;
  output gt_qpllclk_quad2_out;
  output gt_qpllrefclk_quad2_out;
  output sys_reset_out;
  output gt_reset_out;
  output tx_out_clk;
endmodule
