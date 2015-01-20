-- ########################################################
-- #         << ATLAS Project - OpCode Decoder >>         #
-- # **************************************************** #
-- #  OpCode (instruction) decoding unit.                 #
-- # **************************************************** #
-- #  Last modified: 28.11.2014                           #
-- # **************************************************** #
-- #  by Stephan Nolting 4788, Hanover, Germany           #
-- ########################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_package.all;

entity pred_dec is
  port	(
        instr_i         : in  std_logic_vector(data_width_c-1 downto 0); -- instruction input
        instr_adr_i     : in  std_logic_vector(data_width_c-1 downto 0); -- corresponding address
		    is_branch_o     : out std_logic; 
        pred_adr_o      : out std_logic_vector(data_width_c-1 downto 0)
      );
END PRED_DEC;

ARCHITECTURE PRED_DEC_STRUCTURE OF PRED_DEC IS

	
BEGIN

   


end PRED_DEC_STRUCTURE;
