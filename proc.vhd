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

begin 
	proc_fetch : process(clock_CI)
	 begin
		if (rising_edge(clock_CI)) then			
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
        clock_i  	 => clock_i,
        ins_addr_i => ins_addr,
        ins_enab_i => ins_enab,
        ins_data_o => ins_data	
        );
          
	-- ctrl ----------------------------------------------------------------------------------------------------
  ctrl1: ctrl
    port map (
      clock_i         => clock_i,
      reset_i         => reset_i,
      de_ctrl_i       => ,
      of_ctrl_o       => ,
      ex_ctrl_o       => ,
      ma_ctrl_o       => ,
      wb_ctrl_o       => 
      );          
	
end proc_behaviour;
