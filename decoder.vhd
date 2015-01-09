library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.proc_package.all;

entity decoder is
	port	(		
			instr_i         : in  std_logic_vector(data_width_c-1 downto 0); -- instruction input
			ctrl_o          : out std_logic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
			imm_o           : out std_logic_vector(data_width_c-1 downto 0)  -- immediate unsigned output
		  );

end entity decoder;


architecture decoder_structure of decoder is
begin  
  
 -- Decoder  -------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
decoder: process(instr_i)
   begin
      -- defaults --
      ctrl_o                                     <= (others => '0');                  -- all signals disabled

	case (instr_i(isa_op1_c downto isa_op2_c)) is
	
	   when "00" => -- class 0: memory access
      -- -------------------------------------------------------------------	
			case(instr_i(isa_mem_load_store_c)) is
				when '0' => -- Load
					ctrl_o(ctrl_rb_is_imm_c) 							   <= '1';
					ctrl_o(ctrl_ra_2_c   downto ctrl_ra_0_c) <=  instr_i(isa_mem_load_ra_2_c  downto isa_mem_load_ra_0_c);			-- operand a register
					ctrl_o(ctrl_rd_2_c   downto ctrl_rd_0_c) <=  instr_i(isa_mem_load_rd_2_c  downto isa_mem_load_rd_0_c); 			-- destination register 
					ctrl_o   	                               <=  instr_i(isa_mem_load_imm_6_c downto isa_mem_load_imm_0_c); 		-- immediate
				
				when '1' => -- Store
					ctrl_o(ctrl_ra_2_c   downto ctrl_ra_0_c) <=  instr_i(isa_mem_store_ra_2_c  downto isa_mem_store_ra_0_c);						-- operand a register
					ctrl_o(ctrl_rb_2_c   downto ctrl_rb_0_c) <=  instr_i(isa_mem_store_rb_2_c  downto isa_mem_store_rb_0_c); 						-- operand b register
					imm_o   													       <=  "000000000" & instr_i(isa_mem_store_imm_6_c downto isa_mem_store_imm_0_c);	-- immediate
			end case;
			
		
		when "01" => -- class 1: arithmetic op
      -- -------------------------------------------------------------------	
			case(instr_i(isa_alu_c)) is
				when '0' => -- Op with immediate
					ctrl_o(ctrl_rb_is_imm_c) 								 <= '1';
					ctrl_o(ctrl_ra_2_c   downto ctrl_ra_0_c) <=  instr_i(isa_alu_imm_ra_2_c downto isa_alu_imm_ra_0_c); 							-- operand a register
					ctrl_o(ctrl_rd_2_c   downto ctrl_rd_0_c) <=  instr_i(isa_alu_imm_rd_2_c downto isa_alu_imm_rd_0_c); 							-- destination register 
					imm_o   													       <=  "00000000000" & instr_i(isa_alu_imm_imm_4_c downto isa_alu_imm_imm_0_c); 	-- immediate
				
				when '1' => -- Op between registers
					ctrl_o(ctrl_ra_2_c   downto ctrl_ra_0_c) <=  instr_i(isa_alu_reg_ra_2_c downto isa_alu_reg_ra_0_c); 		-- operand a register
					ctrl_o(ctrl_rb_2_c   downto ctrl_rb_0_c) <=  instr_i(isa_alu_reg_rb_2_c downto isa_alu_reg_rb_0_c); 		-- operand b register
					ctrl_o(ctrl_rd_2_c   downto ctrl_rd_0_c) <=  instr_i(isa_alu_reg_rd_2_c downto isa_alu_reg_rd_0_c);		-- immediate
			end case;			
		
		
		when "10" => -- class 2: branch
      -- -------------------------------------------------------------------	
			case(instr_i(isa_branch_1_c downto isa_branch_0_c)) is
				when "00" => -- JMP

				when "01" => -- JNE

				when "10" => -- JE
				
			end case;
		
	end case;
 end process;
	
end architecture decoder_structure;