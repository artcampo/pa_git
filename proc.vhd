library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.proc_package.all;


entity proc is
	PORT 
	(
		clock_i			: in   std_logic; 
		reset_i			: in   std_logic
	);
end proc;

architecture proc_behaviour of proc is

  -- signals for control
  signal f1x_de_ctrl        : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal de_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal ex_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal ma_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal wb_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);
  signal stall              : std_logic := '0';	
  
  -- signals for Fetch
	signal ins_addr           : std_logic_vector(data_width_c - 1 downto 0);	
  signal instr_fe           : std_logic_vector(data_width_c - 1 downto 0); -- to fetch
  signal ins_data_mem       : std_logic_vector(data_width_c - 1 downto 0); -- from memory	
	signal ins_enab           : std_logic := '1';	

  signal pc_fe_de           : std_logic_vector(data_width_c - 1 downto 0);	
  
  -- signals for DEC
  signal de_imm             : std_logic_vector(data_width_c - 1 downto 0);
  signal ra_de	            :	std_logic_vector(data_width_c - 1 downto 0);
  signal rb_de	            :	std_logic_vector(data_width_c - 1 downto 0);
  signal rc_de	            :	std_logic_vector(data_width_c - 1 downto 0);
  signal cond               : std_logic;
  
  signal ra_de_ex	          :	std_logic_vector(data_width_c - 1 downto 0);
  signal rb_de_ex	          :	std_logic_vector(data_width_c - 1 downto 0);  
  
  -- signals for ALU
  signal ra  	              :	std_logic_vector(data_width_c - 1 downto 0);
  signal rb  	              :	std_logic_vector(data_width_c - 1 downto 0);
  signal rd   	            :	std_logic_vector(data_width_c - 1 downto 0);
  
  -- signals for MA
  signal rb_ex_ma           :	std_logic_vector(data_width_c - 1 downto 0);
  signal rd_ex_ma           :	std_logic_vector(data_width_c - 1 downto 0);
  signal w_enable           : std_logic := '1';	
  signal r_enable           :	std_logic;
  signal data_addr          :	std_logic_vector(data_width_c - 1 downto 0);
  signal rd_ma              :	std_logic_vector(data_width_c - 1 downto 0);
  signal data_mem           :	std_logic_vector(data_width_c - 1 downto 0);
  signal w_data             :	std_logic_vector(data_width_c - 1 downto 0);
  signal r_is_code          : std_logic := '0';
        
  -- signals for WB
  signal rd_ma_wb           :	std_logic_vector(data_width_c - 1 downto 0);

  
begin 

          
	-- ctrl ----------------------------------------------------------------------------------------------------
  ctrl1: ctrl
    port map (
      clock_i         => clock_i,
      reset_i         => reset_i,
		
      instr_mem_i     => ins_data_mem,
      de_ctrl_i       => f1x_de_ctrl,
      ra_de_i         => ra_de,
      rb_de_i         => rb_de, 
      rc_de_i         => rc_de,
      cond_de_i       => cond,
      rd_ex           => rd,
      data_ma_i       => rd_ma,
      
      inst_pc_o       => ins_addr,
      instr_fe_o      => instr_fe,
      de_ctrl_o       => de_ctrl,
      ex_ctrl_o       => ex_ctrl,
      ma_ctrl_o       => ma_ctrl,
      wb_ctrl_o       => wb_ctrl,
      
      pc_fe_de_o      => pc_fe_de,
      ra_de_ex_o      => ra_de_ex,
      rb_de_ex_o      => rb_de_ex,
      
      rc_ex_ma_o      => rb_ex_ma,
      rd_ex_ma_o      => rd_ex_ma,
      rd_ma_wb_o      => rd_ma_wb
      ); 

	-- deco: DE --------------------------------------------------------------------------------------------------
  dec1: decoder
    port map (
      clock_i         => clock_i,
      reset_i		      => reset_i,
			instr_i         => instr_fe,
			ctrl_o          => f1x_de_ctrl,
			imm_o           => de_imm
      );
      
	-- regf: both DE and WB ------------------------------------------------------------------------------------
  regf1: regf
    port map (
      clock_i		   => clock_i,
      reset_i		   => reset_i,
      stall_i		   => stall,     
      wb_ctrl_i    => wb_ctrl,
      de_ctrl_i    => de_ctrl,
      wb_data_i    => rd_ma_wb,
      imm_i        => de_imm,
      pc_from_fe_i => pc_fe_de,  
      cond_o       => cond, 
      ra_o         => ra_de,
      rb_o         => rb_de,
      rc_o         => rc_de
      );   

  -- fwd: EX ------------------------------------------------------------------------------------
  fwd1: fwd
    port map (
      ex_ctrl_i    => ex_ctrl,
      ma_ctrl_i    => ma_ctrl,
      wb_ctrl_i    => wb_ctrl,
      wb_data_i    => rd_ma_wb,
      ma_data_i    => rd_ex_ma,
      ra_i         => ra_de_ex,
      rb_i         => rb_de_ex,
      ra_o         => ra,
      rb_o         => rb
      );  
      
	-- alu: EX ----------------------------------------------------------------------------------------------------
  alu1: alu
    port map (
      op1_i => ra,
      op2_i => rb,
      sel_i => ex_ctrl(ctrl_alu_op_1_c downto ctrl_alu_op_0_c),
      res_o => rd
      );   
      
  -- memg: MA ----------------------------------------------------------------------------------------------------
  memg1: memg
    port map (
        clock_i  	 => clock_i,
        ma_ctrl_i  => ma_ctrl,
				data_i     => data_mem,
        addr_i     => rd_ex_ma,
        rd_i       => rb_ex_ma,
        data_addr_o=> data_addr,
        w_data_o   => w_data,
        w_enable_o => w_enable,
        r_enable_o => r_enable,
        r_is_code_o=> r_is_code,
        rd_o       => rd_ma
        );         

	-- mem: dehors ----------------------------------------------------------------------------------------------------
  Mem1: mem
    port map (
        clock_i  	 => clock_i,
        ins_addr_i => ins_addr,
        ins_enab_i => ins_enab,
        data_addr_i=> data_addr,
        w_data_i   => w_data,
        w_enable_i => w_enable,
        r_enable_i => r_enable,
        ins_data_o => ins_data_mem,
        data_o     => data_mem
        );   
	
end proc_behaviour;
