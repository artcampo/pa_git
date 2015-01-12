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
			  data_i          : in   std_logic_vector(data_width_c - 1 downto 0); -- data coming from mem
        rd_i            : in   std_logic_vector(data_width_c - 1 downto 0); -- register to write to mem
       
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





end memg_structure;
