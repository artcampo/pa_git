library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.proc_package.all;


entity regf is
	PORT 
	(
		clock_CI		 : in   std_logic; 
		reset_I		 : in   std_logic;
		
		wb_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
      of_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
	);
end regf;

architecture regf_behaviour of regf is

  -- register file --
  type   regf_mem_type is array (num_registers - 1 downto 0) of std_logic_vector(data_width_c-1 downto 0);
  signal regf_mem      : regf_mem_type := (others => (others => '0'));

begin 


end regf_behaviour;
