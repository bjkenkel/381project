library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- shifts the input "i_to_shift" by 2 and output the result in "o_shifted"
entity sll_2_25bits is
  port( i_to_shift : in std_logic_vector(25 downto 0);
  	    o_shifted : out std_logic_vector(31 downto 0));
 end sll_2_25bits;

architecture mixed of sll_2_25bits is 

signal s_temp : std_logic_vector(31 downto 0);

begin

process(i_to_shift)
begin
	s_temp(31 downto 28) <= "0000";
	s_temp(27 downto 2) <= i_to_shift(25 downto 0);
	s_temp(1 downto 0) <= "00";
end process;

o_shifted <= s_temp;
end mixed;