library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.proc_package.all;

entity decoder is
	port	(		
				inst	:	in		std_logic_vector(data_width_c - 1 downto 0);
				crtl	:	out	std_logic_vector(data_width_c - 1 downto 0)
);

end entity decoder;