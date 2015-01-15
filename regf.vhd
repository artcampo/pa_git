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
		de_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
		wb_data_i    : in  std_logic_vector(data_width_c-1 downto 0);
		imm_i        : in  std_logic_vector(data_width_c-1 downto 0);
    pc_from_fe_i : in  std_logic_vector(data_width_c-1 downto 0);
		
    cond_o       : out std_logic;
		ra_o         : out std_logic_vector(data_width_c-1 downto 0);
    rb_o         : out std_logic_vector(data_width_c-1 downto 0);
    rc_o         : out std_logic_vector(data_width_c-1 downto 0)
	);
end regf;

architecture regf_behaviour of regf is

  -- register file --
  type   regf_mem_type is array (num_registers - 1 downto 0) of std_logic_vector(data_width_c-1 downto 0);
  --signal regf_mem     : regf_mem_type := (others => (others => '0'));
  signal regf_mem     : regf_mem_type := (
  0 => x"0000",
  1 => x"0001",
  2 => x"0002",
  3 => x"0003",
  4 => x"0004",
  5 => x"0005",
  6 => x"0006",
  7 => x"0007");

  signal ra          : std_logic_vector(data_width_c-1 downto 0);
  signal rb          : std_logic_vector(data_width_c-1 downto 0);  
  signal ra2         : std_logic_vector(data_width_c-1 downto 0);
  signal rb2         : std_logic_vector(data_width_c-1 downto 0);  
  
begin 

  write_reg: process(clock_i)
  begin
    if (rising_edge(clock_i) and (wb_ctrl_i(ctrl_nop_c) = '0') and (stall_i = '0') and (wb_ctrl_i(ctrl_rd_c) = '1')) then
      regf_mem(to_integer(unsigned(wb_ctrl_i(ctrl_rd_2_c downto ctrl_rd_0_c)))) <= wb_data_i;
    end if;
  end process write_reg;
  
  operand_fetch: process(de_ctrl_i, regf_mem, ra, rb)
  begin
    ra     <= regf_mem(to_integer(unsigned(de_ctrl_i(ctrl_ra_2_c downto ctrl_ra_0_c))));
    rb     <= regf_mem(to_integer(unsigned(de_ctrl_i(ctrl_rb_2_c downto ctrl_rb_0_c))));
    if(ra /= rb) then
      cond_o <= '0'; 
    else
      cond_o <= '1';
     end if; 
  end process operand_fetch;

  ra2 <= pc_from_fe_i when (de_ctrl_i(ctrl_ra_pc_c ) = '1')  else ra;
  rb2 <= imm_i        when (de_ctrl_i(ctrl_rb_imm_c) = '1')  else rb;
  
  --read_reg: process(clock_i)
  --begin
  --  if (rising_edge(clock_i)) then
      ra_o <= ra2;
      rb_o <= rb2;
      rc_o <= rb;
  --  end if;
  --end process read_reg;
  
end regf_behaviour;
