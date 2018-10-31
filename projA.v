// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.0.0 Build 614 04/24/2018 SJ Standard Edition"
// CREATED		"Thu Oct 25 17:27:34 2018"

module projA(
	i_CLK,
	i_RESET
);


input wire	i_CLK;
input wire	i_RESET;

wire	[3:0] ALU_op;
wire	[31:0] ALU_out;
wire	ALU_src;
wire	branch;
wire	[31:0] i_next_PC;
wire	[31:0] instruction;
wire	jump;
wire	mem_to_reg;
wire	mem_we;
wire	[31:0] o_PC;
wire	[31:0] o_pc_plus_4;
wire	register_we;
wire	[31:0] rs_data;
wire	[31:0] rt_data;
wire	SYNTHESIZED_WIRE_0;
wire	[0:3] SYNTHESIZED_WIRE_1;
wire	[0:31] SYNTHESIZED_WIRE_2;
wire	[0:3] SYNTHESIZED_WIRE_3;
wire	[31:0] SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	[31:0] SYNTHESIZED_WIRE_21;
wire	[0:3] SYNTHESIZED_WIRE_7;
wire	[31:0] SYNTHESIZED_WIRE_8;
wire	[0:4] SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	[31:0] SYNTHESIZED_WIRE_11;
wire	[31:0] SYNTHESIZED_WIRE_12;
wire	[31:0] SYNTHESIZED_WIRE_13;
wire	[31:0] SYNTHESIZED_WIRE_14;
wire	[31:0] SYNTHESIZED_WIRE_15;
wire	[4:0] SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	[31:0] SYNTHESIZED_WIRE_19;
wire	[0:4] SYNTHESIZED_WIRE_20;

assign	SYNTHESIZED_WIRE_0 = 0;
assign	SYNTHESIZED_WIRE_1 = 1;
assign	SYNTHESIZED_WIRE_2 = 0;
assign	SYNTHESIZED_WIRE_3 = 1;
assign	SYNTHESIZED_WIRE_7 = 0;
assign	SYNTHESIZED_WIRE_9 = 0;
assign	SYNTHESIZED_WIRE_20 = 0;




PC_reg	b2v_inst(
	.CLK(i_CLK),
	.reset(i_RESET),
	.i_next_PC(i_next_PC),
	.o_PC(o_PC));


imem	b2v_inst1(
	.clock(i_CLK),
	.wren(SYNTHESIZED_WIRE_0),
	.address(o_PC[11:2]),
	.byteena(SYNTHESIZED_WIRE_1),
	.data(SYNTHESIZED_WIRE_2),
	.q(instruction));
	defparam	b2v_inst1.depth_exp_of_2 = 10;
	defparam	b2v_inst1.mif_filename = "imem.mif";


dmem	b2v_inst10(
	.clock(i_CLK),
	.wren(mem_we),
	.address(ALU_out[11:2]),
	.byteena(SYNTHESIZED_WIRE_3),
	.data(rt_data),
	.q(SYNTHESIZED_WIRE_4));
	defparam	b2v_inst10.depth_exp_of_2 = 10;
	defparam	b2v_inst10.mif_filename = "dmem.mif";



mux21_32bit	b2v_inst12(
	.i_sel(mem_to_reg),
	.i_0(ALU_out),
	.i_1(SYNTHESIZED_WIRE_4),
	.o_mux(SYNTHESIZED_WIRE_15));


sign_extender_16_32	b2v_inst13(
	.i_to_extend(instruction[15:0]),
	.o_extended(SYNTHESIZED_WIRE_21));


and_2	b2v_inst14(
	.i_A(branch),
	.i_B(SYNTHESIZED_WIRE_5),
	.o_F(SYNTHESIZED_WIRE_10));



sll_2	b2v_inst16(
	.i_to_shift(SYNTHESIZED_WIRE_21),
	.o_shifted(SYNTHESIZED_WIRE_8));


ALU	b2v_inst17(
	.ALU_OP(SYNTHESIZED_WIRE_7),
	.i_A(o_pc_plus_4),
	.i_B(SYNTHESIZED_WIRE_8),
	.shamt(SYNTHESIZED_WIRE_9),
	
	.ALU_out(SYNTHESIZED_WIRE_11));





mux21_32bit	b2v_inst26(
	.i_sel(SYNTHESIZED_WIRE_10),
	.i_0(o_pc_plus_4),
	.i_1(SYNTHESIZED_WIRE_11),
	.o_mux(SYNTHESIZED_WIRE_13));


mux21_32bit	b2v_inst27(
	.i_sel(jump),
	.i_0(SYNTHESIZED_WIRE_12),
	.i_1(SYNTHESIZED_WIRE_13),
	.o_mux(i_next_PC));




add4	b2v_inst30(
	.i_A(o_PC),
	.add4_out(o_pc_plus_4));


combine	b2v_inst32(
	.i_inst(SYNTHESIZED_WIRE_14),
	.i_next(o_pc_plus_4),
	.o_combined(SYNTHESIZED_WIRE_12));


main_control	b2v_inst33(
	.i_instruction(instruction),
	.o_reg_dest(SYNTHESIZED_WIRE_17),
	.o_jump(jump),
	.o_branch(branch),
	.o_mem_to_reg(mem_to_reg),
	.o_mem_write(mem_we),
	.o_ALU_src(ALU_src),
	.o_reg_write(register_we),
	.o_ALU_op(ALU_op));


sll_2_25bits	b2v_inst34(
	.i_to_shift(instruction[25:0]),
	.o_shifted(SYNTHESIZED_WIRE_14));


register_file	b2v_inst4(
	.CLK(i_CLK),
	.w_en(register_we),
	.reset(i_RESET),
	.rs_sel(instruction[25:21]),
	.rt_sel(instruction[20:16]),
	.w_data(SYNTHESIZED_WIRE_15),
	.w_sel(SYNTHESIZED_WIRE_16),
	.rs_data(rs_data),
	.rt_data(rt_data));


mux21_5bit	b2v_inst5(
	.i_sel(SYNTHESIZED_WIRE_17),
	.i_0(instruction[20:16]),
	.i_1(instruction[15:11]),
	.o_mux(SYNTHESIZED_WIRE_16));


mux21_32bit	b2v_inst7(
	.i_sel(ALU_src),
	.i_0(rt_data),
	.i_1(SYNTHESIZED_WIRE_21),
	.o_mux(SYNTHESIZED_WIRE_19));


ALU	b2v_inst8(
	.ALU_OP(ALU_op),
	.i_A(rs_data),
	.i_B(SYNTHESIZED_WIRE_19),
	.shamt(SYNTHESIZED_WIRE_20),
	.zero(SYNTHESIZED_WIRE_5),
	.ALU_out(ALU_out));



endmodule
