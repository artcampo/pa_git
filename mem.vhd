library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity mem is
	port	(
				-- Host Interface --
				Clock_CI        : in   std_logic; 
				Ins_Addr_DI     : in   std_logic_vector(15 downto 0); 
				Ins_Enab_DI     : in   std_logic;
				Ins_Data_DO     : out  std_logic_vector(15 downto 0) 
			);
end mem;

architecture mem_structure of mem is	
	constant mem_size     	: natural := 256;
	constant log2_mem_size 	: natural := 8;


	type mem_ram_t is array (0 to (mem_size/2)-1) of std_logic_vector(15 downto 0);

	-- MEMORY IMAGE (Bootloader Program) --
	------------------------------------------------------
	constant mem_ram : mem_ram_t :=
    (
		000000 => x"0020", -- B
		000001 => x"0010", -- B
		000002 => x"00A0", -- B		
		others => x"0000"  -- NOP
 	);
	------------------------------------------------------

begin

	-- Memory Access ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		mem_access: process(Clock_CI)
		begin
			if rising_edge(Clock_CI) then				
				if (Ins_Enab_DI = '1') then					
					Ins_Data_DO <= mem_ram(to_integer(unsigned(Ins_Addr_DI(log2_mem_size-1 downto 0))));
				end if;
			end if;
		end process mem_access;



end mem_structure;
