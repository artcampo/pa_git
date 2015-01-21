library ieee ;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

-----------------------------------------------------

entity predictor is
generic(k: natural:=1; bitsPc: natural:= 1 );
port(	
	PC_predict:						in  std_logic_vector(bitsPc - 1 downto 0);
	PC_update:						in  std_logic_vector(bitsPc - 1 downto 0);
	update:							in  std_logic;
	branch_outcome:				in  std_logic;
	clock:							in  std_logic;
	reset:							in  std_logic;
	-- output
	taken:							out std_logic
);
end predictor;

-----------------------------------------------------

architecture Structure of predictor is

component satIn is
	port(	
		counter: 		in  std_logic_vector(1 downto 0);	
		prediction:		out std_logic
	);
end component;

component satOut is
	port(	
		counter: 		in  std_logic_vector(1 downto 0);	
		increment:		in  std_logic;	
		newCounter: 	out  std_logic_vector(1 downto 0)	
	);
end component;

-----------------------------------------------------

   -- define the states of FSM model

	type HRT_t is array ((2**(bitsPc)) - 1 downto 0 ) of std_logic_vector (k - 1 downto 0);
	type PT_t  is array ((2**     (k)) - 1 downto 0 ) of std_logic_vector (1 	  downto 0);
	signal HRT: HRT_t := (others => (others => '0'));
	signal PT:   PT_t := (others => (others => '0'));
	
	signal HR: 					std_logic_vector (k  - 1 downto 0) := (others => '0');
	signal counter: 			std_logic_vector (1 downto 0) := (others => '0');
	signal setCounterPred:	std_logic:='1';		

	
	signal HR_new: 				 std_logic_vector (k - 1 downto 0) := (others => '0');
	
	signal HR_updt: 				 std_logic_vector (k - 1 downto 0) := (others => '0');
	signal counter_updt_in: 	 std_logic_vector (1 downto 0) := (others => '0');
	signal counter_updt_out: 	 std_logic_vector (1 downto 0) := (others => '0');
	
	signal PC_predict_synch:			std_logic_vector(bitsPc - 1 downto 0) := (others => '0');
	signal PC_update_synch:			std_logic_vector(bitsPc - 1 downto 0) := (others => '0');	
	signal branch_outcome_synch:	std_logic := '0';	
	
	
-----------------------------------------------------	
	
begin

	satCounterPred : satIn port map(	counter 		=> counter,
												prediction 	=> taken
												);
												
	satCounterUpdt : satOut port map(increment	=> branch_outcome_synch, 												
												counter 		=> counter_updt_in,												
												newCounter 	=> counter_updt_out
												);																	

	HR 					<= HRT(to_integer(unsigned(PC_predict_synch)));			
	counter 				<= PT (to_integer(unsigned(HR)));				 	
	
	HR_updt 				<= HRT(to_integer(unsigned(PC_update)));	
	counter_updt_in	<= PT (to_integer(unsigned(HR_updt)));			

	HR_new		 		<= HR_updt(k - 2 downto 0) & branch_outcome;
	
		
-- Apply reset
process (clock, reset)
 begin
	  if (reset = '1') then           
			HRT <= (others => (others => '0'));
			PT  <= (others => (others => '0'));
	  elsif (clock'event and clock='1' )  then          

			--taken 					<= taken_out;
			if (update='1') then
				PT (to_integer(unsigned(HR_updt))) 	<= counter_updt_out;
				HRT(to_integer(unsigned(PC_update)))<= HR_new;				
			end if;

	  end if;
 end process;	

end Structure;

-----------------------------------------------------
