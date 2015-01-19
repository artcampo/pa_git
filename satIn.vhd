library ieee ;
use ieee.std_logic_1164.all;

-----------------------------------------------------

entity satIn is
port(	

	counter: 		in  std_logic_vector(1 downto 0);	
	prediction:		out std_logic
	
);
end satIn;

-----------------------------------------------------

architecture Structure of satIn is
	
begin

	with counter select
		prediction <= 
			  '0'  when "00", 
			  '0'  when "01", 
			  '0'  when "10", 			  
			  '1'  when "11", 
			  '0'  when others;

end Structure;

-----------------------------------------------------
