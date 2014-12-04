library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity registerfile is
  port(
      clk : in STD_LOGIC;
      rst : in STD_LOGIC;
      
      REGF_SrcA: in STD_LOGIC_VECTOR(3 downto 0);
      REGF_SrcB: in STD_LOGIC_VECTOR(3 downto 0);
      REGF_InAddr : in STD_LOGIC_VECTOR(3 downto 0);
      REGF_WE : in STD_LOGIC;
      REGF_InData : in STD_LOGIC_VECTOR(15 downto 0);
      REGF_InPC : in STD_LOGIC_VECTOR(15 downto 0);
      
      REGF_OutA: out STD_LOGIC_VECTOR(15 downto 0);
      REGF_OutB: out STD_LOGIC_VECTOR(15 downto 0)
      
  );
end registerFile;

architecture behavioral of registerFile is
  type reg_array is array (integer range 0 to REGF_REGNUM) of std_logic_vector(15 downto 0);
  signal regs : reg_array;
begin
  REGF_OutA <= regs(CONV_INTEGER(REGF_SrcA));
  REGF_OutB <= regs(CONV_INTEGER(REGF_SrcB));
  
  
  process(clk, rst)
  begin
    if rst = '0' then
      for i in 0 to REGF_REGNUM loop
        regs(i) <= ZERO;
      end loop;
      regs(CONV_INTEGER(REGF_SP))<="1000000000000000";
    elsif rst = '1' and REGF_WE = '1' and clk'event and clk='0' then
      regs(CONV_INTEGER(REGF_InAddr)) <= REGF_InData;
		regs(CONV_INTEGER(REGF_PC)) <= REGF_InPC;
    end if;
  end process;
end behavioral;