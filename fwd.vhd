library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.proc_package.all;


entity fwd is
	PORT 
	(
    ex_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
		ma_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
    wb_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
		
		wb_data_i    : in  std_logic_vector(data_width_c-1 downto 0);
		op1_i        : in  std_logic_vector(data_width_c-1 downto 0);
    op2_i        : in  std_logic_vector(data_width_c-1 downto 0);    
		
		op1_o        : out std_logic_vector(data_width_c-1 downto 0);
    op2_o        : out std_logic_vector(data_width_c-1 downto 0)
	);
end fwd;

architecture fwd_behaviour of fwd is


  
begin 


  
  --operand_fetch: process()
  --begin

  --end process operand_fetch;


  
end fwd_behaviour;
