// This file contains gloabl parameters

`ifndef _GLOBAL_PARA_V
`define _GLOBAL_PARA_V

`define DATA_SIZE 			128 
`define HEADER_SIZE 			24
`define CHANNEL_SIZE 		`DATA_SIZE+`HEADER_SIZE 
`define IN_ROUTER_SIZE		`CHANNEL_SIZE+10	// 162 bits			
`define FLITNUM_SIZE			2			// in-packet sequence number
`define PKTID_SIZE			8
`define FLITTYPE_SIZE		2			// 0: header 1: body 2: tail 3: header & tail
`define PORT_TAG_SIZE		3
`define PROD_VECTOR_SIZE	5
`define COORDINATE_SIZE		6			// source and destination coordinate width
`define CURRENT_POSITION_X		3'b001	// in really system, each router knows its own position. set statically here for simplicity
`define CURRENT_POSITION_Y		3'b001	// in really system, each router knows its own position. set statically here for simplicity

`define EPOCH_GOLDEN			8'd12

`define VALID 				161
`define GOLDEN 			160
`define PORT_TAG			159:157
`define PROD_VECTOR		156:152
`define PROD_VECTOR_NO_LOCAL	155:152
`define PKT_ID				151:144
`define FLIT_NUM			143:142
`define SRC					141:136
`define DST					135:130
`define TYPE				129:128

`define PROD_VECTOR_LOCAL	156

`define PROD_VECTOR_EAST 	152
`define PROD_VECTOR_WEST	153  
`define PROD_VECTOR_NORTH	154
`define PROD_VECTOR_SOUTH	155


// The following is for PAB-NOC
`define PERMANENT 			1'b1
`define NONPERMANENT 		1'b0
`define EPOCH_PG			10'd1000
`define PG_COUNTER_SIZE		10
`define PG_THRESHOLD_PORT	150 
`define PG_THRESHOLD_LV2	500
`define PG_THRESHOLD_LV3	400
`define PG_ROUTER_LOAD_SIZE `PG_COUNTER_SIZE+2
`define PG_PORT_LOAD_SIZE	`PG_COUNTER_SIZE
`define INACTIVE			3'b000
`define ACTIVE				3'b001
`define WAKE_UP_TX			3'b010
`define WAKE_UP_RX			3'b011
`define WAIT_PG_HIGH		3'b100
`define WAIT_PG_LOW			3'b101
`define WAIT_WU_LOW			3'b110
`define WAKE_UP_DELAY		5'd5
`define PORT_STAT_SIZE		3



`endif