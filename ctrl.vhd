
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
  signal stall_load    : std_logic;
  signal stall_store   : std_logic;  
  
  -- predictor signals
	signal branch_taken         : std_logic:= '1';
  signal branch_taken2         : std_logic:= '1';
  signal pred_taken_fe_de     : std_logic;
  signal pred_taken_de_ex     : std_logic;
  signal pred_inst_addr_fe_de : std_logic_vector(data_width_c-1 downto 0);-- pc of branch instr
  signal pred_inst_addr_de_ex : std_logic_vector(data_width_c-1 downto 0);-- pc of branch instr
  signal pred_othr_addr       : std_logic_vector(data_width_c-1 downto 0):= (others => '0');	
  signal pred_othr_addr_fe_de : std_logic_vector(data_width_c-1 downto 0); -- shadow branch
  signal pred_othr_addr_de_ex : std_logic_vector(data_width_c-1 downto 0); -- shadow branch
	signal pred_updt            : std_logic;
  signal pred_adr             : std_logic_vector(data_width_c-1 downto 0):= (others => '0'); -- pc of target
  signal is_branch            : std_logic;
  signal branch_outcome       : std_logic;
  
begin

  prediction_decoder: pred_dec
    port map (
       instr_i         => instr_mem_i,
       instr_adr_i     => ins_addr,
       is_branch_o     => is_branch,
       pred_adr_o      => pred_adr
       );

  branch_predictor: predictor
    port map (
      PC_predict      => ins_addr,
      PC_update       => pred_inst_addr_de_ex,
      update          => pred_updt,
      branch_outcome  => branch_outcome,
      clock           => clock_i,
      reset           => reset_i,
      taken           => branch_taken
      );			 

  compute_stall: process (de_ctrl, ex_ctrl)
  begin    
    if( (     (de_ctrl(ctrl_ra_c) = '1' and (unsigned(de_ctrl(ctrl_ra_2_c downto ctrl_ra_0_c)) = unsigned(ex_ctrl(ctrl_rd_2_c downto ctrl_rd_0_c)))) 
           or (de_ctrl(ctrl_rb_c) = '1' and (unsigned(de_ctrl(ctrl_rb_2_c downto ctrl_rb_0_c)) = unsigned(ex_ctrl(ctrl_rd_2_c downto ctrl_rd_0_c)))) 
           or (de_ctrl(ctrl_rc_c) = '1' and (unsigned(de_ctrl(ctrl_rc_2_c downto ctrl_rc_0_c)) = unsigned(ex_ctrl(ctrl_rd_2_c downto ctrl_rd_0_c)))) 
           ) 
           and (ex_ctrl(ctrl_use_mem_c) = '1' and ex_ctrl(ctrl_rd_c) = '1')) then
      stall_load <='1';
    else
      stall_load <= '0';
    end if;
  end process compute_stall;
  
  compute_stall_store: process (de_ctrl, ex_ctrl)
  begin    
    if( de_ctrl(ctrl_rc_c) = '1' 
        and (unsigned(de_ctrl(ctrl_rc_2_c downto ctrl_rc_0_c)) = unsigned(ex_ctrl(ctrl_rd_2_c downto ctrl_rd_0_c))) 
        and (de_ctrl(ctrl_use_mem_c) = '1' and ex_ctrl(ctrl_rd_c) = '1')) then
      stall_store <='1';
    else
      stall_store <= '0';
    end if;
  end process compute_stall_store;

  stall <= stall_load or stall_store;
  
  compute_br_shadow: process (ex_ctrl, cond_de_ex)
  begin    
    if(ex_ctrl(ctrl_is_branch_c) = '1') then
        if 
          (
           (    (ex_ctrl(ctrl_branch_cond_1_c downto ctrl_branch_cond_0_c) /= br_unconditional)
            and (ex_ctrl(ctrl_branch_cond_1_c) = cond_de_ex)
          )) then
        -- jump taken
        branch_outcome <= '1';
        if (pred_taken_de_ex = '1') then
          br_shadow <='0';
        else
          br_shadow <='1';
        end if;
      else
        branch_outcome <= '0';
        -- jump not taken
        if (pred_taken_de_ex = '1') then
          br_shadow <='1';
        else
          br_shadow <='0';
        end if;
      end if;
    else
      -- not a branch
      br_shadow <='0';
    end if;
  end process compute_br_shadow;  
  
  -- predictor --
  --compute this
	 --pred_updt
  compute_pred_updt: process(ex_ctrl)
  begin
      if (ex_ctrl(ctrl_is_branch_c) = '1' ) then				
        pred_updt <= '1';
      else
        pred_updt <= '0';
      end if;
  end process compute_pred_updt;
 
  compute_mispredict_target: process(branch_taken, ins_addr, pred_adr)
  begin
    if (branch_taken = '1') then				
      pred_othr_addr <= std_logic_vector(unsigned(ins_addr) + 1); -- word increment
    else
      pred_othr_addr <= pred_adr;
    end if;
  end process compute_mispredict_target;	
  
 -- Stage 1:instruction fetch ------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
  fe_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        ins_addr      <= (others => '0');
        instr_fe_de_o <= (others => '0');
      else
        if(stall = '0') then    
          pred_inst_addr_fe_de <= ins_addr;
          pred_othr_addr_fe_de <= pred_othr_addr;
          pred_taken_fe_de     <= branch_taken;
          if(br_shadow = '0') then
            instr_fe_de_o        <= instr_mem_i;
            if(branch_taken = '1' and is_branch = '1') then
              ins_addr    <= pred_adr;
              pc_fe_de_o  <= pred_adr;
            else
              ins_addr   <= std_logic_vector(unsigned(ins_addr)+1);
              pc_fe_de_o  <= std_logic_vector(unsigned(ins_addr)+1);
            end if;
          else
            -- we had a branch / mispredictionv
            instr_fe_de_o <= (others => '0');
            ins_addr      <= pred_othr_addr_de_ex;
            pc_fe_de_o    <= pred_othr_addr_de_ex;
          end if;

        end if;
      end if;
    end if;
  end process fe_stage;

  inst_pc_o   <= ins_addr; 
         
  
 -- Stage 2: decode/ operand fetch ------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
  de_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (stall = '0' and reset_i = '0') then
        if(de_ctrl_i(ctrl_nop_c) = '0' ) then
          ra_de_ex_o            <= ra_de_i;
          rb_de_ex_o            <= rb_de_i;
          rc_de_ex              <= rc_de_i;
          cond_de_ex            <= cond_de_i;
          pred_inst_addr_de_ex  <= pred_inst_addr_fe_de;
          pred_othr_addr_de_ex  <= pred_othr_addr_fe_de;
          pred_taken_de_ex      <= pred_taken_fe_de;
        else
          ra_de_ex_o  <= (others => '0');   -- nop explicit datapath info
          rb_de_ex_o  <= (others => '0');   -- nop explicit datapath info
          rc_de_ex    <= (others => '0');   -- nop explicit datapath info        
          cond_de_ex  <= '0';               -- nop explicit datapath info  
        end if;
      end if;
    end if;
  end process de_stage;
  
  
  de_ctrl_o <= de_ctrl;
  
  de_update: process (de_ctrl_i, stall, reset_i, br_shadow)
  begin
    if (reset_i = '1') then
      de_ctrl   <= (0 => '1', others => '0');
    else 
      if (stall = '0' and reset_i = '0') then
        if(br_shadow = '1') then
          de_ctrl   <= (0 => '1', others => '0');
        else
          de_ctrl   <= de_ctrl_i ;
        end if;      
      end if;
    end if;
  end process de_update;

   
 -- Stage 3: Execution ----------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------------------------------
  ex_stage: process (clock_i)
  begin
    if rising_edge(clock_i) then
      if (reset_i = '1') then
        ex_ctrl	 <= (0 => '1', others => '0');
      else
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
