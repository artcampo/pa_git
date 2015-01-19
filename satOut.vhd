library ieee ;
use ieee.std_logic_1164.all;

-----------------------------------------------------

entity satOut is
port(	
	counter: 		in  std_logic_vector(1 downto 0);	
	increment:		in  std_logic;	
	newCounter: 	out  std_logic_vector(1 downto 0)	
	
);
end satOut;

-----------------------------------------------------

architecture Structure of satOut is
   
	signal c:		std_logic:='1';
	signal newc:	std_logic_vector(1 downto 0)	:="00";
	
begin
   
	state_reg: process(counter,increment)
	VARIABLE  sel  :  STD_LOGIC_VECTOR(2 DOWNTO 0);
	begin
	sel := counter & increment;
	CASE sel IS
		 WHEN  "000"  =>  newCounter <= "00";
		 WHEN  "001"  =>  newCounter <= "01";
		 
		 WHEN  "010"  =>  newCounter <= "00";
		 WHEN  "011"  =>  newCounter <= "10";
		 
		 WHEN  "100"  =>  newCounter <= "01";
		 WHEN  "101"  =>  newCounter <= "11";
		 
		 WHEN  "110"  =>  newCounter <= "10";
		 WHEN  "111"  =>  newCounter <= "11";
		 WHEN OTHERS =>  newCounter <= "00";
	  END CASE;

    end process;						  

end Structure;

-----------------------------------------------------
