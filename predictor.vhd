library ieee ;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.proc_package.all;

-----------------------------------------------------

entity predictor is
generic(k: natural:=2; bitsPc: natural:= 4; hrt_size: natural := 2; pt_size: natural := 4);
port(	
	PC_predict:					in  std_logic_vector(data_width_c - 1 downto 0);
	PC_update:					in  std_logic_vector(data_width_c - 1 downto 0);
	update:							in  std_logic;
	branch_outcome:			in  std_logic;
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
		counter: 		in   std_logic_vector(1 downto 0);	
		prediction:	out  std_logic
	);
end component;

component satOut is
	port(	
		counter: 		in   std_logic_vector(1 downto 0);	
		increment:	in   std_logic;	
		newCounter: out  std_logic_vector(1 downto 0)	
	);
end component;

-----------------------------------------------------

   -- define the states of FSM model

	type HRT_t is array ((hrt_size - 1) downto 0 ) of std_logic_vector (k - 1 downto 0);
	type PT_t  is array ((pt_size  - 1) downto 0 ) of std_logic_vector (1 	  downto 0);
	signal HRT: HRT_t := (others => (others => '0'));
	signal PT:   PT_t := (others => (others => '0'));
	
  type HRT_ta is array ((hrt_size - 1) downto 0 ) of std_logic_vector (15 downto 0);
  signal HRT_add: HRT_ta := (others => (others => '0'));
  
  
	signal HR: 					    std_logic_vector (k - 1 downto 0) := (others => '0');
	signal counter: 			  std_logic_vector (1     downto 0) := (others => '0');
	signal HR_new: 				  std_logic_vector (k - 1 downto 0) := (others => '0');
	signal HR_updt: 				std_logic_vector (k - 1 downto 0) := (others => '0');
	signal counter_updt_in: std_logic_vector (1     downto 0) := (others => '0');
	signal counter_updt_out:std_logic_vector (1     downto 0) := (others => '0');
	
  signal seed: 					  std_logic_vector (4 downto 0) := (others => '0');
  signal seed_inc: 			  std_logic_vector (1 downto 0) := (others => '0');
  signal index: 					std_logic_vector (k - 1 downto 0) := (others => '0');
  signal index_update: 		std_logic_vector (k - 1 downto 0) := (others => '0');

 -----------------------------------------------------	
	
begin

	satCounterPred : satIn port map(	counter 		=> counter,
												prediction 	=> taken
												);
												
	satCounterUpdt : satOut port map(increment	=> branch_outcome, 												
												counter 		=> counter_updt_in,												
												newCounter 	=> counter_updt_out
												);																	

	HR 					    <= HRT(to_integer(unsigned(index)));			
	counter 				<= PT (to_integer(unsigned(HR)));				 	
	
	HR_updt 				<= HRT(to_integer(unsigned(index_update)));	
	counter_updt_in	<= PT (to_integer(unsigned(HR_updt)));			

	HR_new		 		  <= HR_updt(k - 2 downto 0) & branch_outcome;
	
  
-- Compute index for predict
process (PC_predict, HRT_add, seed)
begin
  if   (HRT_add(0) = PC_predict) then
    index <= "00";
  elsif(HRT_add(1) = PC_predict) then
    index <= "01";
  elsif(HRT_add(2) = PC_predict) then
    index <= "10";
  elsif(HRT_add(3) = PC_predict) then
    index <= "11";
  else
    index <= seed(1 downto 0);
  end if;
end process;	

process (PC_update, HRT_add, seed)
begin
  if   (HRT_add(0) = PC_update) then
    index_update <= "00";
  elsif(HRT_add(1) = PC_update) then
    index_update <= "01";
  elsif(HRT_add(2) = PC_update) then
    index_update <= "10";
  elsif(HRT_add(3) = PC_update) then
    index_update <= "11";
  else
    index_update <= seed(1 downto 0);
  end if;
end process;	
		
-- Apply reset
process (clock, reset)
 begin
	  if (reset = '1') then   
      HRT_add <= (others => (others => '0'));    
			HRT     <= (others => (others => '0'));
			PT      <= (others => (others => '0'));
      seed    <= "00000";
	  elsif (clock'event and clock='1' )  then          
      seed <= std_logic_vector(unsigned(seed)+unsigned(seed_inc));
      seed_inc <= std_logic_vector(unsigned(seed_inc)+1);
			if (update='1') then
				PT     (to_integer(unsigned(HR_updt))) 	   <= counter_updt_out;
				HRT    (to_integer(unsigned(index_update)))<= HR_new;	
        HRT_add(to_integer(unsigned(index_update)))<= PC_update;	
			end if;
	  end if;
 end process;	

end Structure;

-----------------------------------------------------
