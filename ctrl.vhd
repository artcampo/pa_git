
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
    cond_de_i         : in  std_logic;
    rd_ex             : in  std_logic_vector(data_width_c-1 downto 0);
    data_ma_i         : in  std_logic_vector(data_width_c-1 downto 0);

    inst_pc_o         : out std_logic_vector(data_width_c-1 downto 0);
    instr_fe_o        : out std_logic_vector(data_width_c-1 downto 0); -- instruction fetched
    instr_fe_de_o     : out std_logic_vector(data_width_c-1 downto 0);
    de_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); -- de stage control
    ex_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); -- ex stage control
    ma_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); -- ma stage control
    wb_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0);  -- wb stage control
    pc_fe_de_o        : out std_logic_vector(data_width_c-1 downto 0);
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

  
  signal instr_fe      : std_logic_vector(data_width_c-1 downto 0);
  signal cond_de_ex    : std_logic;
  signal rc_ex_ma      : std_logic_vector(data_width_c-1 downto 0);
  signal rc_de_ex      : std_logic_vector(data_width_c-1 downto 0);
  signal rd_ex_ma      : std_logic_vector(data_width_c-1 downto 0);
  
  -- system enable/start-up control --
  signal sys_enable    : std_logic;
  signal start         : std_logic;
  signal sleep         : std_logic;
  
  -- signals affecting whole pipeline
  signal stall         : std_logic;
  signal br_shadow     : std_logic;
  
	
begin

  compute_stall: process (de_ctrl, ex_ctrl)
  begin    
    if( ( (de_ctrl(ctrl_ra_c) = '1' and unsigned(de_ctrl(ctrl_ra_2_c downto ctrl_ra_0_c)) = unsigned(ex_ctrl(ctrl_rd_2_c downto ctrl_rd_0_c))) 
           or (de_ctrl(ctrl_rb_c) = '1' and unsigned(de_ctrl(ctrl_rb_2_c downto ctrl_rb_0_c)) = unsigned(ex_ctrl(ctrl_rd_2_c downto ctrl_rd_0_c))) 
           ) 
           and (ex_ctrl(ctrl_use_mem_c) = '1' and ex_ctrl(ctrl_rd_c) = '1')) then
      stall <='1';
    else
      stall <= '0';
    end if;
  end process compute_stall;
  
  compute_br_shadow: process (ex_ctrl, de_ctrl, cond_de_ex)
  begin    
    if(ex_ctrl(ctrl_is_branch_c) = '1' and 
        ((de_ctrl(ctrl_branch_cond_1_c downto ctrl_branch_cond_0_c) = br_unconditional)
        or
         (de_ctrl(ctrl_branch_cond_1_c downto ctrl_branch_cond_0_c) = br_unconditional 
          and de_ctrl(ctrl_branch_cond_1_c) = cond_de_ex)
        )) then
      br_shadow <='1';
    else
      br_shadow <= '0';
    end if;
  end process compute_br_shadow;  
  
 -- Stage 1:instruction fetch ------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
  fe_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        ins_addr      <= (others => '0');
        instr_fe      <= (others => '0');
        inst_pc_o     <= (others => '0');
        instr_fe_o    <= (others => '0');
      else
        if(stall = '0') then
          instr_fe      <= instr_mem_i;
          if(br_shadow = '0') then
            ins_addr   <= std_logic_vector(unsigned(ins_addr)+1);
            inst_pc_o  <= std_logic_vector(unsigned(ins_addr)+1);
          else
            ins_addr   <= rd_ex;
            inst_pc_o  <= rd_ex;
          end if;
          instr_fe_o <= instr_mem_i;
        end if;
      end if;
    end if;
  end process fe_stage;

  
  
 -- Stage 2: decode/ operand fetch ------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
  de_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        instr_fe_de_o <= (others => '0');
      else
        if (stall = '0') then
          if(br_shadow = '0') then
            instr_fe_de_o <= instr_fe;
            pc_fe_de_o    <= ins_addr;
          else
            instr_fe_de_o <= (others => '0');
          end if;
          if(de_ctrl(ctrl_nop_c) = '0' ) then
            ra_de_ex_o  <= ra_de_i;
            rb_de_ex_o  <= rb_de_i;
            rc_de_ex    <= rc_de_i;
            cond_de_ex  <= cond_de_i;
          else
            ra_de_ex_o  <= (others => '0');   -- nop explicit datapath info
            rb_de_ex_o  <= (others => '0');   -- nop explicit datapath info
            rc_de_ex    <= (others => '0');   -- nop explicit datapath info        
          end if;
        end if;
      end if;
    end if;
  end process de_stage;
  de_ctrl_o <= de_ctrl;
  de_ctrl     <= de_ctrl_i;
	 
 -- Stage 3: Execution ----------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
  ex_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        ex_ctrl	 <= (0 => '1', others => '0');
      else
        if (stall = '0') then
          if(br_shadow = '0') then
            ex_ctrl     <= de_ctrl;
          else
            ex_ctrl     <= (0 => '1', others => '0');
          end if;
          if(ex_ctrl(ctrl_nop_c) = '0') then
            rd_ex_ma_o  <= rd_ex;
            rd_ex_ma    <= rd_ex;
            rc_ex_ma    <= rc_de_ex;
          else
            rd_ex_ma_o  <= (others => '0');   -- nop explicit datapath info
            rd_ex_ma    <= (others => '0');   -- nop explicit datapath info
            rc_ex_ma    <= (others => '0');   -- nop explicit datapath info
          end if;
        else
            -- stall: insert nop
            ex_ctrl	 <= (0 => '1', others => '0');
            rd_ex_ma_o  <= (others => '0');   -- nop explicit datapath info
            rd_ex_ma    <= (others => '0');   -- nop explicit datapath info
            rc_ex_ma    <= (others => '0');   -- nop explicit datapath info
        end if;        
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
        if(ma_ctrl(ctrl_nop_c) = '0') then
          if (ma_ctrl(ctrl_use_mem_c) = '1' and ma_ctrl(ctrl_rd_c) = '1') then
            rd_ma_wb_o <= data_ma_i;
          else
            rd_ma_wb_o <= rd_ex_ma;
          end if;
        else
          rd_ma_wb_o <= (others => '0');   -- nop explicit datapath info
        end if;
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
