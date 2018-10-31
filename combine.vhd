library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- shifts the input "i_to_shift" by 2 and output the result in "o_shifted"
entity combine is
  port( i_inst : in std_logic_vector(31 downto 0);
		  i_next : in std_logic_vector(31 downto 0);
  	     o_combined : out std_logic_vector(31 downto 0));
 end combine;

architecture mixed of combine is 

signal s_temp: std_logic_vector(31 downto 0);
begin

process(i_inst, i_next)
  
  variable temp1 : std_logic_vector(31 downto 0);
  variable temp2 : std_logic_vector(31 downto 0);
  begin

		temp1(31 downto 0) := i_inst and "00001111111111111111111111111111";
		temp2(31 downto 0) := i_next and "11110000000000000000000000000000";
	
		s_temp(31 downto 0) <= temp1(31 downto 0) or temp2(31 downto 0);
		
  end process;
  
  o_combined <= s_temp(31 downto 0);


end mixed;