library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.proc_package.all;

entity decoder is
	port	(		
				inst	:	in		std_logic_vector(instr_length_c - 1 downto 0);
				op		:	out	std_logic_vector(op_c - 1 downto 0);
				ra		:	out	std_logic_vector(registers_c - 1 downto 0);
				rb		:	out	std_logic_vector(registers_c - 1 downto 0);
				rd		:	out	std_logic_vector(registers_c - 1 downto 0);
				inm	: 	out	std_logic_vector(inmediate_c - 1 downto 0)
);

end entity decoder;