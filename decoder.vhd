library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.proc_package.all;

entity decoder is
	port	(		
			instr_i         : in  std_logic_vector(data_width_c-1 downto 0); -- instruction input
			ctrl_o          : out std_logic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
		  );

end entity decoder;


architecture decoder_structure of decoder is
  
    -- Formated instruction --
  signal instr_int : std_logic_vector(15 downto 0);

begin

  -- Data Format Converter -------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
data_conv: process(instr_i)
  variable instr_tmp_v : std_logic_vector(15 downto 0);
  begin
    instr_tmp_v := (others => '0');
      for i in 0 to data_width_c-1 loop
        instr_tmp_v(i) := instr_i(i);
      end loop;
      
		instr_int <= instr_tmp_v;

end process data_conv;
  
  
 -- Decoder  -------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
decoder: process(instr_int)
   begin
      -- defaults --
      ctrl_o                                     <= (others => '0');                  -- all signals disabled
 
	case (instr_int(15 downto 14)) is
	
	   when "00" => -- class 0: memory access
      -- -------------------------------------------------------------------	
			case(instr_int(13 downto 13)) is
				when "0" => -- Load
					ctrl_o(ctrl_ra_3_c   downto ctrl_ra_0_c)  	<=  instr_int(12 downto 10)-- operand a register
					ctrl_o(ctrl_rd_3_c   downto ctrl_rd_0_c)   	<=  instr_int(9 downto 7) 	-- destination register 
					ctrl_o(ctrl_inm_6_c  downto ctrl_inm_0_c)   	<=  instr_int(7 downto 0) 	-- immediate
				
				when "1" => -- Store
					ctrl_o(ctrl_ra_3_c   downto ctrl_ra_0_c)   	<=  instr_int(12 downto 10)-- operand a register
					ctrl_o(ctrl_rb_3_c   downto ctrl_rb_0_c)   	<=  instr_int(9 downto 7) 	-- operand b register
					ctrl_o(ctrl_inm_6_c  downto ctrl_inm_0_c)   	<=  instr_int(9 downto 7)	-- immediate
			end case;
			
		
		when "01" => -- class 1: arithmetic op
      -- -------------------------------------------------------------------	
			case(instr_int(13 downto 13)) is
				when "0" => -- Op with immediate
					ctrl_o(ctrl_ra_3_c   downto ctrl_ra_0_c)  	<=  instr_int(10 downto 8) -- operand a register
					ctrl_o(ctrl_rd_3_c   downto ctrl_rd_0_c)   	<=  instr_int(7 downto 5) 	-- destination register 
					ctrl_o(ctrl_inm_6_c  downto ctrl_inm_0_c)   	<=  instr_int(4 downto 0) 	-- immediate
				
				when "1" => -- Op between registers
					ctrl_o(ctrl_ra_3_c   downto ctrl_ra_0_c)   	<=  instr_int(10 downto 8) -- operand a register
					ctrl_o(ctrl_rb_3_c   downto ctrl_rb_0_c)   	<=  instr_int(7 downto 5) 	-- operand b register
					ctrl_o(ctrl_rd_3_c   downto ctrl_rd_0_c)   	<=  instr_int(4 downto 2)	-- immediate
			end case;			
		
		
		when "10" => -- class 2: branch
      -- -------------------------------------------------------------------	
			case(instr_int(13 downto 12)) is
				when "00" => -- JMP

				when "01" => -- JNE

				when "10" => -- JE
				
			end case;
		
	end case;
 end process;
	
end architecture decoder_structure;