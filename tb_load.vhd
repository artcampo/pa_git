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
constant numberCycles: natural := 62;

		constant c_p0: std_logic_vector := x"000A";
		constant c_p1: std_logic_vector := x"0001";
		constant c_p2: std_logic_vector := x"003C";
		constant c_p3: std_logic_vector := x"0082";


BEGIN

  -- Free running test clock
  TestClk <= NOT TestClk AFTER ClkPeriod/2;


  -- Instance of design being tested
  test_load: proc PORT MAP (clock_i => TestClk,
                            reset_i => Rst
                            );
  
  
 exec: PROCESS
 variable ErrorMsg: LINE;
 BEGIN
  -- reset processor
  Rst <= '1';
  WAIT FOR ClkPeriod;
	
  -- perform execution
  Rst <= '0';
  WAIT FOR ClkPeriod*numberCycles;

  REPORT "Simulation complete"
  SEVERITY NOTE;
  
  --Check here
  if(p0 /= c_p0) then
		      write(ErrorMsg, STRING'("p0 Should be: "));
		      write(ErrorMsg, c_p0);	
		      write(ErrorMsg, STRING'(" is: "));
		      write(ErrorMsg, p0);		  
		      writeline(output, ErrorMsg);
		  end if;
  
		  if(p1 /= c_p1) then
		      write(ErrorMsg, STRING'("p1 Should be: "));
		      write(ErrorMsg, c_p1);	
		      write(ErrorMsg, STRING'(" is: "));
		      write(ErrorMsg, p1);		  
		      writeline(output, ErrorMsg);
		  end if;
  
		  if(p2 /= c_p2) then
		      write(ErrorMsg, STRING'("p2 Should be: "));
		      write(ErrorMsg, c_p2);	
		      write(ErrorMsg, STRING'(" is: "));
		      write(ErrorMsg, p2);		  
		      writeline(output, ErrorMsg);
		  end if;

		  if(p3 /= c_p3) then
		      write(ErrorMsg, STRING'("p3 Should be: "));
		      write(ErrorMsg, c_p3);	
		      write(ErrorMsg, STRING'(" is: "));
		      write(ErrorMsg, p3);		  
		      writeline(output, ErrorMsg);
		  end if;

   
end process;
                        
END testbench;
	 