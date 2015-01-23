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

decoder: process(instr_i, instr_adr_i)
  begin
      
    case (instr_i(isa_op1_c downto isa_op2_c)) is
      
      when op_branch_c => -- class 3: branch
        -- -------------------------------------------------------------------	
        is_branch_o <= '1';
        
        case(instr_i(isa_branch_1_c downto isa_branch_0_c)) is
          when op_branch_jmp_c => -- JMP
            pred_adr_o  <= std_logic_vector( unsigned(instr_adr_i) + unsigned(instr_i(isa_jmp_imm_11_c downto isa_jmp_imm_0_c)));
          when op_branch_jne_c => -- JNE
            pred_adr_o  <= std_logic_vector( unsigned(instr_adr_i) + unsigned(instr_i(isa_br_imm_8_c downto isa_br_imm_0_c)));
          when op_branch_je_c => -- JE
            pred_adr_o  <= std_logic_vector( unsigned(instr_adr_i) + unsigned(instr_i(isa_br_imm_8_c downto isa_br_imm_0_c)));          
          when OTHERS => 
            pred_adr_o  <= (others => '0');                  -- all signals disabled
            is_branch_o <= '0';
        end case;
        
      when OTHERS =>       
        pred_adr_o  <= (others => '0');                  -- all signals disabled
        is_branch_o <= '0';
      
    end case;

 end process;   


end PRED_DEC_STRUCTURE;
