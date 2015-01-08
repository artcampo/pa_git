
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_package.all;

entity ctrl is
  port	(
        clock_i           : in  std_logic; -- global clock line
        reset_i           : in  std_logic; -- global reset line, sync, high-active

        op_dec_ctrl_i   : in  std_logic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines

        of_ctrl_o   : out std_logic_vector(ctrl_width_c-1 downto 0); 
        ex_ctrl_o   : out std_logic_vector(ctrl_width_c-1 downto 0); 
        ma_ctrl_o   : out std_logic_vector(ctrl_width_c-1 downto 0);
        wb_ctrl_o   : out std_logic_vector(ctrl_width_c-1 downto 0)
      );
end ctrl;

architecture ctrl_structure of ctrl is

  -- pipeline register --
  signal ex_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);
  signal ma_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);
  signal wb_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);

	
begin


end ctrl_structure;
