library ieee;
use ieee.std_logic_1164.all;

package proc_package is


-- Constants ---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
constant data_width_c      : natural := 16;
constant num_registers	   : natural := 8;
constant ctrl_width_c      : natural := 24; -- TODO: reduce this when processor finished

-- alu
constant alu_op_bits	     : natural := 2;
constant alu_equal_c       : std_logic_vector(15 downto 0) := "0000000000000001"; 
constant alu_not_equal_c   : std_logic_vector(15 downto 0) := "0000000000000000"; 

-- Isa values ---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- operations 
constant op_nop_c          : std_logic_vector(1 downto 0)  := "00"; 

constant op_mem_c          : std_logic_vector(1 downto 0)  := "01"; 
constant op_mem_load_c     : std_logic_vector := "00"; 
constant op_mem_store_c    : std_logic_vector := "01"; 
constant op_mem_move_c     : std_logic_vector := "10"; 
 
  
constant op_ari_c         : std_logic_vector(1 downto 0)  := "10"; 
constant op_ari_imm_c     : std_logic := '0'; 
constant op_ari_reg_c     : std_logic := '1'; 

constant op_branch_c      : std_logic_vector(1 downto 0)  := "11"; 
constant op_branch_jmp_c  : std_logic_vector(1 downto 0)  := "00"; 
constant op_branch_jne_c  : std_logic_vector(1 downto 0)  := "01"; 
constant op_branch_je_c   : std_logic_vector(1 downto 0)  := "10"; 



-- Control word description ---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

constant ctrl_nop_c         : natural := 0; -- is 1 for a nop inst, 0 for a valid inst

-- Operand A
constant ctrl_ra_pc_c       : natural := 1; -- use pc for ra (opA is the pc)
constant ctrl_ra_c          : natural := 2; -- is 1 for not using A, 0 for using A
constant ctrl_ra_0_c        : natural := 3; -- operand register A adr bit 0
constant ctrl_ra_2_c        : natural := 5; -- operand register A adr bit 2

-- Operand B
constant ctrl_rb_imm_c      : natural := 6; -- operand register B is an immediate
constant ctrl_rb_c          : natural := 7; -- is 1 for not using B, 0 for using B
constant ctrl_rb_0_c        : natural := 8; -- operand register B adr bit 0
constant ctrl_rb_2_c        : natural := 10; -- operand register B adr bit 2

-- Destiantion Register
constant ctrl_rd_wb_c       : natural := 11;	 -- enable write back
constant ctrl_rd_c          : natural := 12;   -- is 1 for not using D, 0 for using D
constant ctrl_rd_0_c        : natural := 13;   -- register destination adr bit 0
constant ctrl_rd_2_c        : natural := 15;   -- register destination adr bit 2

-- Alu
constant ctrl_alu_op_0_c        : natural := 16;   -- register destination adr bit 0
constant ctrl_alu_op_1_c        : natural := 17;   -- register destination adr bit 2

-- Memg
constant ctrl_use_mem_c         : natural := 18;   -- set if it accesses memory

-- branches
constant ctrl_is_branch_c       : natural := 19;   
constant ctrl_branch_cond_0_c   : natural := 20;
constant ctrl_branch_cond_1_c   : natural := 21;

-- ISA description ---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

constant isa_op1_c		    					  : natural := 15;
constant isa_op2_c		    					  : natural := 14;


-- load/store - move
constant isa_mem_load_store_1_c		    : natural := 13;
constant isa_mem_load_store_0_c		 		: natural := 12;

  --move
  constant isa_mem_move_rd_2_c          : natural := 11;
  constant isa_mem_move_rd_0_c          : natural := 9;
  constant isa_mem_move_imm_8_c         : natural := 8;
  constant isa_mem_move_imm_0_c         : natural := 0;

  --load
  constant isa_mem_load_ra_2_c		   	: natural := 11;
  constant isa_mem_load_ra_0_c		   	: natural := 9;
  constant isa_mem_load_rd_2_c		   	: natural := 8;
  constant isa_mem_load_rd_0_c		   	: natural := 6;
  constant isa_mem_load_imm_6_c		   	: natural := 5;
  constant isa_mem_load_imm_0_c		   	: natural := 0;

  --store
  constant isa_mem_store_ra_2_c		   	: natural := 11;
  constant isa_mem_store_ra_0_c		   	: natural := 9;
  constant isa_mem_store_rb_2_c		   	: natural := 8;
  constant isa_mem_store_rb_0_c		   	: natural := 6;
  constant isa_mem_store_imm_6_c		  : natural := 5;
  constant isa_mem_store_imm_0_c		  : natural := 0;

