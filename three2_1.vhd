library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity three2_1 is
	port(I0		:in std_logic_vector (31 downto 0);
	     I1		:in std_logic_vector (31 downto 0);
	     I2		:in  std_logic_vector (31 downto 0);
	     SEL	:in std_logic_vector (1 downto 0);
	      MP_out	:out std_logic_vector (31 downto 0) );
end three2_1;

architecture dataflow of three2_1 is

begin

with SEL select
	MP_out <= I0 when "00",
		  I1 when "01",
 		  I2 when "10",
		"00000000000000000000000000000000" when others; 

end dataflow;



