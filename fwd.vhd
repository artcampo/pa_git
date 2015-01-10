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
		ra_i        : in  std_logic_vector(data_width_c-1 downto 0);
    rb_i        : in  std_logic_vector(data_width_c-1 downto 0);    
		
		ra_o        : out std_logic_vector(data_width_c-1 downto 0);
    rb_o        : out std_logic_vector(data_width_c-1 downto 0)
	);
end fwd;

architecture fwd_behaviour of fwd is

begin

 -- Bypass, alu-alu and alu-mem  -------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
 process (ex_ctrl_i, ma_ctrl_i, wb_ctrl_i, ra_i, rb_i) is
 begin  
  
  --By pass form ma to ex ---------------------------------------------------------------------------------------
 -- rd provaider vs ra consummer
  if ((ma_ctrl_i(ctrl_rd_c) = not op_not_using_regX) and ((ex_ctrl_i(ctrl_ra_c) = not op_not_using_regX))) then  
      if 	(ma_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c) = ex_ctrl_i(ctrl_ra_2_c downto ctrl_ra_0_c) ) then
        ra_o <= ma_data_i;
      end if;
      
   elsif ((wb_ctrl_i(ctrl_rd_c) = not op_not_using_regX) and ((ex_ctrl_i(ctrl_ra_c) = not op_not_using_regX))) then  
      if 	(wb_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c) = ex_ctrl_i(ctrl_ra_2_c downto ctrl_ra_0_c) ) then
        ra_o <= wb_data_i;
      end if;
   else ra_o <= ra_i;
   end if;

   
  -- rd provaider vs rb consummer
  if ((ma_ctrl_i(ctrl_rd_c) = not op_not_using_regX) and ((ex_ctrl_i(ctrl_rb_c) = not op_not_using_regX))) then  
      if 	(ma_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c) = ex_ctrl_i(ctrl_rb_2_c downto ctrl_rb_0_c) ) then
        rb_o <= ma_data_i;
      end if;
      
   elsif ((wb_ctrl_i(ctrl_rd_c) = not op_not_using_regX) and ((ex_ctrl_i(ctrl_rb_c) = not op_not_using_regX))) then  
      if 	(wb_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c) = ex_ctrl_i(ctrl_rb_2_c downto ctrl_rb_0_c) ) then
        rb_o <= wb_data_i;
      end if;
   else rb_o <= rb_i;
   end if;

   
 end process;
  

  
end fwd_behaviour;
