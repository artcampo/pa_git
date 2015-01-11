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
FILE     vectorFile: TEXT OPEN READ_MODE is "vectorfile_alu.txt";
SIGNAL   Rst: 				std_logic;
SIGNAL 	 TestClk: 		std_logic := '0';
CONSTANT ClkPeriod: 		TIME := 10 ns;
SIGNAL   VerifySignal:	std_logic := '0';

-- In signals
signal p256           : std_logic_vector(data_width_c - 1 downto 0);
signal p257           : std_logic_vector(data_width_c - 1 downto 0);





BEGIN

-- Free running test clock
  TestClk <= NOT TestClk AFTER ClkPeriod/2;


-- Instance of design being tested
  test_load: load PORT MAP (	clock_i,
                              reset_i
                            );

  readVec: PROCESS
	VARIABLE 	VectorLine: 	LINE;
	VARIABLE 	VectorValid: 	BOOLEAN;
	VARIABLE   	space: 			CHARACTER;
	VARIABLE 	vRst: 			STD_LOGIC;
	VARIABLE 	vVerify:			std_logic;

	-- In VARIABLES
	VARIABLE vp256: 					std_logic_vector(15 downto 0);
	VARIABLE vp257: 					std_logic_vector(15 downto 0);		
	
	

 BEGIN
    WHILE NOT ENDFILE (vectorFile) LOOP
      readline(vectorFile, VectorLine); -- put file data into line

      read(VectorLine, vVerify, good => VectorValid);
      NEXT WHEN NOT VectorValid;
		read(VectorLine, space); read(VectorLine, vRst);
      read(VectorLine, space); read(VectorLine, vop1);
      read(VectorLine, space); read(VectorLine, vop2);
      read(VectorLine, space); read(VectorLine, vsel);
		read(VectorLine, space); read(VectorLine, vcheck_res);


      WAIT FOR ClkPeriod/4;
	   Rst <= vRst;
		VerifySignal<=vVerify;

    
    p256 <= vp256;
    p257 <= vp257;
	
      WAIT FOR (ClkPeriod/4) * 3;
   END LOOP;
	 ASSERT FALSE
      REPORT "Simulation complete"
      SEVERITY NOTE;
   WAIT;
END PROCESS;

-- Process to verify outputs
  verify: PROCESS (TestClk)
  variable ErrorMsg: LINE;
  BEGIN
    IF (TestClk'event AND TestClk = '0' AND VerifySignal = '1') THEN
      IF check_res /= res_o THEN
        write(ErrorMsg, STRING'("Vector failed: check_res "));
        write(ErrorMsg, now);
		  write(ErrorMsg, STRING'(" -- is: "));
		  write(ErrorMsg, res_o );
		  write(ErrorMsg, STRING'(" should: "));
		  write(ErrorMsg, check_res);		  
        writeline(output, ErrorMsg);
      END IF;
    END IF;
  END PROCESS;                        
END testbench;
	 