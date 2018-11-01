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
-- CREATED		"Wed Oct 31 20:04:21 2018"

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

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 i_next_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

COMPONENT and_2
	PORT(i_A : IN STD_LOGIC;
		 i_B : IN STD_LOGIC;
		 o_F : OUT STD_LOGIC
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

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	ALU_is_zero :  STD_LOGIC;
SIGNAL	ALU_op :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	ALU_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_src :  STD_LOGIC;
SIGNAL	branch :  STD_LOGIC;
SIGNAL	combined_next_pc :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	i_next_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	instruction :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	jump :  STD_LOGIC;
SIGNAL	mem_to_reg :  STD_LOGIC;
SIGNAL	mem_we :  STD_LOGIC;
SIGNAL	o_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_pc_plus_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pc_sll2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	register_we :  STD_LOGIC;
SIGNAL	rs_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rt_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(0 TO 31);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(0 TO 4);
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC_VECTOR(0 TO 4);


BEGIN 
SYNTHESIZED_WIRE_0 <= '0';
SYNTHESIZED_WIRE_1 <= "1111";
SYNTHESIZED_WIRE_2 <= "00000000000000000000000000000000";
SYNTHESIZED_WIRE_3 <= "1111";
SYNTHESIZED_WIRE_6 <= "0000";
SYNTHESIZED_WIRE_8 <= "00000";
SYNTHESIZED_WIRE_17 <= "00000";



b2v_inst : pc_reg
PORT MAP(CLK => i_CLK,
		 reset => i_RESET,
		 i_next_PC => i_next_PC,
		 o_PC => o_PC);


b2v_inst1 : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => i_CLK,
		 wren => SYNTHESIZED_WIRE_0,
		 address => o_PC(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_1,
		 data => SYNTHESIZED_WIRE_2,
		 q => instruction);


b2v_inst10 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => i_CLK,
		 wren => mem_we,
		 address => ALU_out(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_3,
		 data => rt_data,
		 q => SYNTHESIZED_WIRE_4);



b2v_inst12 : mux21_32bit
PORT MAP(i_sel => mem_to_reg,
		 i_0 => ALU_out,
		 i_1 => SYNTHESIZED_WIRE_4,
		 o_mux => SYNTHESIZED_WIRE_12);


b2v_inst13 : sign_extender_16_32
PORT MAP(i_to_extend => instruction(15 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_18);


b2v_inst14 : and_2
PORT MAP(i_A => branch,
		 i_B => ALU_is_zero,
		 o_F => SYNTHESIZED_WIRE_9);



b2v_inst16 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_18,
		 o_shifted => SYNTHESIZED_WIRE_7);


b2v_inst17 : alu
PORT MAP(ALU_OP => SYNTHESIZED_WIRE_6,
		 i_A => o_pc_plus_4,
		 i_B => SYNTHESIZED_WIRE_7,
		 shamt => SYNTHESIZED_WIRE_8,
		 ALU_out => SYNTHESIZED_WIRE_10);





b2v_inst26 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_9,
		 i_0 => o_pc_plus_4,
		 i_1 => SYNTHESIZED_WIRE_10,
		 o_mux => SYNTHESIZED_WIRE_11);


b2v_inst27 : mux21_32bit
PORT MAP(i_sel => jump,
		 i_0 => SYNTHESIZED_WIRE_11,
		 i_1 => combined_next_pc,
		 o_mux => i_next_PC);




b2v_inst30 : add4
PORT MAP(i_A => o_PC,
		 add4_out => o_pc_plus_4);


b2v_inst32 : combine
PORT MAP(i_inst => pc_sll2,
		 i_next => o_pc_plus_4,
		 o_combined => combined_next_pc);


b2v_inst33 : main_control
PORT MAP(i_instruction => instruction,
		 o_reg_dest => SYNTHESIZED_WIRE_14,
		 o_jump => jump,
		 o_branch => branch,
		 o_mem_to_reg => mem_to_reg,
		 o_mem_write => mem_we,
		 o_ALU_src => ALU_src,
		 o_reg_write => register_we,
		 o_ALU_op => ALU_op);


b2v_inst36 : sll_2
PORT MAP(i_to_shift => instruction,
		 o_shifted => pc_sll2);


b2v_inst4 : register_file
PORT MAP(CLK => i_CLK,
		 w_en => register_we,
		 reset => i_RESET,
		 rs_sel => instruction(25 DOWNTO 21),
		 rt_sel => instruction(20 DOWNTO 16),
		 w_data => SYNTHESIZED_WIRE_12,
		 w_sel => SYNTHESIZED_WIRE_13,
		 rs_data => rs_data,
		 rt_data => rt_data);


b2v_inst5 : mux21_5bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_14,
		 i_0 => instruction(20 DOWNTO 16),
		 i_1 => instruction(15 DOWNTO 11),
		 o_mux => SYNTHESIZED_WIRE_13);


b2v_inst7 : mux21_32bit
PORT MAP(i_sel => ALU_src,
		 i_0 => rt_data,
		 i_1 => SYNTHESIZED_WIRE_18,
		 o_mux => SYNTHESIZED_WIRE_16);


b2v_inst8 : alu
PORT MAP(ALU_OP => ALU_op,
		 i_A => rs_data,
		 i_B => SYNTHESIZED_WIRE_16,
		 shamt => SYNTHESIZED_WIRE_17,
		 zero => ALU_is_zero,
		 ALU_out => ALU_out);



END bdf_type;