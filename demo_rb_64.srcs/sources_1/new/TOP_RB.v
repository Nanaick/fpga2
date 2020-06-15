`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/12 14:14:00
// Design Name: 
// Module Name: TOP_RB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TOP_RB(
	input		wire 	sys_clk_p,
	input		wire 	sys_clk_n,
	
	input		wire	reset,
	
	input		wire	GTXQ_P,
	input		wire	GTXQ_N,

	input		wire 	RXP,
	input		wire 	RXN,

	output		wire 	TXP,
	output		wire 	TXN,

	output 		wire [1:0] sfp_dis
    );


 wire 	   sys_clk_100m;
 wire 	   drp_clk_100m;
 
 wire 	   sys_rst;
 
 wire 	   user_clk_out; // 5G 66bit 75M
 wire 	   sys_reset_out;
 
 (* mark_debug = "1" *)wire	   channel_up;
 (* mark_debug = "1" *)wire	   lane_up;

 reg       ap_start;

 reg       Rx_flage;
 reg 	   tx_flag;

 reg   	   Rx_flage_reg;

 wire 	   sys_clk_i;

 reg    [7:0]  STAT;

 reg 	[7:0]  sd_state;
 reg    [7:0]  rd_state;

 reg    [15:0]  Tx_Cnt;
 reg    [15:0]  Rx_Cnt;

 reg    [15:0]  send_len;
 reg    [15:0]  read_len;

 reg    [31:0] wait_cnt;
 
 reg    [15:0] chnnal;

 reg    [63:0] parity;   //校验
 reg    [63:0] Rx_data_temp;
 reg    [63:0] rx_parity;

 reg [31:0] idataInCtrl[3:0];
 reg [31:0] fdataInCtrl[3:0];

 reg [63:0] DATA_OUT[31:0];
 reg [63:0] DATA_IN [31:0];

 assign  sys_clk_100m = sys_clk_i;
 assign  drp_clk_100m = sys_clk_i;
 
 assign  sys_rst = ~reset;

 assign  sfp_dis = 2'b00; 
 
 reg	[63: 0]	s_axi_tx_tdata ;
 reg	[ 7: 0]	s_axi_tx_tkeep ;
 reg			s_axi_tx_tlast ;
 reg			s_axi_tx_tvalid;
 wire			s_axi_tx_tready;
 

wire   [63: 0] m_axi_rx_tdata ;
wire   [ 7: 0] m_axi_rx_tkeep ;
wire    	   m_axi_rx_tlast ;
wire    	   m_axi_rx_tvalid;


 IBUFDS #(
   .DIFF_TERM("FALSE"),       // Differential Termination
   .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
   .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
 ) IBUFDS_inst (
   .O (sys_clk_i  ),  // Buffer output
   .I (sys_clk_p),  // Diff_p buffer input (connect directly to top-level port)
   .IB(sys_clk_n)   // Diff_n buffer input (connect directly to top-level port)
);



//数据接收端
always @(posedge user_clk_out or posedge sys_reset_out) begin
	if (sys_reset_out) begin
		Rx_data_temp  <= 64'd0;
		Rx_flage_reg  <= 1'b0;
	end else begin
		Rx_data_temp  <= m_axi_rx_tdata; 
		Rx_flage_reg  <= Rx_flage;    
	end
end

always @(posedge user_clk_out or posedge sys_reset_out) begin
	if (sys_reset_out) begin
		// reset
		rd_state  	<= 8'h01;
		Rx_Cnt		<= 16'd0;
		rx_parity	<= 64'd0;
		read_len	<= 16'd0;
		chnnal		<= 16'd0;
		Rx_flage	<= 1'b0;
	end else begin
		case(rd_state) 
			8'h01 : begin
				if(m_axi_rx_tvalid && (Rx_data_temp[63:48] == 16'haa55)) begin
					rx_parity			<= Rx_data_temp;
					chnnal				<= Rx_data_temp[47:32];
					read_len			<= Rx_data_temp[15: 0];
					rd_state 			<= 8'h02;
				end else begin
					rx_parity 			<= 64'd0;
					rd_state 			<= 8'h01;
				end
				Rx_Cnt					<= 16'd0;
				Rx_flage 				<= 1'b0;
			end
			8'h02 : begin
				if(m_axi_rx_tvalid) begin
					DATA_IN[Rx_Cnt]		<= Rx_data_temp;
					Rx_Cnt				<= Rx_Cnt + 1'b1;
					rx_parity 			<= rx_parity ^ Rx_data_temp;
					rd_state 			<= 8'h03;
				end else begin
					rd_state 			<= 8'h02;
				end
			end
			8'h03 : begin
				if(Rx_Cnt == read_len || (Rx_Cnt > 16'd200)) begin
					rd_state 			<= 8'h04;
				end else begin
					rd_state 			<= 8'h02;
				end
			end
			8'h4 : begin
				if(m_axi_rx_tlast && (Rx_data_temp == rx_parity)) begin
					rd_state 			<= 8'h05;
					Rx_flage 			<= 1'b1;
				end else begin
					rd_state 			<= 8'h05;
				end
			end
			8'h5 : begin
				rd_state 			<= 8'h01;
			end
			default : rd_state 			<= 8'h01;
		endcase
	end
end

 always @(posedge user_clk_out or posedge sys_reset_out) begin
	if (sys_reset_out) begin
		STAT 		<= 8'd1;
		ap_start	<= 1'b0;
	end else begin
		case(STAT)
			8'd1 : begin
			 	ap_start	<= 1'b0;
				if({Rx_flage_reg,Rx_flage} == 2'b01) begin
					STAT 		<= 8'd2;
				end else begin
					STAT 		<= 8'd1;
				end
			end
			8'd2 : begin
				STAT 		<= 8'd3;
				if(chnnal == 16'h000a) begin
					{idataInCtrl[0],idataInCtrl[1]} <= DATA_IN[0];
					{idataInCtrl[2],idataInCtrl[3]} <= DATA_IN[1];
				end else if(chnnal == 16'h000b)begin
					{fdataInCtrl[0],fdataInCtrl[1]} <= DATA_IN[0];
					{fdataInCtrl[2],fdataInCtrl[3]} <= DATA_IN[1];
				end else begin
					;
				end
			end
			8'd3 : begin
				STAT 		<= 8'd1;
				ap_start	<= 1'b1;
			end
			default : begin
				STAT 		<= 8'd1;
			end
		endcase
	end
end

/*
aurora_64b66b_0 aurora_64b66b_rb (
  .rxp(RXP),                                          // input wire [0 : 0] rxp
  .rxn(RXN),                                          // input wire [0 : 0] rxn
  .reset_pb(sys_rst),                                // input wire reset_pb
  .power_down(1'b0),                            // input wire power_down
  .pma_init(1'b0),                                // input wire pma_init
  .loopback(3'd0 ),                                // input wire [2 : 0] loopback
  .txp(TXP),                                          // output wire [0 : 0] txp
  .txn(TXN),                                          // output wire [0 : 0] txn
 
  .hard_err( ),                                // output wire hard_err
  .soft_err( ),                                // output wire soft_err
  .channel_up(channel_up),                            // output wire channel_up
  .lane_up(lane_up),                                  // output wire [0 : 0] lane_up
  
  .tx_out_clk(  ),                            // output wire tx_out_clk
  .drp_clk_in(drp_clk_100m),                            // input wire drp_clk_in
  .gt_pll_lock(  ),                          // output wire gt_pll_lock
  
  .s_axi_tx_tdata (s_axi_tx_tdata ),                    // input wire [63 : 0] s_axi_tx_tdata
  .s_axi_tx_tkeep (s_axi_tx_tkeep ),                    // input wire [7 : 0] s_axi_tx_tkeep
  .s_axi_tx_tlast (s_axi_tx_tlast ),                    // input wire s_axi_tx_tlast
  .s_axi_tx_tvalid(s_axi_tx_tvalid),                  // input wire s_axi_tx_tvalid
  .s_axi_tx_tready(s_axi_tx_tready),                  // output wire s_axi_tx_tready

  .m_axi_rx_tdata (m_axi_rx_tdata),                    // output wire [63 : 0] m_axi_rx_tdata
  .m_axi_rx_tkeep (m_axi_rx_tkeep),                    // output wire [7 : 0] m_axi_rx_tkeep
  .m_axi_rx_tlast (m_axi_rx_tlast),                    // output wire m_axi_rx_tlast
  .m_axi_rx_tvalid(m_axi_rx_tvalid),                  // output wire m_axi_rx_tvalid

//  .mmcm_not_locked_out(mmcm_not_locked_out),          // output wire mmcm_not_locked_out

  .drpaddr_in(9'd0),                            // input wire [8 : 0] drpaddr_in
  .drpdi_in(16'd0),                                // input wire [15 : 0] drpdi_in
  .drprdy_out( ),                            // output wire drprdy_out
  .drpen_in(1'b0),                                // input wire drpen_in
  .drpwe_in(1'b0),                                // input wire drpwe_in
  .drpdo_out( ),                              // output wire [15 : 0] drpdo_out
  
  .init_clk(sys_clk_100m),                                // input wire init_clk
  .link_reset_out( ),                    // output wire link_reset_out
  
  .gt_refclk1_p(GTXQ_P),                        // input wire gt_refclk1_p
  .gt_refclk1_n(GTXQ_N),                        // input wire gt_refclk1_n
  
  .user_clk_out(user_clk_out),                        // output wire user_clk_out
  .sync_clk_out(   ),                        // output wire sync_clk_out
  
  .gt_rxcdrovrden_in(1'b0),              			  // input wire gt_rxcdrovrden_in
  .sys_reset_out (sys_reset_out),                     // output wire sys_reset_out 低系统有效
  .gt_reset_out  (  ),                      // output wire gt_reset_out
  .gt_refclk1_out(   )                     // output wire gt_refclk1_out
);
*/
aurora_64b66b_0 aurora_64b66b_rb (
  .rxp(RXP),                                          // input wire [0 : 0] rxp
  .rxn(RXN),                                          // input wire [0 : 0] rxn
  .reset_pb(sys_rst),                                // input wire reset_pb
  .power_down(1'b0),                            // input wire power_down
  .pma_init(1'b0),                                // input wire pma_init
  .loopback(3'd0),                                // input wire [2 : 0] loopback
  .txp(TXP),                                          // output wire [0 : 0] txp
  .txn(TXN),                                          // output wire [0 : 0] txn
  .hard_err( ),                                // output wire hard_err
  .soft_err( ),                                // output wire soft_err
  .channel_up(channel_up),                            // output wire channel_up
  .lane_up(lane_up),                                  // output wire [0 : 0] lane_up
  .tx_out_clk( ),                            // output wire tx_out_clk
  .drp_clk_in(drp_clk_100m),                            // input wire drp_clk_in
  .gt_pll_lock( ),                          // output wire gt_pll_lock
  .s_axi_tx_tdata(s_axi_tx_tdata),                    // input wire [63 : 0] s_axi_tx_tdata
  .s_axi_tx_tkeep(s_axi_tx_tkeep),                    // input wire [7 : 0] s_axi_tx_tkeep
  .s_axi_tx_tlast(s_axi_tx_tlast),                    // input wire s_axi_tx_tlast
  .s_axi_tx_tvalid(s_axi_tx_tvalid),                  // input wire s_axi_tx_tvalid
  .s_axi_tx_tready(s_axi_tx_tready),                  // output wire s_axi_tx_tready
 
  .m_axi_rx_tdata(m_axi_rx_tdata),                    // output wire [63 : 0] m_axi_rx_tdata
  .m_axi_rx_tkeep(m_axi_rx_tkeep),                    // output wire [7 : 0] m_axi_rx_tkeep
  .m_axi_rx_tlast(m_axi_rx_tlast),                    // output wire m_axi_rx_tlast
  .m_axi_rx_tvalid(m_axi_rx_tvalid),                  // output wire m_axi_rx_tvalid
  .mmcm_not_locked_out( ),          // output wire mmcm_not_locked_out
  .drpaddr_in(9'd0),                            // input wire [8 : 0] drpaddr_in
  .drpdi_in(16'd0),                                // input wire [15 : 0] drpdi_in
  .drprdy_out( ),                            // output wire drprdy_out
  .drpen_in(1'b0),                                // input wire drpen_in
  .drpwe_in(1'b0),                                // input wire drpwe_in
  .drpdo_out( ),                              // output wire [15 : 0] drpdo_out
  .init_clk(sys_clk_100m),                                // input wire init_clk
  .link_reset_out( ),                    // output wire link_reset_out
  .gt_refclk1_p(GTXQ_P),                        // input wire gt_refclk1_p
  .gt_refclk1_n(GTXQ_N),                        // input wire gt_refclk1_n
  .user_clk_out(user_clk_out),                        // output wire user_clk_out
  .sync_clk_out( ),                        // output wire sync_clk_out
  .gt_qpllclk_quad2_out( ),        // output wire gt_qpllclk_quad2_out
  .gt_qpllrefclk_quad2_out( ),  // output wire gt_qpllrefclk_quad2_out
  .gt_rxcdrovrden_in(1'b0),              // input wire gt_rxcdrovrden_in
  .sys_reset_out( sys_reset_out ),                      // output wire sys_reset_out
  .gt_reset_out( ),                        // output wire gt_reset_out
  .gt_refclk1_out( )                    // output wire gt_refclk1_out
);


ila_0 ila_RX (
	.clk(user_clk_out), // input wire clk

	.probe0(channel_up), // input wire [0:0]  probe0  
	.probe1(lane_up), // input wire [0:0]  probe1 
	.probe2(m_axi_rx_tdata), // input wire [63:0]  probe2 
	.probe3(m_axi_rx_tkeep), // input wire [7:0]  probe3 
	.probe4(m_axi_rx_tlast), // input wire [0:0]  probe4 
	.probe5(m_axi_rx_tvalid) // input wire [0:0]  probe5
);


	
endmodule
