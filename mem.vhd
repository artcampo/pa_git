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
        data_addr_i     : in   std_logic_vector(data_width_c - 1 downto 0); 
        w_data_i        : in   std_logic_vector(data_width_c - 1 downto 0); -- write data
        w_enable_i      : in   std_logic;
        r_enable_i      : in   std_logic; 
				ins_data_o      : out  std_logic_vector(data_width_c - 1 downto 0);
        data_o          : out  std_logic_vector(data_width_c - 1 downto 0)
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
		000000 => x"6201", -- MOV R1, 1
		000001 => x"6402", -- MOV R2, 2
		000002 => x"6603", -- MOV R3, 3
		000003 => x"5040", -- STR R0(0) <- R1
		000004 => x"5081", -- STR R0(1) <- R2
		000005 => x"50C2", -- STR R0(2) <- R3
		others => x"0000"  -- NOP
		);
    
	------------------------------------------------------
	signal mem_data_ram : mem_ram_t :=
    (
		others => x"DEAD"
 	  );
  
begin

	-- Memory Access - code ---------------------------------------------------------------------------------------
  mem_access: process(ins_addr_i)
  begin			
    if (ins_enab_i = '1') then					
      ins_data_o <= mem_ram(to_integer(unsigned(ins_addr_i(log2_mem_size-1 downto 0))));
    end if;
  end process mem_access;

  -- Memory read - data ---------------------------------------------------------------------------------------
  mem_data_read: process(data_addr_i, r_enable_i)
  begin			
    if (r_enable_i = '1') then					
      data_o <= mem_data_ram(to_integer(unsigned(data_addr_i(log2_mem_size-1 downto 0))));
    end if;
  end process mem_data_read;  

  -- Memory write - data ---------------------------------------------------------------------------------------
  mem_data_write: process(clock_i,data_addr_i, r_enable_i)
  begin			
    if (rising_edge(clock_i)) then
      if (w_enable_i = '1') then					
        mem_data_ram(to_integer(unsigned(data_addr_i(log2_mem_size-1 downto 0)))) <= w_data_i;
      end if;
    end if;
  end process mem_data_write;    
  
  -- Used in tb_load
  p0  <= mem_data_ram(0);
  p1  <= mem_data_ram(1);
  p2  <= mem_data_ram(2);


end mem_structure;
