library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity hazard_detect is 
	 port(	CLK           		: in  std_logic;
		id_ex_mem_to_reg	: in  std_logic;
		id_instruction		: in std_logic_vector (31 downto 0); --from after the IF/ID
		id_ex_register_rt	: in std_logic_vector (4 downto 0);
		ex_write_reg_sel	: in std_logic_vector (4 downto 0); 
		if_id_register_rs	: in std_logic_vector (4 downto 0); 
		if_id_register_rt	: in std_logic_vector (4 downto 0); 
		branch_taken		: in std_logic;
		o_stall			: out std_logic;
		o_flush			: out std_logic); 

end hazard_detect;

architecture mixed of hazard_detect is 
signal op_code : std_logic_vector(5 downto 0);
begin 


 op_code <= id_instruction(31 downto 26);
 

instruction_check: process(op_code,CLK)
begin

		if(op_code = "000010" ) then -- jump flush 
			o_flush <= '1'; 
			o_stall <='0';

		elsif(op_code = "000100") then -- beq flush 
			if(branch_taken ='1')then
				o_flush <='1'; --needs to go to if_id
				o_stall <= '0';
			elsif((ex_write_reg_sel = if_id_register_rs) or (ex_write_reg_sel = if_id_register_rt)) then
				o_stall <= '1'; --needs to go to PC, if_id 
				o_flush <= '1'; --needs to go to id_ex 
			else
				o_stall <= '0';
				o_flush <= '0';
			end if; 
			
		elsif(id_ex_mem_to_reg = '1' and ((id_ex_register_rt = if_id_register_rs) or (id_ex_register_rt = if_id_register_rt)))then --used for forwarding checks 2 ahead 
			o_stall <= '1'; -- goes to PC, if_id
			o_flush <= '1'; -- goes to id_ex 
		else
			o_stall <= '0';
			o_flush <= '0';
		end if;

	

end process instruction_check;
end mixed; 