-- arithmetic op
constant isa_alu_c		   					    : natural := 13;
constant isa_alu_op1_c							  : natural := 12;
constant isa_alu_op0_c							  : natural := 11;

  --op with immediate
  constant isa_alu_imm_ra_2_c		    	: natural := 10;
  constant isa_alu_imm_ra_0_c	   		  : natural := 8;
  constant isa_alu_imm_rd_2_c		    	: natural := 7;
  constant isa_alu_imm_rd_0_c		  		: natural := 5;
  constant isa_alu_imm_imm_4_c		   	: natural := 4;
  constant isa_alu_imm_imm_0_c		   	: natural := 0;

  --op between registers
  constant isa_alu_reg_ra_2_c		   	: natural := 10;
  constant isa_alu_reg_ra_0_c	   		: natural := 8;
  constant isa_alu_reg_rb_2_c		   	: natural := 7;
  constant isa_alu_reg_rb_0_c		  	: natural := 5;
  constant isa_alu_reg_rd_2_c		   	: natural := 4;
  constant isa_alu_reg_rd_0_c		  	: natural := 2;
    
-- branch
constant isa_branch_1_c		   				: natural := 13;
constant isa_branch_0_c							: natural := 12;

  -- jmp
  constant isa_jmp_imm_11_c				  : natural := 11;
  constant isa_jmp_imm_0_c				  : natural := 0;

  -- bre / brne
  constant isa_br_ra_2_c				  : natural := 11;
  constant isa_br_ra_0_c				  : natural := 9;    
  constant isa_br_imm_8_c				  : natural := 8;
  constant isa_br_imm_0_c				  : natural := 0;
  



-- ALU Function Select -----------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------

constant alu_add_c        : std_logic_vector(1 downto 0) := "00"; -- add 
constant alu_sub_c        : std_logic_vector(1 downto 0) := "01"; -- subtract 
constant alu_comp_c       : std_logic_vector(1 downto 0) := "10"; -- compare (keep the biggest)
constant alu_op2_c        : std_logic_vector(1 downto 0) := "11"; -- result equal to op2

-- branch constants  -----------------------------------------------------------------------
constant br_unconditional : std_logic_vector(1 downto 0) := "00";
constant br_neq           : std_logic_vector(1 downto 0) := "01";
constant br_eq            : std_logic_vector(1 downto 0) := "10";

-- Component: Control --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component ctrl
  port	(
    clock_i           : in  std_logic;
    reset_i           : in  std_logic;
   
    instr_mem_i       : in  std_logic_vector(data_width_c-1 downto 0); -- instruction input
    de_ctrl_i         : in  std_logic_vector(ctrl_width_c-1 downto 0);
    ra_de_i           : in  std_logic_vector(data_width_c-1 downto 0);
    rb_de_i           : in  std_logic_vector(data_width_c-1 downto 0);
    rc_de_i           : in  std_logic_vector(data_width_c-1 downto 0);
    cond_de_i         : in  std_logic;
    rd_ex             : in  std_logic_vector(data_width_c-1 downto 0);
    data_ma_i         : in  std_logic_vector(data_width_c-1 downto 0);
  
    inst_pc_o         : out std_logic_vector(data_width_c-1 downto 0);
    instr_fe_o        : out std_logic_vector(data_width_c-1 downto 0); -- instruction fetched
    instr_fe_de_o     : out std_logic_vector(data_width_c-1 downto 0);
    de_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); -- de stage control
    ex_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0); 
    ma_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0);
    wb_ctrl_o         : out std_logic_vector(ctrl_width_c-1 downto 0);
    pc_fe_de_o        : out std_logic_vector(data_width_c-1 downto 0);
    ra_de_ex_o        : out std_logic_vector(data_width_c-1 downto 0);
    rb_de_ex_o        : out std_logic_vector(data_width_c-1 downto 0);
    rc_ex_ma_o        : out std_logic_vector(data_width_c-1 downto 0);
    rd_ex_ma_o        : out std_logic_vector(data_width_c-1 downto 0);
    rd_ma_wb_o        : out std_logic_vector(data_width_c-1 downto 0)
  );
