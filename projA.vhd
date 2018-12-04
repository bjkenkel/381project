-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.0.0 Build 614 04/24/2018 SJ Standard Edition"
-- CREATED		"Mon Dec 03 17:24:16 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY projA IS 
	PORT
	(
		i_CLK :  IN  STD_LOGIC;
		i_RESET :  IN  STD_LOGIC
	);
END projA;

ARCHITECTURE bdf_type OF projA IS 

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT imem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dmem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_32bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sll_2
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(ALU_OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT branch_comparator
	PORT(i_rs_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_rt_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_equal : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT if_id
	PORT(CLK : IN STD_LOGIC;
		 id_flush : IN STD_LOGIC;
		 id_stall : IN STD_LOGIC;
		 ifid_reset : IN STD_LOGIC;
		 if_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 if_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ex_mem
	PORT(CLK : IN STD_LOGIC;
		 mem_flush : IN STD_LOGIC;
		 mem_stall : IN STD_LOGIC;
		 exmem_reset : IN STD_LOGIC;
		 ex_reg_dest : IN STD_LOGIC;
		 ex_mem_to_reg : IN STD_LOGIC;
		 ex_mem_write : IN STD_LOGIC;
		 ex_reg_write : IN STD_LOGIC;
		 ex_ALU_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rt_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 mem_reg_dest : OUT STD_LOGIC;
		 mem_mem_to_reg : OUT STD_LOGIC;
		 mem_mem_write : OUT STD_LOGIC;
		 mem_reg_write : OUT STD_LOGIC;
		 mem_ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_write_reg_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mem_wb
	PORT(CLK : IN STD_LOGIC;
		 wb_flush : IN STD_LOGIC;
		 wb_stall : IN STD_LOGIC;
		 memwb_reset : IN STD_LOGIC;
		 mem_reg_dest : IN STD_LOGIC;
		 mem_mem_to_reg : IN STD_LOGIC;
		 mem_reg_write : IN STD_LOGIC;
		 mem_ALU_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_dmem_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 wb_reg_dest : OUT STD_LOGIC;
		 wb_mem_to_reg : OUT STD_LOGIC;
		 wb_reg_write : OUT STD_LOGIC;
		 wb_ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_dmem_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_write_reg_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT three2_1
	PORT(I0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 I1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 I2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 MP_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT add4
	PORT(i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 add4_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT combine
	PORT(i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_next : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_combined : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT main_control
	PORT(i_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_reg_dest : OUT STD_LOGIC;
		 o_jump : OUT STD_LOGIC;
		 o_branch : OUT STD_LOGIC;
		 o_mem_to_reg : OUT STD_LOGIC;
		 o_mem_write : OUT STD_LOGIC;
		 o_ALU_src : OUT STD_LOGIC;
		 o_reg_write : OUT STD_LOGIC;
		 o_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT id_ex
	PORT(CLK : IN STD_LOGIC;
		 ex_flush : IN STD_LOGIC;
		 ex_stall : IN STD_LOGIC;
		 idex_reset : IN STD_LOGIC;
		 id_reg_dest : IN STD_LOGIC;
		 id_jump : IN STD_LOGIC;
		 id_branch : IN STD_LOGIC;
		 id_mem_to_reg : IN STD_LOGIC;
		 id_mem_write : IN STD_LOGIC;
		 id_ALU_src : IN STD_LOGIC;
		 id_reg_write : IN STD_LOGIC;
		 id_ALU_op : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 id_extended_immediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_rd_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_rs_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_rt_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_reg_dest : OUT STD_LOGIC;
		 ex_jump : OUT STD_LOGIC;
		 ex_branch : OUT STD_LOGIC;
		 ex_mem_to_reg : OUT STD_LOGIC;
		 ex_mem_write : OUT STD_LOGIC;
		 ex_ALU_src : OUT STD_LOGIC;
		 ex_reg_write : OUT STD_LOGIC;
		 ex_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 ex_extended_immediate : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rd_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rs_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rt_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT forwarding
	PORT(wb_reg_write : IN STD_LOGIC;
		 mem_reg_write : IN STD_LOGIC;
		 ex_rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 mem_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 wb_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs_mux_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 rt_mux_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT register_file
	PORT(CLK : IN STD_LOGIC;
		 w_en : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 w_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 w_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT hazard
	PORT(control_jump : IN STD_LOGIC;
		 id_branch : IN STD_LOGIC;
		 branch_taken : IN STD_LOGIC;
		 id_ex_memRead : IN STD_LOGIC;
		 ex_writRegSel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_ex_regRt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 if_id_regRs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 if_id_regRt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 pc_stall : OUT STD_LOGIC;
		 if_id_stall : OUT STD_LOGIC;
		 if_id_flush : OUT STD_LOGIC;
		 id_ex_flush : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 stall : IN STD_LOGIC;
		 i_next_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT and_2
	PORT(i_A : IN STD_LOGIC;
		 i_B : IN STD_LOGIC;
		 o_F : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	ALU_in_A :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_in_B :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	branch_taken :  STD_LOGIC;
SIGNAL	combined_next_pc :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_ALU_op :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	ex_ALU_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_ALU_src :  STD_LOGIC;
SIGNAL	ex_extended_immediate :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_extended_immediate_sll2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_instruction :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_instruction_sll2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_jump :  STD_LOGIC;
SIGNAL	ex_mem_to_reg :  STD_LOGIC;
SIGNAL	ex_mem_write :  STD_LOGIC;
SIGNAL	ex_pc_plus_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_rd_sel :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	ex_reg_dest :  STD_LOGIC;
SIGNAL	ex_reg_write :  STD_LOGIC;
SIGNAL	ex_rs_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_rs_sel :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	ex_rt_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_rt_sel :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	ex_write_reg_sel :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	forward_A :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	forward_B :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	hazards_pc_stall :  STD_LOGIC;
SIGNAL	id_ALU_op :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	id_ALU_src :  STD_LOGIC;
SIGNAL	id_branch :  STD_LOGIC;
SIGNAL	id_instruction :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	id_jump :  STD_LOGIC;
SIGNAL	id_mem_to_reg :  STD_LOGIC;
SIGNAL	id_mem_we :  STD_LOGIC;
SIGNAL	id_pc_plus_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	id_reg_dest :  STD_LOGIC;
SIGNAL	id_reg_write :  STD_LOGIC;
SIGNAL	id_rs_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	id_rt_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	if_instruction :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	if_pc_plus_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	in_next_pc :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	mem_ALU_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	mem_dmem_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	mem_mem_we :  STD_LOGIC;
SIGNAL	mem_reg_write :  STD_LOGIC;
SIGNAL	mem_rt_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	mem_write_reg_sel :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	o_branch_comparator :  STD_LOGIC;
SIGNAL	o_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	wb_ALU_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	wb_dmem_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	wb_mux_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	wb_reg_write :  STD_LOGIC;
SIGNAL	wb_write_reg_sel :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(0 TO 31);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(0 TO 4);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_30 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_31 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_22 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_23 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC_VECTOR(0 TO 4);


BEGIN 
SYNTHESIZED_WIRE_0 <= '0';
SYNTHESIZED_WIRE_1 <= "1111";
SYNTHESIZED_WIRE_2 <= "00000000000000000000000000000000";
SYNTHESIZED_WIRE_3 <= "1111";
SYNTHESIZED_WIRE_6 <= "0000";
SYNTHESIZED_WIRE_7 <= "00000";
SYNTHESIZED_WIRE_30 <= '0';
SYNTHESIZED_WIRE_23 <= '0';
SYNTHESIZED_WIRE_28 <= "00000";



b2v_inst : mux21_5bit
PORT MAP(i_sel => ex_reg_dest,
		 i_0 => ex_rt_sel,
		 i_1 => ex_rd_sel,
		 o_mux => SYNTHESIZED_WIRE_26);


b2v_inst1 : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => i_CLK,
		 wren => SYNTHESIZED_WIRE_0,
		 address => o_PC(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_1,
		 data => SYNTHESIZED_WIRE_2,
		 q => if_instruction);


b2v_inst10 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => i_CLK,
		 wren => mem_mem_we,
		 address => mem_ALU_out(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_3,
		 data => mem_rt_data,
		 q => mem_dmem_out);



b2v_inst12 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_4,
		 i_0 => wb_ALU_out,
		 i_1 => wb_dmem_out,
		 o_mux => wb_mux_out);


b2v_inst13 : sign_extender_16_32
PORT MAP(i_to_extend => id_instruction(15 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_29);




b2v_inst16 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_29,
		 o_shifted => ex_extended_immediate_sll2);


b2v_inst17 : alu
PORT MAP(ALU_OP => SYNTHESIZED_WIRE_6,
		 i_A => id_pc_plus_4,
		 i_B => ex_extended_immediate_sll2,
		 shamt => SYNTHESIZED_WIRE_7,
		 ALU_out => SYNTHESIZED_WIRE_19);


b2v_inst18 : branch_comparator
PORT MAP(i_rs_data => id_rs_data,
		 i_rt_data => id_rt_data,
		 o_equal => o_branch_comparator);


b2v_inst19 : if_id
PORT MAP(CLK => i_CLK,
		 id_flush => SYNTHESIZED_WIRE_8,
		 id_stall => SYNTHESIZED_WIRE_9,
		 ifid_reset => i_RESET,
		 if_instruction => if_instruction,
		 if_pc_plus_4 => if_pc_plus_4,
		 id_instruction => id_instruction,
		 id_pc_plus_4 => id_pc_plus_4);



b2v_inst20 : ex_mem
PORT MAP(CLK => i_CLK,
		 mem_flush => SYNTHESIZED_WIRE_30,
		 mem_stall => SYNTHESIZED_WIRE_30,
		 exmem_reset => i_RESET,
		 ex_reg_dest => ex_reg_dest,
		 ex_mem_to_reg => ex_mem_to_reg,
		 ex_mem_write => ex_mem_write,
		 ex_reg_write => ex_reg_write,
		 ex_ALU_out => ex_ALU_out,
		 ex_instruction => ex_instruction,
		 ex_pc_plus_4 => ex_pc_plus_4,
		 ex_rt_data => SYNTHESIZED_WIRE_31,
		 ex_write_reg_sel => ex_write_reg_sel,
		 mem_reg_dest => SYNTHESIZED_WIRE_15,
		 mem_mem_to_reg => SYNTHESIZED_WIRE_16,
		 mem_mem_write => mem_mem_we,
		 mem_reg_write => mem_reg_write,
		 mem_ALU_out => mem_ALU_out,
		 mem_instruction => SYNTHESIZED_WIRE_17,
		 mem_pc_plus_4 => SYNTHESIZED_WIRE_18,
		 mem_rt_data => mem_rt_data,
		 mem_write_reg_sel => mem_write_reg_sel);


b2v_inst22 : mem_wb
PORT MAP(CLK => i_CLK,
		 wb_flush => SYNTHESIZED_WIRE_30,
		 wb_stall => SYNTHESIZED_WIRE_30,
		 memwb_reset => i_RESET,
		 mem_reg_dest => SYNTHESIZED_WIRE_15,
		 mem_mem_to_reg => SYNTHESIZED_WIRE_16,
		 mem_reg_write => mem_reg_write,
		 mem_ALU_out => mem_ALU_out,
		 mem_dmem_out => mem_dmem_out,
		 mem_instruction => SYNTHESIZED_WIRE_17,
		 mem_pc_plus_4 => SYNTHESIZED_WIRE_18,
		 mem_write_reg_sel => mem_write_reg_sel,
		 wb_mem_to_reg => SYNTHESIZED_WIRE_4,
		 wb_reg_write => wb_reg_write,
		 wb_ALU_out => wb_ALU_out,
		 wb_dmem_out => wb_dmem_out,
		 wb_write_reg_sel => wb_write_reg_sel);


b2v_inst23 : three2_1
PORT MAP(I0 => ex_rt_data,
		 I1 => wb_mux_out,
		 I2 => mem_ALU_out,
		 SEL => forward_B,
		 MP_out => SYNTHESIZED_WIRE_31);




b2v_inst26 : mux21_32bit
PORT MAP(i_sel => branch_taken,
		 i_0 => id_pc_plus_4,
		 i_1 => SYNTHESIZED_WIRE_19,
		 o_mux => SYNTHESIZED_WIRE_20);


b2v_inst27 : mux21_32bit
PORT MAP(i_sel => ex_jump,
		 i_0 => SYNTHESIZED_WIRE_20,
		 i_1 => combined_next_pc,
		 o_mux => in_next_pc);



b2v_inst29 : three2_1
PORT MAP(I0 => ex_rs_data,
		 I1 => wb_mux_out,
		 I2 => mem_ALU_out,
		 SEL => forward_A,
		 MP_out => ALU_in_A);



b2v_inst30 : add4
PORT MAP(i_A => o_PC,
		 add4_out => if_pc_plus_4);



b2v_inst32 : combine
PORT MAP(i_inst => ex_instruction_sll2,
		 i_next => id_pc_plus_4,
		 o_combined => combined_next_pc);


b2v_inst33 : main_control
PORT MAP(i_instruction => id_instruction,
		 o_reg_dest => id_reg_dest,
		 o_jump => id_jump,
		 o_branch => id_branch,
		 o_mem_to_reg => id_mem_to_reg,
		 o_mem_write => id_mem_we,
		 o_ALU_src => id_ALU_src,
		 o_reg_write => id_reg_write,
		 o_ALU_op => id_ALU_op);


b2v_inst34 : mux21_32bit
PORT MAP(i_sel => ex_ALU_src,
		 i_0 => SYNTHESIZED_WIRE_31,
		 i_1 => ex_extended_immediate,
		 o_mux => ALU_in_B);


b2v_inst36 : sll_2
PORT MAP(i_to_shift => id_instruction,
		 o_shifted => ex_instruction_sll2);


b2v_inst37 : id_ex
PORT MAP(CLK => i_CLK,
		 ex_flush => SYNTHESIZED_WIRE_22,
		 ex_stall => SYNTHESIZED_WIRE_23,
		 idex_reset => i_RESET,
		 id_reg_dest => id_reg_dest,
		 id_jump => id_jump,
		 id_branch => id_branch,
		 id_mem_to_reg => id_mem_to_reg,
		 id_mem_write => id_mem_we,
		 id_ALU_src => id_ALU_src,
		 id_reg_write => id_reg_write,
		 id_ALU_op => id_ALU_op,
		 id_extended_immediate => SYNTHESIZED_WIRE_29,
		 id_instruction => id_instruction,
		 id_pc_plus_4 => id_pc_plus_4,
		 id_rd_sel => id_instruction(15 DOWNTO 11),
		 id_rs_data => id_rs_data,
		 id_rs_sel => id_instruction(25 DOWNTO 21),
		 id_rt_data => id_rt_data,
		 id_rt_sel => id_instruction(20 DOWNTO 16),
		 ex_reg_dest => ex_reg_dest,
		 ex_jump => ex_jump,
		 ex_mem_to_reg => ex_mem_to_reg,
		 ex_mem_write => ex_mem_write,
		 ex_ALU_src => ex_ALU_src,
		 ex_reg_write => ex_reg_write,
		 ex_ALU_op => ex_ALU_op,
		 ex_extended_immediate => ex_extended_immediate,
		 ex_instruction => ex_instruction,
		 ex_pc_plus_4 => ex_pc_plus_4,
		 ex_rd_sel => ex_rd_sel,
		 ex_rs_data => ex_rs_data,
		 ex_rs_sel => ex_rs_sel,
		 ex_rt_data => ex_rt_data,
		 ex_rt_sel => ex_rt_sel);


b2v_inst38 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_25,
		 i_0 => if_pc_plus_4,
		 i_1 => in_next_pc,
		 o_mux => SYNTHESIZED_WIRE_27);


b2v_inst39 : forwarding
PORT MAP(wb_reg_write => wb_reg_write,
		 mem_reg_write => mem_reg_write,
		 ex_rs_sel => ex_rs_sel,
		 ex_rt_sel => ex_rt_sel,
		 mem_write_reg_sel => mem_write_reg_sel,
		 wb_write_reg_sel => wb_write_reg_sel,
		 rs_mux_sel => forward_A,
		 rt_mux_sel => forward_B);


b2v_inst4 : register_file
PORT MAP(CLK => i_CLK,
		 w_en => wb_reg_write,
		 reset => i_RESET,
		 rs_sel => id_instruction(25 DOWNTO 21),
		 rt_sel => id_instruction(20 DOWNTO 16),
		 w_data => wb_mux_out,
		 w_sel => wb_write_reg_sel,
		 rs_data => id_rs_data,
		 rt_data => id_rt_data);


SYNTHESIZED_WIRE_25 <= id_jump OR id_branch;


b2v_inst42 : hazard
PORT MAP(control_jump => id_jump,
		 id_branch => id_branch,
		 branch_taken => branch_taken,
		 id_ex_memRead => ex_mem_to_reg,
		 ex_writRegSel => ex_write_reg_sel,
		 id_ex_regRt => ex_rt_sel,
		 if_id_regRs => id_instruction(25 DOWNTO 21),
		 if_id_regRt => id_instruction(20 DOWNTO 16),
		 pc_stall => hazards_pc_stall,
		 if_id_stall => SYNTHESIZED_WIRE_9,
		 if_id_flush => SYNTHESIZED_WIRE_8,
		 id_ex_flush => SYNTHESIZED_WIRE_22);


b2v_inst5 : mux21_5bit
PORT MAP(i_sel => ex_mem_to_reg,
		 i_0 => SYNTHESIZED_WIRE_26,
		 i_1 => ex_rt_sel,
		 o_mux => ex_write_reg_sel);


b2v_inst6 : pc_reg
PORT MAP(CLK => i_CLK,
		 reset => i_RESET,
		 stall => hazards_pc_stall,
		 i_next_PC => SYNTHESIZED_WIRE_27,
		 o_PC => o_PC);


b2v_inst7 : and_2
PORT MAP(i_A => o_branch_comparator,
		 i_B => id_branch,
		 o_F => branch_taken);


b2v_inst8 : alu
PORT MAP(ALU_OP => ex_ALU_op,
		 i_A => ALU_in_A,
		 i_B => ALU_in_B,
		 shamt => SYNTHESIZED_WIRE_28,
		 ALU_out => ex_ALU_out);



END bdf_type;