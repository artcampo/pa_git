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
		ma_data_i    : in  std_logic_vector(data_width_c-1 downto 0);
		ra_i         : in  std_logic_vector(data_width_c-1 downto 0);
    rb_i         : in  std_logic_vector(data_width_c-1 downto 0);    
		
		ra_o         : out std_logic_vector(data_width_c-1 downto 0);
    rb_o         : out std_logic_vector(data_width_c-1 downto 0)
	);
end fwd;

architecture fwd_behaviour of fwd is
  signal mb : std_logic := '0';
  signal wb : std_logic := '0';
  signal mb2 : std_logic := '0';
  signal wb2 : std_logic := '0';  
begin

 -- Bypass, alu-alu and alu-mem  -------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
 process (ex_ctrl_i, ma_ctrl_i, wb_ctrl_i, ra_i, rb_i, ma_data_i, wb_data_i) is
 begin  
  
  --By pass form ma to ex ---------------------------------------------------------------------------------------
 -- rd provider vs ra consummer
  if ((ma_ctrl_i(ctrl_rd_c) = '1') and ((ex_ctrl_i(ctrl_ra_c) = '1'))) then  
    if 	(ma_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c) = ex_ctrl_i(ctrl_ra_2_c downto ctrl_ra_0_c) ) then
      ra_o <= ma_data_i;
      mb <= '1';
      wb <= '0';
    end if;
  elsif ((wb_ctrl_i(ctrl_rd_c) = '1') and ((ex_ctrl_i(ctrl_ra_c) = '1'))) then  
    if 	(wb_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c) = ex_ctrl_i(ctrl_ra_2_c downto ctrl_ra_0_c) ) then
      ra_o <= wb_data_i;
  
      mb <= '0';
      wb <= '1';
    end if;
  else 
    ra_o <= ra_i;
    mb <= '0';
    wb <= '0';
  end if;

   
  -- rd provider vs rb consumer
  if ((ma_ctrl_i(ctrl_rd_c) = '1') and ((ex_ctrl_i(ctrl_rb_c) = '1'))) then  
      if 	(ma_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c) = ex_ctrl_i(ctrl_rb_2_c downto ctrl_rb_0_c) ) then
        rb_o <= ma_data_i;     
        mb2 <= '1';
        wb2 <= '0';
      end if;
      
   elsif ((wb_ctrl_i(ctrl_rd_c) = '1') and ((ex_ctrl_i(ctrl_rb_c) = '1'))) then  
      if 	(wb_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c) = ex_ctrl_i(ctrl_rb_2_c downto ctrl_rb_0_c) ) then
        rb_o <= wb_data_i;      
        mb2 <= '0';
        wb2 <= '1';
      end if;
   else 
    rb_o <= rb_i;
    
        mb2 <= '0';
        wb2 <= '0';
   end if;

   
 end process;
  

  
end fwd_behaviour;
