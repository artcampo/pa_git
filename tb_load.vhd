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
SIGNAL   Rst: 				 std_logic;
SIGNAL 	 TestClk: 		 std_logic := '0';
CONSTANT ClkPeriod: 	 TIME := 10 ns;
constant numberCycles: natural := 15;

BEGIN

  -- Free running test clock
  TestClk <= NOT TestClk AFTER ClkPeriod/2;


  -- Instance of design being tested
  test_load: proc PORT MAP (clock_i,
                            reset_i
                            );
  
  -- reset processor
  Rst <= '1';
  WAIT FOR ClkPeriod;
	
  -- perform execution
  Rst <= '0';
  WAIT FOR ClkPeriod*numberCycles;

  --Check here
  if(p256 /= "500")
      REPORT "Simulation complete"
      SEVERITY NOTE;
  else 
        write(ErrorMsg, STRING'(" Should: "));
        write(ErrorMsg, "500");		  
        writeline(output, ErrorMsg);
   end if
                        
END testbench;
	 