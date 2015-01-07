library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.proc_package.all;

entity ALU is
	port	(		
				op1	:	in		std_logic_vector(data_width_c - 1 downto 0);
				op2	:	in		std_logic_vector(data_width_c - 1 downto 0);
				sel	:	in		std_logic_vector(alu_op_bits - 1 downto 0);
				res	:	out	std_logic_vector(data_width_c - 1 downto 0)  
);

end entity ALU;
 
architecture ALU_structure of ALU is
  

begin
 
 PROCESS (sel, op1, op2) is
 begin 
	case sel is
		when alu_add_c => res <= op1 + op2;
		when alu_sub_c => res <= op1 - op2;
		when alu_comp_c => 
			if(op1=op2) then
				res <= alu_equal_c; 			-- if op1 equals op2 res = TRUE
			elsif(op1/=op2) then
				res <= alu_not_equal_c;		-- if op1 != op2 res = FALSE
			end if;
		when alu_op1_c => res <= op1;
		when others => res <= "XXXXXXXXXXXXXXXX";
	end case;
 END PROCESS;
	
end architecture ALU_structure;