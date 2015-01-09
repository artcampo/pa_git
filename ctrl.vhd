
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_package.all;

entity ctrl is
  port	(
    clock_i           : in  std_logic; -- global clock
    reset_i           : in  std_logic; -- global reset

    de_ctrl_i         : in  std_logic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
    --instr_i           : in  std_logic_vector(data_width_c-1 downto 0); -- instruction input

    of_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); -- of stage control
    ex_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); -- ex stage control
    ma_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); -- ma stage control
    wb_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0);  -- wb stage control
    pc_from_of_o      : out std_logic_vector(data_width_c-1 downto 0) 
    );
end ctrl;

architecture ctrl_structure of ctrl is

  -- pipeline register --
  signal ex_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);
  signal ma_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);
  signal wb_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);

  -- system enable/start-up control --
  signal sys_enable    : std_logic;
  signal start         : std_logic;
  signal sleep         : std_logic;

  
	
begin


  
 -- Stage 1: operand fetch ------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
    of_ctrl_o <= de_ctrl_i;

	 
	 
 -- Stage 2: Execution ----------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
    ex_stage: process (clock_i)
    begin
      if rising_edge(clock_i) then
        if (reset_i = '1') then
          ex_ctrl	 <= (others => '0');
        else
          ex_ctrl  <= de_ctrl_i;
        end if;
      end if;
    end process ex_stage;

	     -- output --
    ex_ctrl_o <= ex_ctrl;

	 
 -- Stage 3: Memory Access ------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
    ma_stage: process (clock_i)
    begin
      if rising_edge(clock_i) then
        if (reset_i = '1') then
          ma_ctrl <= (others => '0');
        else
          ma_ctrl <= ex_ctrl;
        end if;
      end if;
    end process ma_stage;

    -- output --
    ma_ctrl_o <= ma_ctrl;
	 
	 

 -- Stage 4: Write Back ---------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
    wb_stage: process (clock_i)
    begin
      if rising_edge(clock_i) then
        if (reset_i = '1') then
          wb_ctrl <= (others => '0');
        else
          wb_ctrl <= ma_ctrl;
       end if;
      end if;
    end process wb_stage;

    -- output --
    wb_ctrl_o <= wb_ctrl;
	

end ctrl_structure;
