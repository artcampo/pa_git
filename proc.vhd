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
  signal de_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal fe_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal ex_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal ma_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);	
  signal wb_ctrl            : std_logic_vector(ctrl_width_c - 1 downto 0);
  signal stall              : std_logic := '1';	
  
  -- signals for Fetch
	signal ins_addr           : std_logic_vector(data_width_c - 1 downto 0);	
	signal ins_data           : std_logic_vector(data_width_c - 1 downto 0);	
	signal ins_enab           : std_logic := '1';	
  
  -- signals for DEC
  signal de_imm             : std_logic_vector(ctrl_width_c - 1 downto 0);
  signal pc_from_fe         : std_logic_vector(ctrl_width_c - 1 downto 0);	
 
  -- signals for ALU
  signal op1  	            :	std_logic_vector(data_width_c - 1 downto 0);
  signal op2  	            :	std_logic_vector(data_width_c - 1 downto 0);
  signal sel  	            :	std_logic_vector(alu_op_bits - 1  downto 0);
  signal res  	            :	std_logic_vector(data_width_c - 1 downto 0);
  
  -- signals for WB
  signal wb_data            :	std_logic_vector(data_width_c - 1 downto 0);
      
        
  
begin 
	proc_fetch : process(clock_i)
	 begin
		if (rising_edge(clock_i)) then			
			if (reset_I = '1') then				 
				 ins_addr <= (others => '0');
			else
				ins_addr <= std_logic_vector(unsigned(ins_addr)+1);
			end if;			
		end if;
	end process;					


          
	-- ctrl ----------------------------------------------------------------------------------------------------
  ctrl1: ctrl
    port map (
      clock_i         => clock_i,
      reset_i         => reset_i,
		
      de_ctrl_i       => de_ctrl,
      fe_ctrl_o       => fe_ctrl,
      ex_ctrl_o       => ex_ctrl,
      ma_ctrl_o       => ma_ctrl,
      wb_ctrl_o       => wb_ctrl,
      
      pc_from_fe_o    => pc_from_fe
      ); 

	-- deco: DE --------------------------------------------------------------------------------------------------
  dec1: decoder
    port map (
			instr_i         => ins_data,
			ctrl_o          => de_ctrl,
			imm_o           => de_imm
      );
      

	-- regf: both OF and WB ------------------------------------------------------------------------------------
  regf1: regf
    port map (
      clock_i		   => clock_i,
      reset_i		   => reset_i,
      stall_i		   => stall,     
      wb_ctrl_i    => wb_ctrl,
      fe_ctrl_i    => fe_ctrl,
      wb_data_i    => wb_data,
      imm_i        => de_imm,
      pc_from_fe_i => pc_from_fe,   
      op1_o        => op1,
      op2_o        => op2
      );   
   
	-- alu: EX ----------------------------------------------------------------------------------------------------
  alu1: alu
    port map (
      op1_i => op1,
      op2_i => op2,
      sel_i => sel,
      res_o => res
      );   
   
	-- mem: MA ----------------------------------------------------------------------------------------------------
  Mem1: mem
    port map (
        clock_i  	  => clock_i,
        ins_addr_i => ins_addr,
        ins_enab_i => ins_enab,
        ins_data_o => ins_data	
        );   
	
end proc_behaviour;
