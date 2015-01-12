library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.proc_package.all;
use work.tb_load_signals.all;

entity memg is
	port	(
				clock_i         : in   std_logic; 
        ma_ctrl_i       : in   std_logic_vector(ctrl_width_c - 1 downto 0); -- ma stage control
			  data_i          : in   std_logic_vector(data_width_c - 1 downto 0); -- data coming from mem
        addr_i          : in   std_logic_vector(data_width_c - 1 downto 0); -- address to access
        rb_i            : in   std_logic_vector(data_width_c - 1 downto 0); -- register to write to mem
       
        data_addr_o     : out  std_logic_vector(data_width_c - 1 downto 0); -- to mem interface
        w_data_o        : out  std_logic_vector(data_width_c - 1 downto 0); 
        w_enable_o      : out  std_logic;
        r_data_o        : out  std_logic_vector(data_width_c - 1 downto 0); 
        r_enable_o      : out  std_logic;   
        r_is_code_o     : out  std_logic;                                   -- '1'=code, '0'=data
        rd_o            : out  std_logic_vector(data_width_c - 1 downto 0)
			);
end memg;

architecture memg_structure of memg is	
  
begin

  rd_o        <= data_i;
  r_is_code_o <= '0';

	mem_request : process(clock_i)
	 begin
		if (rising_edge(clock_i)) then
      if(ma_ctrl_i(ctrl_use_mem_c) = '1') then
        data_addr_o <= addr_i; 
        if (ma_ctrl_i(ctrl_rd_c) = '1') then				 
          -- load
          r_enable_o <= '1';
          w_enable_o <= '0';
        else
          -- store
          r_enable_o <= '0';
          w_enable_o <= '1';
          w_data_o   <= rb_i;
        end if;	
      else
          r_enable_o <= '0';
          w_enable_o <= '0';
      end if;
    end if;
	end process;
  
end memg_structure;
