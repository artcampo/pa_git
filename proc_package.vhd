library ieee;
use ieee.std_logic_1164.all;

package proc_package is


-- Constants ---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
constant data_width_c      : natural := 16;
constant num_registers	   : natural := 8;
constant ctrl_width_c      : natural := 16;

constant alu_op_bits	      : natural := 2;
constant alu_equal_c        	: std_logic_vector(15 downto 0) := "0000000000000001"; 
constant alu_not_equal_c       : std_logic_vector(15 downto 0) := "0000000000000000"; 

-- ALU Function Select -----------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------

  -- Elementary ALU Operations --
  constant alu_add_c        : std_logic_vector(1 downto 0) := "00"; -- add 
  constant alu_sub_c        : std_logic_vector(1 downto 0) := "01"; -- subtract 
  constant alu_comp_c       : std_logic_vector(1 downto 0) := "10"; -- compare (keep the biggest)
  constant alu_op1_c        : std_logic_vector(1 downto 0) := "11"; -- result equal to op1





-- Component: ALU -------------------------------------------------------
-- -------------------------------------------------------------------------------------------

component ALU is
	port	(		
				op1	:	in		std_logic_vector(data_width_c - 1 downto 0);
				op2	:	in		std_logic_vector(data_width_c - 1 downto 0);
				sel	:	in		std_logic_vector(1 downto 0);
				res	:	out	std_logic_vector(data_width_c - 1 downto 0)  
);
end component ALU;



-- Component: MEM -------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component mem is
	port	(
				-- Host Interface --
				Clock_CI        : in   std_logic; 
				Ins_Addr_DI     : in   std_logic_vector(data_width_c - 1 downto 0); 
				Ins_Enab_DI     : in   std_logic;
				Ins_Data_DO     : out  std_logic_vector(data_width_c - 1 downto 0) 
			);
end component mem;
----------------------------------------------------------------------------------------------


end package proc_package;