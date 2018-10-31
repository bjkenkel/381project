library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity add4 is
  port(i_A           : in  std_logic_vector(31 downto 0);
       add4_out       : out std_logic_vector(31 downto 0));
end add4;

Architecture mixed of add4 is 

signal s_temp : std_logic_vector(63 downto 0);

begin

  process(i_A)
  
  variable int_shamt : integer;
  variable temp : std_logic_vector(63 downto 0);
  begin

		temp(31 downto 0) := std_logic_vector(signed(i_A) + 4);
	
	s_temp <= temp;
  end process;
  
  add4_out <= s_temp(31 downto 0);

end mixed;