LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_textio.all;

LIBRARY std;
USE std.textio.all;

use work.proc_package.all;
use work.tb_package.all;

entity tb_ALU IS
end entity tb_ALU;

ARCHITECTURE testbench OF tb_ALU IS


-- Common signals
FILE     vectorFile: TEXT OPEN READ_MODE is "vectorfile_alu.txt";
SIGNAL   Rst: 				std_logic;
SIGNAL 	TestClk: 		std_logic := '0';
CONSTANT ClkPeriod: 		TIME := 10 ns;
SIGNAL   VerifySignal:	std_logic := '0';

-- In signals
signal op1: 					std_logic_vector(15 downto 0) := (others => '0');
signal op2: 					std_logic_vector(15 downto 0) := (others => '0');
signal sel: 					std_logic_vector(1 downto 0) := (others => '0');
	
-- Out signals
signal res: 					std_logic_vector(15 downto 0) := (others => '0');
		
-- check
signal check_res: 			std_logic_vector(15 downto 0) := (others => '0');





BEGIN

-- Free running test clock
  TestClk <= NOT TestClk AFTER ClkPeriod/2;


-- Instance of design being tested
  test_ALU: ALU PORT MAP (	op1 => op1,
									op2 => op2,
									sel => sel,
									res => res
								  );

  readVec: PROCESS
	VARIABLE 	VectorLine: 	LINE;
	VARIABLE 	VectorValid: 	BOOLEAN;
	VARIABLE   	space: 			CHARACTER;
	VARIABLE 	vRst: 			STD_LOGIC;
	VARIABLE 	vVerify:			std_logic;

	-- In VARIABLES
	VARIABLE vop1: 					std_logic_vector(15 downto 0);
	VARIABLE vop2: 					std_logic_vector(15 downto 0);
	VARIABLE vsel: 					std_logic_vector(1 downto 0);
		
	
	-- check
	VARIABLE vcheck_res: 			std_logic_vector(15 downto 0);
	
	

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

		op1 <= vop1;
		op2 <= vop2;
		sel <= vsel;
		check_res <= vcheck_res;
	
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
      IF check_res /= res THEN
        write(ErrorMsg, STRING'("Vector failed: check_res "));
        write(ErrorMsg, now);
		  write(ErrorMsg, STRING'(" -- is: "));
		  write(ErrorMsg, res );
		  write(ErrorMsg, STRING'(" should: "));
		  write(ErrorMsg, check_res);		  
        writeline(output, ErrorMsg);
      END IF;
    END IF;
  END PROCESS;                        
END testbench;
	 