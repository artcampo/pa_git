LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_textio.all;

LIBRARY std;
USE std.textio.all;

use work.proc_package.all;
use work.tb_package.all;
use work.tb_load_signals.all;

entity tb_load IS
end entity tb_load;

ARCHITECTURE testbench OF tb_load IS


-- Common signals
SIGNAL   Rst: 				std_logic;
SIGNAL 	 TestClk: 		std_logic := '0';
CONSTANT ClkPeriod: 		TIME := 10 ns;


BEGIN

-- Free running test clock
  TestClk <= NOT TestClk AFTER ClkPeriod/2;


-- Instance of design being tested
  test_load: proc PORT MAP (clock_i,
                            reset_i
                            );
                            
      WAIT FOR ClkPeriod/4;
	   Rst <= vRst;
		VerifySignal<=vVerify;



                        
END testbench;
	 