library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity alu is
  port (
    srcA : in STD_LOGIC_VECTOR(15 downto 0);
    srcB : in STD_LOGIC_VECTOR(15 downto 0);
    op   : in STD_LOGIC_VECTOR(2 downto 0);
    
    result : out STD_LOGIC_VECTOR(15 downto 0);
    zero_flag : out STD_LOGIC;
    sign_flag : out STD_LOGIC
  );
end alu;

architecture behavioral of alu is
  signal res: STD_LOGIC_VECTOR(15 downto 0);
begin
  with op select
    res <= srcA + srcB when ALUOP_ADD,
              srcA - srcB when ALUOP_SUB,
              srcA and srcB when ALUOP_AND,
              srcA or srcB when ALUOP_OR,
              not srcA when ALUOP_NOT,
              to_stdlogicvector(to_bitvector(srcA) sll conv_integer(srcB)) when ALUOP_SLL,
              to_stdlogicvector(to_bitvector(srcA) sra conv_integer(srcB)) when ALUOP_SRA,
              ZERO when others;
  zero_flag <= '1' when res = ZERO else '0';
  sign_flag <= res(15);
  result <= res;
    
end behavioral; 
