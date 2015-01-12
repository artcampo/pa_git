
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_package.all;

entity ctrl is
  port	(
    clock_i           : in  std_logic; -- global clock
    reset_i           : in  std_logic; -- global reset

    instr_mem_i       : in  std_logic_vector(data_width_c-1 downto 0); -- instruction input
    de_ctrl_i         : in  std_logic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
    ra_de_i           : in  std_logic_vector(data_width_c-1 downto 0);
    rb_de_i           : in  std_logic_vector(data_width_c-1 downto 0);
    rc_de_i           : in  std_logic_vector(data_width_c-1 downto 0);
    rd_ex             : in  std_logic_vector(data_width_c-1 downto 0);

    inst_pc_o         : out std_logic_vector(data_width_c-1 downto 0);
    instr_fe_o        : out std_logic_vector(data_width_c-1 downto 0); -- instruction fetched
    ex_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); -- ex stage control
    ma_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); -- ma stage control
    wb_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0);  -- wb stage control
    pc_from_fe_o      : out std_logic_vector(data_width_c-1 downto 0);
    ra_de_ex_o        : out std_logic_vector(data_width_c-1 downto 0);
    rb_de_ex_o        : out std_logic_vector(data_width_c-1 downto 0);
    rc_ex_ma_o        : out std_logic_vector(data_width_c-1 downto 0);
    rd_ex_ma_o        : out std_logic_vector(data_width_c-1 downto 0);
    rd_ma_wb_o        : out std_logic_vector(data_width_c-1 downto 0)
    );
end ctrl;

architecture ctrl_structure of ctrl is

  signal ins_addr       : std_logic_vector(data_width_c-1 downto 0); -- pc

  -- pipeline register --
  signal de_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);
  signal ex_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);
  signal ma_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);
  signal wb_ctrl       : std_logic_vector(ctrl_width_c-1 downto 0);

  
  --signal rb_ex         : std_logic_vector(data_width_c-1 downto 0);
  signal rc_ex_ma         : std_logic_vector(data_width_c-1 downto 0);
  signal rc_de_ex         : std_logic_vector(data_width_c-1 downto 0);
  signal rd_ex_ma      : std_logic_vector(data_width_c-1 downto 0);
  
  -- system enable/start-up control --
  signal sys_enable    : std_logic;
  signal start         : std_logic;
  signal sleep         : std_logic;
	
begin

	inc_pc : process(clock_i)
	 begin
		if (rising_edge(clock_i)) then			
			if (reset_i = '1') then				 
				ins_addr <= (others => '0');
			else
        ins_addr <= std_logic_vector(unsigned(ins_addr)+1);
			end if;			
		end if;
	end process;
  
  inst_pc_o <= ins_addr;
  
 -- Stage 1:instruction fetch ------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
  fe_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        instr_fe_o <= ( others => '0');
      else
        instr_fe_o <= instr_mem_i;
      end if;
    end if;
  end process fe_stage;

  
 -- Stage 2: decode/ operand fetch ------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
  de_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        de_ctrl	    <= (0 => '1', others => '0');
      else
        de_ctrl     <= de_ctrl_i;
        ra_de_ex_o  <= ra_de_i;
        rb_de_ex_o  <= rb_de_i;
        rc_de_ex    <= rc_de_i;
      end if;
    end if;
  end process de_stage;
	 
 -- Stage 3: Execution ----------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
  ex_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        ex_ctrl	 <= (0 => '1', others => '0');
      else
        rd_ex_ma_o  <= rd_ex;
        rd_ex_ma    <= rd_ex;
        rc_ex_ma    <= rc_de_ex;
        ex_ctrl     <= de_ctrl;
      end if;
    end if;
  end process ex_stage;

     -- output --
  ex_ctrl_o  <= ex_ctrl;
  rc_ex_ma_o <= rc_ex_ma;

   
   -- Stage 4: Memory Access ------------------------------------------------------------------------------
   -- --------------------------------------------------------------------------------------------------------
  ma_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        ma_ctrl <= (0 => '1', others => '0');
      else
        rd_ma_wb_o <= rd_ex_ma; 
        ma_ctrl    <= ex_ctrl;
      end if;
    end if;
  end process ma_stage;

  -- output --
  ma_ctrl_o <= ma_ctrl;
   
   

   -- Stage 5: Write Back ---------------------------------------------------------------------------------
   -- --------------------------------------------------------------------------------------------------------
  wb_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        wb_ctrl <= (0 => '1', others => '0');
      else
        wb_ctrl <= ma_ctrl;
     end if;
    end if;
  end process wb_stage;

  -- output --
  wb_ctrl_o <= wb_ctrl;
	

end ctrl_structure;
