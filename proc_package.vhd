library ieee;
use ieee.std_logic_1164.all;

package proc_package is


-- Constants ---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
constant data_width_c      : natural := 16;
constant num_registers	   : natural := 8;
constant ctrl_width_c      : natural := 16;

constant alu_op_bits	      : natural := 2;
constant alu_equal_c       : std_logic_vector(15 downto 0) := "0000000000000001"; 
constant alu_not_equal_c   : std_logic_vector(15 downto 0) := "0000000000000000"; 

-- Control word description ---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

constant ctrl_nop_c         : natural := 0;

constant ctrl_ra_pc_c       : natural := 1; -- use pc for ra
constant ctrl_ra_0_c        : natural := 2;
constant ctrl_ra_2_c        : natural := 4;

constant ctrl_rb_0_c        : natural := 5;
constant ctrl_rb_2_c        : natural := 7;

constant ctrl_rd_wb_c       : natural := 8;	-- enable write back
constant ctrl_rd_0_c        : natural := 9;
constant ctrl_rd_2_c        : natural := 11;

constant ctrl_imm_c       	 : natural := 12; -- immediate implicated



-- ISA description ---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

constant isa_op1_c		    				: natural := 15;
constant isa_op2_c		    				: natural := 14;

-- load/store
constant isa_mem_load_store_c		   	: natural := 13;
	--load
	constant isa_mem_load_ra_2_c		   	: natural := 12;
	constant isa_mem_load_ra_0_c		   	: natural := 10;
	constant isa_mem_load_rd_2_c		   	: natural := 9;
	constant isa_mem_load_rd_0_c		   	: natural := 7;
	constant isa_mem_load_imm_6_c		   	: natural := 6;
	constant isa_mem_load_imm_0_c		   	: natural := 0;

	--store
	constant isa_mem_store_ra_2_c		   	: natural := 12;
	constant isa_mem_store_ra_0_c		   	: natural := 10;
	constant isa_mem_store_rb_2_c		   	: natural := 9;
	constant isa_mem_store_rb_0_c		   	: natural := 7;
	constant isa_mem_store_imm_6_c		   : natural := 6;
	constant isa_mem_store_imm_0_c		   : natural := 0;
	
-- arithmetic op
constant isa_alu_c		   					: natural := 13;
constant isa_alu_op1_c							: natural := 12;
constant isa_alu_op0_c							: natural := 11;

	--op with immediate
	constant isa_alu_imm_ra_2_c		   	: natural := 10;
	constant isa_alu_imm_ra_0_c	   		: natural := 8;
	constant isa_alu_imm_rd_2_c		   	: natural := 7;
	constant isa_alu_imm_rd_0_c		  		: natural := 5;
	constant isa_alu_imm_imm_4_c		   	: natural := 4;
	constant isa_alu_imm_imm_0_c		   	: natural := 0;
	
	--op between registers
	constant isa_alu_reg_ra_2_c		   	: natural := 10;
	constant isa_alu_reg_ra_0_c	   		: natural := 8;
	constant isa_alu_reg_rb_2_c		   	: natural := 7;
	constant isa_alu_reg_rb_0_c		  		: natural := 5;
	constant isa_alu_reg_rd_2_c		   	: natural := 4;
	constant isa_alu_reg_rd_0_c		  		: natural := 2;
	
-- branch
constant isa_branch_1_c		   				: natural := 13;
constant isa_branch_0_c							: natural := 12;



	
-- ALU Function Select -----------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------

  -- Elementary ALU Operations --
  constant alu_add_c        : std_logic_vector(1 downto 0) := "00"; -- add 
  constant alu_sub_c        : std_logic_vector(1 downto 0) := "01"; -- subtract 
  constant alu_comp_c       : std_logic_vector(1 downto 0) := "10"; -- compare (keep the biggest)
  constant alu_op1_c        : std_logic_vector(1 downto 0) := "11"; -- result equal to op1





-- Component: ALU -------------------------------------------------------
-- -------------------------------------------------------------------------------------------

component ALU is
	port	(		
				op1	:	in		std_logic_vector(data_width_c - 1 downto 0);
				op2	:	in		std_logic_vector(data_width_c - 1 downto 0);
				sel	:	in		std_logic_vector(1 downto 0);
				res	:	out	std_logic_vector(data_width_c - 1 downto 0)  
);
end component ALU;



-- Component: MEM -------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component mem is
	port	(
				-- Host Interface --
				Clock_CI        : in   std_logic; 
				Ins_Addr_DI     : in   std_logic_vector(data_width_c - 1 downto 0); 
				Ins_Enab_DI     : in   std_logic;
				Ins_Data_DO     : out  std_logic_vector(data_width_c - 1 downto 0) 
			);
end component mem;


-- Component: Decoder --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component decoder
  port	(
        -- decoder interface input --
        instr_i         : in  std_logic_vector(data_width_c-1 downto 0); -- instruction input

        -- decoder interface output --
        ctrl_o          : out std_logic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
      );
end component;


end package proc_package;