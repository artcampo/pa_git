--my_gates.vhd in the "work" directory (in this example)

library ieee;
use ieee.std_logic_1164.all;

package proc_package is


component ALU is
	port	(		
				op1	:	in		std_logic_vector(15 downto 0);
				op2	:	in		std_logic_vector(15 downto 0);
				sel	:	in		std_logic_vector(2 downto 0);
				res	:	out	std_logic_vector(15 downto 0)  
);
end component ALU;



component mem is
	port	(
				-- Host Interface --
				Clock_CI        : in   std_logic; 
				Ins_Addr_DI     : in   std_logic_vector(15 downto 0); 
				Ins_Enab_DI     : in   std_logic;
				Ins_Data_DO     : out  std_logic_vector(15 downto 0) 
			);
end component mem;


end package proc_package;