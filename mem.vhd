library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.proc_package.all;
use work.tb_load_signals.all;

entity mem is
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
end mem;

architecture mem_structure of mem is	
	constant mem_size     	: natural := 256*10;
	constant log2_mem_size 	: natural := 8;


	type mem_ram_t is array (0 to (mem_size/2)-1) of std_logic_vector(data_width_c - 1 downto 0);

	-- MEMORY IMAGE (Bootloader Program) --
	------------------------------------------------------
	signal mem_ram : mem_ram_t :=
    (		
 		000000 => x"600A", -- MOV R0, 10		r0=10
		000001 => x"6201", -- MOV R1, 1			r0=10, r1=1
		000002 => x"6402", -- MOV R2, 2			r0=10, r1=1, r2=2
		000003 => x"6603", -- MOV R3, 3			r0=10, r1=1, r2=2, r3=3
		000004 => x"D204", -- jump if R1 != R0,  pc+4;  jumps
		000005 => x"65FF", -- MOV R2, 511		
		000006 => x"67FF", -- MOV R3, 511
		000007 => x"8121", -- ADD R1 +1; 		r0=10, r1=2, r2=2, r3=3
		000008 => x"D204", -- jump if R1 != R0,  pc+4;  jumps
		000009 => x"65FF", -- MOV R2, 511		
		000010 => x"67FF", -- MOV R3, 511
		000011 => x"8122", -- ADD R1 +2; 		r0=10, r1=4, r2=2, r3=3, r4=4
		000012 => x"D204", -- jump if R1 != R0,  pc+4;  jumps
		000013 => x"65FF", -- MOV R2, 511		
		000014 => x"67FF", -- MOV R3, 511
		000015 => x"8122", -- ADD R1 +2; 		r0=10, r1=6, r2=2, r3=3, r4=4
		000016 => x"D204", -- jump if R1 != R0,  pc+4;  jumps
		000017 => x"65FF", -- MOV R2, 511		
		000018 => x"67FF", -- MOV R3, 511
		000019 => x"8122", -- ADD R1 +2; 		r0=10, r1=8, r2=2, r3=3, r4=4
		000020 => x"D204", -- jump if R1 != R0,  pc+4;  jumps
		000021 => x"65FF", -- MOV R2, 511		
		000022 => x"67FF", -- MOV R3, 511
		000023 => x"8122", -- ADD R1 +2; 		r0=10, r1=10, r2=2, r3=3
		000024 => x"E204", -- jump if R1 = R0,  pc+4;  DON'T JUMP
		000025 => x"6414", -- MOV R2, 20		r0=10, r1=10, r2=20, r3=3		
		000026 => x"661E", -- MOV R3, 30		r0=10, r1=10, r2=20, r3=30
		000027 => x"A34C", -- ADD R3 <- R2+R3,	r0=10, r1=10, r2=20, r3=50
		000028 => x"E204", -- jump if R1 = R0,  pc+4;  DON'T JUMP
		000029 => x"641E", -- MOV R2, 30		r0=10, r1=10, r2=20, r3=50		
		000030 => x"6624", -- MOV R3, 40		r0=10, r1=10, r2=30, r3=40
		000031 => x"A34C", -- ADD R3 <- R2+R3,	r0=10, r1=10, r2=30, r3=70
		000032 => x"E204", -- jump if R1 = R0,  pc+4;  DON'T JUMP
		000033 => x"6424", -- MOV R2, 40		r0=10, r1=10, r2=40, r3=70		
		000034 => x"6632", -- MOV R3, 50		r0=10, r1=10, r2=40, r3=50
		000035 => x"A34C", -- ADD R3 <- R2+R3,	r0=10, r1=10, r2=40, r3=90
		000036 => x"E204", -- jump if R1 = R0,  pc+4;  DON'T JUMP
		000037 => x"6432", -- MOV R2, 50		r0=10, r1=10, r2=50, r3=90		
		000038 => x"663C", -- MOV R3, 60		r0=10, r1=10, r2=50, r3=60
		000039 => x"A34C", -- ADD R3 <- R2+R3,	r0=10, r1=10, r2=50, r3=110
		000040 => x"E204", -- jump if R1 = R0,  pc+4;  DON'T JUMP		
		000041 => x"643C", -- MOV R2, 60		r0=10, r1=10, r2=60, r3=110		
		000042 => x"6646", -- MOV R3, 70		r0=10, r1=10, r2=60, r3=70
		000043 => x"A34C", -- ADD R3 <- R2+R3,	r0=10, r1=10, r2=60, r3=130
		000044 => x"E204", -- jump if R1 = R0,  pc+4;  DON'T JUMP
		000045 => x"5000", -- ST R0(0) <- R0
		000046 => x"5041", -- ST R0(1) <- R1
		000047 => x"5082", -- ST R0(2) <- R2
		000048 => x"50C3", -- ST R0(3) <- R3
		others => x"0000"  -- NOP  
		);
    
	------------------------------------------------------
	signal mem_data_ram : mem_ram_t :=
    (
		others => x"DEAD"
 	  );
  
begin

	-- Memory Access - code ---------------------------------------------------------------------------------------
  mem_access: process(ins_addr_i)
  begin			
    if (ins_enab_i = '1') then					
      ins_data_o <= mem_ram(to_integer(unsigned(ins_addr_i(log2_mem_size-1 downto 0))));
    end if;
  end process mem_access;

  -- Memory read - data ---------------------------------------------------------------------------------------
  mem_data_read: process(data_addr_i, r_enable_i)
  begin			
    if (r_enable_i = '1') then					
      data_o <= mem_data_ram(to_integer(unsigned(data_addr_i(log2_mem_size-1 downto 0))));
    end if;
  end process mem_data_read;  

  -- Memory write - data ---------------------------------------------------------------------------------------
  mem_data_write: process(clock_i,data_addr_i, r_enable_i)
  begin			
    if (rising_edge(clock_i)) then
      if (w_enable_i = '1') then					
        mem_data_ram(to_integer(unsigned(data_addr_i(log2_mem_size-1 downto 0)))) <= w_data_i;
      end if;
    end if;
  end process mem_data_write;    
  
  -- Used in tb_load
		p0  <= mem_data_ram(0);
  	p1  <= mem_data_ram(1);
  	p2  <= mem_data_ram(2);
		p3  <= mem_data_ram(3);


end mem_structure;
