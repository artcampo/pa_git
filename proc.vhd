library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.proc_package.all;


entity proc is
	PORT 
	(
		clock_i			: in   std_logic; 
		reset_i			: in   std_logic
	);
end proc;

architecture proc_behaviour of proc is

	signal ins_addr           : std_logic_vector(data_width_c - 1 downto 0);	
	signal ins_data           : std_logic_vector(data_width_c - 1 downto 0);	
	signal ins_enab           : std_logic := '1';	

  signal de_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal of_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal ex_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal ma_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal wb_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  
begin 
	proc_fetch : process(clock_i)
	 begin
		if (rising_edge(clock_i)) then			
			if (reset_I = '1') then				 
				 ins_addr <= (others => '0');
			else
				ins_addr <= std_logic_vector(unsigned(ins_addr)+1);
			end if;			
		end if;
	end process;					


	-- mem ----------------------------------------------------------------------------------------------------
  Mem1: mem
    port map (
        clock_i  	  => clock_i,
        Ins_Addr_DI => ins_addr,
        Ins_Enab_DI => ins_enab,
        Ins_Data_DO => ins_data	
        );
          
	-- ctrl ----------------------------------------------------------------------------------------------------
  ctrl1: ctrl
    port map (
      clock_i         => clock_i,
      reset_i         => reset_i,
		
      de_ctrl_i       => de_ctrl,
      of_ctrl_o       => of_ctrl,
      ex_ctrl_o       => ex_ctrl,
      ma_ctrl_o       => ma_ctrl,
      wb_ctrl_o       => wb_ctrl
      );          
	
end proc_behaviour;
