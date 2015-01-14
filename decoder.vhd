library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.proc_package.all;

entity decoder is
	port	(		
      clock_i         : in  std_logic; 
      reset_i		      : in  std_logic;
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
  --if (rising_edge(clock_i)) then
  --  if(reset_i = '0') then
      -- defaults, given that all bits are already set to '0' those whose value had to be set 0, won't be set again
      ctrl_o <= (others => '0');                  -- all signals disabled
      imm_o  <= (others => '0');
      
      case (instr_i(isa_op1_c downto isa_op2_c)) is
      
         when op_nop_c => -- class 0: NOP
          -- -------------------------------------------------------------------	
          ctrl_o(ctrl_nop_c)  <= '1';
           
         when op_mem_c => -- class 1: memory access
          -- -------------------------------------------------------------------	
          case(instr_i(isa_mem_load_store_1_c downto isa_mem_load_store_0_c)) is

            when op_mem_load_c => -- Load
              ctrl_o(ctrl_use_mem_c) 							     <= '1';
              ctrl_o(ctrl_rb_imm_c) 							     <= '1';
              ctrl_o(ctrl_ra_c) 							         <= '1';
              ctrl_o(ctrl_rd_c) 							         <= '1';  
              ctrl_o(ctrl_alu_op_1_c downto ctrl_alu_op_0_c) <= alu_add_c;        
              ctrl_o(ctrl_ra_2_c   downto ctrl_ra_0_c) <= instr_i(isa_mem_load_ra_2_c  downto isa_mem_load_ra_0_c);			
              ctrl_o(ctrl_rd_2_c   downto ctrl_rd_0_c) <= instr_i(isa_mem_load_rd_2_c  downto isa_mem_load_rd_0_c); 
              imm_o   	                               <= "0000000000" & instr_i(isa_mem_load_imm_6_c downto isa_mem_load_imm_0_c); 
            
            when op_mem_store_c => -- Store
              ctrl_o(ctrl_use_mem_c) 							     <= '1';
              ctrl_o(ctrl_ra_c) 							         <= '1';
              ctrl_o(ctrl_rb_c) 							         <= '1';
              ctrl_o(ctrl_alu_op_1_c downto ctrl_alu_op_0_c) <= alu_add_c;                  
              ctrl_o(ctrl_ra_2_c   downto ctrl_ra_0_c) <= instr_i(isa_mem_store_ra_2_c  downto isa_mem_store_ra_0_c);
              ctrl_o(ctrl_rb_2_c   downto ctrl_rb_0_c) <= instr_i(isa_mem_store_rb_2_c  downto isa_mem_store_rb_0_c);
              imm_o   													       <= "0000000000" & instr_i(isa_mem_store_imm_6_c downto isa_mem_store_imm_0_c);
              
            when op_mem_move_c => -- Move
              ctrl_o(ctrl_rb_imm_c) 	  			         <= '1';
              ctrl_o(ctrl_rd_c) 							         <= '1';
              ctrl_o(ctrl_rd_2_c   downto ctrl_rd_0_c) <= instr_i(isa_mem_move_rd_2_c  downto isa_mem_move_rd_0_c);
              imm_o   													       <= "0000000" & instr_i(isa_mem_move_imm_8_c downto isa_mem_move_imm_0_c);
              ctrl_o(ctrl_alu_op_1_c downto ctrl_alu_op_0_c) <= alu_op2_c;
              
            when OTHERS => ctrl_o <= (OTHERS=>'X');
          end case;
         
        when op_ari_c => -- class 2: arithmetic op
          -- -------------------------------------------------------------------	
          ctrl_o(ctrl_alu_op_1_c downto ctrl_alu_op_0_c)  <= instr_i(isa_alu_op1_c downto isa_alu_op0_c);
          case(instr_i(isa_alu_c)) is
            
            when op_ari_imm_c => -- Op with immediate
              ctrl_o(ctrl_rb_imm_c) 									    <= '1';
              ctrl_o(ctrl_ra_2_c   downto ctrl_ra_0_c)  	<=  instr_i(isa_alu_imm_ra_2_c downto isa_alu_imm_ra_0_c);
              ctrl_o(ctrl_rd_2_c   downto ctrl_rd_0_c)   	<=  instr_i(isa_alu_imm_rd_2_c downto isa_alu_imm_rd_0_c);
              imm_o   													          <=  "00000000000" & instr_i(isa_alu_imm_imm_4_c downto isa_alu_imm_imm_0_c);
            
            when op_ari_reg_c => -- Op between registers
              ctrl_o(ctrl_ra_c) 							            <= '1';
              ctrl_o(ctrl_rb_c) 							            <= '1';        
              ctrl_o(ctrl_rd_c) 							            <= '1';
              ctrl_o(ctrl_ra_2_c   downto ctrl_ra_0_c)   	<=  instr_i(isa_alu_reg_ra_2_c downto isa_alu_reg_ra_0_c);
              ctrl_o(ctrl_rb_2_c   downto ctrl_rb_0_c)   	<=  instr_i(isa_alu_reg_rb_2_c downto isa_alu_reg_rb_0_c);
              ctrl_o(ctrl_rd_2_c   downto ctrl_rd_0_c)   	<=  instr_i(isa_alu_reg_rd_2_c downto isa_alu_reg_rd_0_c);
              
            when OTHERS => ctrl_o <= (OTHERS=>'X');
            
          end case;			
        
        
        when op_branch_c => -- class 3: branch
          -- -------------------------------------------------------------------	
          ctrl_o(ctrl_is_branch_c)                       <= '1';
          ctrl_o(ctrl_ra_pc_c)                           <= '1';
          ctrl_o(ctrl_rb_imm_c)                          <= '1';
          ctrl_o(ctrl_alu_op_1_c downto ctrl_alu_op_0_c) <= alu_add_c;
          
          case(instr_i(isa_branch_1_c downto isa_branch_0_c)) is
            when op_branch_jmp_c => -- JMP
              imm_o   		<= "0000" & instr_i(isa_jmp_imm_11_c downto isa_jmp_imm_0_c); 
              ctrl_o(ctrl_branch_cond_1_c downto ctrl_branch_cond_0_c) <= "10";
            when op_branch_jne_c => -- JNE
              imm_o   		                             <= "00000000" & instr_i(isa_br_imm_7_c downto isa_br_imm_0_c);
              ctrl_o(ctrl_ra_c) 							         <= '1';
              ctrl_o(ctrl_rb_c) 							         <= '1'; 
              ctrl_o(ctrl_ra_2_c   downto ctrl_ra_0_c) <= instr_i(isa_br_ra_2_c downto isa_br_ra_0_c);
              ctrl_o(ctrl_rb_2_c   downto ctrl_rb_0_c) <= (OTHERS=>'0');
              ctrl_o(ctrl_branch_cond_1_c downto ctrl_branch_cond_0_c) <= '0' & instr_i(isa_br_cnd_c);
            when op_branch_je_c => -- JE
              
            when OTHERS => ctrl_o <= (OTHERS=>'X');
            
          end case;
          
        when OTHERS => ctrl_o <= (OTHERS=>'X');
        
      end case;
    --else 
      --ctrl_o <= (0 => '1', others => '0');  -- reset insert nops
      --imm_o  <= (others => '0');            -- reset insert nops
    --end if;
  --end if;
 end process;
	
end architecture decoder_structure;