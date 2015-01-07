library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ALU is
	port	(		
				op1	:	in		std_logic_vector(15 downto 0);
				op2	:	in		std_logic_vector(15 downto 0);
				sel	:	in		std_logic_vector(1 downto 0);
				res	:	out	std_logic_vector(15 downto 0)  
);

end entity ALU;
 
architecture ALU_structure of ALU is
  
signal zero: std_logic_vector(14 downto 0);

begin
 zero <= (others => '0');
 
 PROCESS (sel, op1, op2) is
 begin 
	case sel is
		when "00" => res <= op1 + op2;
		when "01" => res <= op1 - op2;
		when "10" => res <= op2;
		when "11" => res <= op1;
		when others => res <= "XXXXXXXXXXXXXXXX";
	end case;
 END PROCESS;
	
end architecture ALU_structure;