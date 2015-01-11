library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.proc_package.all;

entity ALU is
	port	(		
    op1_i	:	in		std_logic_vector(data_width_c - 1 downto 0);
    op2_i	:	in		std_logic_vector(data_width_c - 1 downto 0);
    sel_i	:	in		std_logic_vector(alu_op_bits - 1 downto 0);
    res_o	:	out	std_logic_vector(data_width_c - 1 downto 0)  
);

end entity ALU;
 
architecture ALU_structure of ALU is
  

begin
 
 process (sel_i, op1_i, op2_i) is
 begin 
	case sel_i is
		when alu_add_c => res_o <= op1_i + op2_i; -- add operation
		when alu_sub_c => res_o <= op1_i - op2_i; -- substract operation
		when alu_comp_c => 					-- comparison
			if(op1_i=op2_i) then
				res_o <= alu_equal_c; 			-- if op1_i equals op2_i res_o = TRUE
			elsif(op1_i/=op2_i) then
				res_o <= alu_not_equal_c;		-- if op1_i != op2_i res_o = FALSE
			end if;
		when alu_op2_c => res_o <= op2_i; 		-- move operation
		when others => res_o <= "XXXXXXXXXXXXXXXX";
	end case;
 end process;
	
end architecture ALU_structure;