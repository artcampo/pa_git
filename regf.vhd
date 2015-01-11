library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.proc_package.all;


entity regf is
	PORT 
	(
		clock_i		   : in   std_logic; 
		reset_i		   : in   std_logic;
		stall_i		   : in   std_logic;
		
		wb_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
		fe_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
		wb_data_i    : in  std_logic_vector(data_width_c-1 downto 0);
		imm_i        : in  std_logic_vector(data_width_c-1 downto 0);
    pc_from_fe_i : in  std_logic_vector(data_width_c-1 downto 0);
		
		ra_o        : out std_logic_vector(data_width_c-1 downto 0);
    rb_o        : out std_logic_vector(data_width_c-1 downto 0)
	);
end regf;

architecture regf_behaviour of regf is

  -- register file --
  type   regf_mem_type is array (num_registers - 1 downto 0) of std_logic_vector(data_width_c-1 downto 0);
  signal regf_mem     : regf_mem_type := (others => (others => '0'));

  signal ra          : std_logic_vector(data_width_c-1 downto 0);
  signal rb          : std_logic_vector(data_width_c-1 downto 0);  
  
begin 

  write_reg: process(clock_i)
  begin
    if ((wb_ctrl_i(ctrl_nop_c) = '0') and (stall_i = '0') and (wb_ctrl_i(ctrl_rd_c) = '1')) then
      regf_mem(to_integer(unsigned(wb_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c)))) <= wb_data_i;
    end if;
  end process write_reg;
  
  operand_fetch: process(fe_ctrl_i, regf_mem)
  begin
    ra <= regf_mem(to_integer(unsigned(fe_ctrl_i(ctrl_ra_2_c downto ctrl_ra_0_c))));
    rb <= regf_mem(to_integer(unsigned(fe_ctrl_i(ctrl_rb_2_c downto ctrl_rb_0_c))));
  end process operand_fetch;

  ra_o <= pc_from_fe_i when (fe_ctrl_i(ctrl_ra_pc_c ) = '1')  else ra;
  rb_o <= imm_i        when (fe_ctrl_i(ctrl_rb_imm_c) = '1')  else rb;
  
end regf_behaviour;
