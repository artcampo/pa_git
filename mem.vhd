library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.proc_package.all;
use work.tb_load_signals.all;

entity mem is
	port	(
				-- Host Interface --
				clock_i         : in   std_logic; 
				ins_addr_i      : in   std_logic_vector(data_width_c - 1 downto 0); 
				ins_enab_i      : in   std_logic;
        w_data_i        : in   std_logic_vector(data_width_c - 1 downto 0); -- write data
        w_enable_i      : in   std_logic;
				ins_data_o      : out  std_logic_vector(data_width_c - 1 downto 0) 
			);
end mem;

architecture mem_structure of mem is	
	constant mem_size     	: natural := 256*10;
	constant log2_mem_size 	: natural := 8;


	type mem_ram_t is array (0 to (mem_size/2)-1) of std_logic_vector(data_width_c - 1 downto 0);

	-- MEMORY IMAGE (Bootloader Program) --
	------------------------------------------------------
	signal mem_ram : mem_ram_t :=
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
  mem_access: process(clock_i)
  begin
    if rising_edge(clock_i) then				
      if (ins_enab_i = '1') then					
        ins_data_o <= mem_ram(to_integer(unsigned(ins_addr_i(log2_mem_size-1 downto 0))));
      end if;
    end if;
  end process mem_access;

  p256 <= mem_ram(256);
  p257 <= mem_ram(257);


end mem_structure;
