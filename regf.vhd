library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.proc_package.all;


entity regf is
	PORT 
	(
		clock_i		   : in   std_logic; 
		reset_I		   : in   std_logic;
		stall_i		   : in   std_logic;
		
		wb_ctrl_i    	: in  std_logic_vector(ctrl_width_c-1 downto 0);
		of_ctrl_i    		: in  std_logic_vector(ctrl_width_c-1 downto 0);
		
		wb_data_i    : in  std_logic_vector(data_width_c-1 downto 0);
		imm_i        : in  std_logic_vector(data_width_c-1 downto 0);
		
		op1_o        : out std_logic_vector(data_width_c-1 downto 0);
    op2_o        : out std_logic_vector(data_width_c-1 downto 0)
		
	);
end regf;

architecture regf_behaviour of regf is

  -- register file --
  type   regf_mem_type is array (num_registers - 1 downto 0) of std_logic_vector(data_width_c-1 downto 0);
  signal regf_mem     : regf_mem_type := (others => (others => '0'));

  signal op1          : std_logic_vector(data_width_c-1 downto 0);
  signal op2          : std_logic_vector(data_width_c-1 downto 0);  
  
begin 

  write_reg: process(clock_i)
  begin
    if rising_edge(clock_i) then
      if (wb_ctrl_i(ctrl_nop_c) = '0') and (stall_i = '0') then
        regf_mem(to_integer(unsigned(wb_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c)))) <= wb_data_i;
      end if;
    end if;
  end process write_reg;
  
  operand_fetch: process(of_ctrl_i, regf_mem)
  begin
    op1 <= regf_mem(to_integer(unsigned(of_ctrl_i(ctrl_ra_2_c downto ctrl_ra_0_c))));
    op2 <= regf_mem(to_integer(unsigned(of_ctrl_i(ctrl_rb_2_c downto ctrl_rb_0_c))));
  end process operand_fetch;

  op1_o <= op1;
  op2_o <= op2;
end regf_behaviour;