end component;


-- Component: Decoder --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component decoder
  port	(    
    clock_i         : in  std_logic; 
    reset_i		      : in  std_logic;    
    instr_i         : in  std_logic_vector(data_width_c-1 downto 0); -- instruction input
    ctrl_o          : out std_logic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
    imm_o           : out std_logic_vector(data_width_c-1 downto 0)  -- immediate unsigned output
  );
end component;


-- Component: regf --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component regf
  port	(
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
end component;


-- Component: fwd --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component fwd
  port	(
    ex_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
		ma_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
    wb_ctrl_i    : in  std_logic_vector(ctrl_width_c-1 downto 0);
		wb_data_i    : in  std_logic_vector(data_width_c-1 downto 0);
    ma_data_i    : in  std_logic_vector(data_width_c-1 downto 0);
		ra_i         : in  std_logic_vector(data_width_c-1 downto 0);
    rb_i         : in  std_logic_vector(data_width_c-1 downto 0);    
		ra_o         : out std_logic_vector(data_width_c-1 downto 0);
    rb_o         : out std_logic_vector(data_width_c-1 downto 0)
    );
end component;


-- Component: ALU -------------------------------------------------------
-- -------------------------------------------------------------------------------------------

component ALU is
	port	(		
    op1_i	:	in		std_logic_vector(data_width_c - 1 downto 0);
    op2_i	:	in		std_logic_vector(data_width_c - 1 downto 0);
    sel_i	:	in		std_logic_vector(1 downto 0);
    res_o	:	out	std_logic_vector(data_width_c - 1 downto 0)  
);
end component ALU;

-- Component: MEMGATE -------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component memg is
	port	(
				clock_i         : in   std_logic; 
        ma_ctrl_i       : in   std_logic_vector(ctrl_width_c - 1 downto 0); -- ma stage control
			  data_i          : in   std_logic_vector(data_width_c - 1 downto 0); -- data coming from mem
        addr_i          : in   std_logic_vector(data_width_c - 1 downto 0); -- address to access
        rd_i            : in   std_logic_vector(data_width_c - 1 downto 0); -- register to write to mem
       
        data_addr_o     : out  std_logic_vector(data_width_c - 1 downto 0); -- to mem interface
        w_data_o        : out  std_logic_vector(data_width_c - 1 downto 0); 
        w_enable_o      : out  std_logic;
        r_enable_o      : out  std_logic;   
        r_is_code_o     : out  std_logic;                                   -- '1'=code, '0'=data
        rd_o            : out  std_logic_vector(data_width_c - 1 downto 0)
			);
end component memg;

-- Component: MEM -------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component mem is
	port	(
    -- Host Interface --
    clock_i         : in   std_logic; 
    ins_addr_i      : in   std_logic_vector(data_width_c - 1 downto 0); 
    ins_enab_i      : in   std_logic;
    data_addr_i     : in   std_logic_vector(data_width_c - 1 downto 0); 
    w_data_i        : in   std_logic_vector(data_width_c - 1 downto 0); -- write data
    w_enable_i      : in   std_logic;
    r_enable_i      : in   std_logic;     
    ins_data_o      : out  std_logic_vector(data_width_c - 1 downto 0);
    data_o          : out  std_logic_vector(data_width_c - 1 downto 0)
  );
end component mem;


-- Component: Proc -------------------------------------------------------
-- -------------------------------------------------------------------------------------------
component proc is
	port	(
		clock_i			: in   std_logic; 
		reset_i			: in   std_logic
  );
end component proc;


end package proc_package;