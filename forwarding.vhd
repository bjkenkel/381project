library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity forwarding is
port( 	CLK			:in std_logic;
	wb_reg_write		:in  std_logic;
	ex_reg_write  		:in std_logic;
	id_ex_register_rs	:in std_logic_vector (4 downto 0); 
	id_ex_register_rt	:in std_logic_vector (4 downto 0); 
	ex_mem_register_rd	:in std_logic_vector (4 downto 0);
	mem_wb_register_rd	:in std_logic_vector (4 downto 0);
	forward_A		:out std_logic_vector (1 downto 0);
	forward_B		:out std_logic_vector (1 downto 0)
);
end forwarding; 
architecture mixed of forwarding is 
begin

forward_check: process(CLK)
begin

	if(ex_reg_write  ='1' and id_ex_register_rs = ex_mem_register_rd and ex_mem_register_rd > "00000") then --checks 1 away for Rt
		
		forward_A <= "10";

	elsif(wb_reg_write ='1' and id_ex_register_rs = mem_wb_register_rd and mem_wb_register_rd > "00000") then--checks 2 away for Rt

		forward_A <= "01";

	else 
		forward_A <="00";--neither
		
	end if;
		
	if(ex_reg_write  ='1' and id_ex_register_rt = ex_mem_register_rd and ex_mem_register_rd > "00000") then --checks 1 away for Rs

		forward_B <= "10";

	elsif(wb_reg_write ='1' and id_ex_register_rt = mem_wb_register_rd and mem_wb_register_rd > "00000") then --checks 2 away for Rs

		forward_B <= "01";

	else 
		
		forward_B <="00";	--neither 
	
	end if;
end process forward_check;
end mixed; 

 


		