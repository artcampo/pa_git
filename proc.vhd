library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.proc_package.all;


entity proc is
	PORT 
	(
		Clock_CI			: in   std_logic; 
		Reset				: in   std_logic
	);
end proc;

architecture proc_behaviour of proc is



	signal Ins_Addr           : std_logic_vector(15 downto 0);	
	signal Ins_Data           : std_logic_vector(15 downto 0);	
	signal Ins_Enab           : std_logic := '1';
	

begin 
	proc_fetch : process(Clock_CI)
	 begin
		if (rising_edge(Clock_CI)) then			
			if (Reset = '1') then				 
				 Ins_Addr <= (others => '0');
			else
				Ins_Addr <= std_logic_vector(unsigned(Ins_Addr)+1);
			end if;			
		end if;
	end process;					


	-- mem ----------------------------------------------------------------------------------------------------
		Mem1: mem
			port map (
					Clock_CI 	=> Clock_CI,
					Ins_Addr_DI => Ins_Addr,
					Ins_Enab_DI => Ins_Enab,
					Ins_Data_DO => Ins_Data	
					);
	
end proc_behaviour;
