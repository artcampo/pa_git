library ieee;
use ieee.std_logic_1164.all;

package proc_package is

----------------------------------------------------------------------------
--		Constants
constant data_width_c      : natural := 16;
constant num_registers	   : natural := 8;
constant ctrl_width_c      : natural := 16;

constant alu_op_bits	      : natural := 2;

----------------------------------------------------------------------------
--		Components

------------------------------------------------
component ALU is
	port	(		
				op1	:	in		std_logic_vector(data_width_c - 1 downto 0);
				op2	:	in		std_logic_vector(data_width_c - 1 downto 0);
				sel	:	in		std_logic_vector(1 downto 0);
				res	:	out	std_logic_vector(data_width_c - 1 downto 0)  
);
end component ALU;

------------------------------------------------
component mem is
	port	(
				-- Host Interface --
				Clock_CI        : in   std_logic; 
				Ins_Addr_DI     : in   std_logic_vector(data_width_c - 1 downto 0); 
				Ins_Enab_DI     : in   std_logic;
				Ins_Data_DO     : out  std_logic_vector(data_width_c - 1 downto 0) 
			);
end component mem;


end package proc_package;