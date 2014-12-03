library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity ID_EXE_Register is
  port(
    clk: in STD_LOGIC;
    --exe phase
    in_alu_op: in STD_LOGIC_VECTOR(15 downto 0);
    in_a: in STD_LOGIC_VECTOR(15 downto 0);
    in_b: in STD_LOGIC_VECTOR(15 downto 0);
    in_imm: in STD_LOGIC_VECTOR(15 downto 0);
    in_alu_b_src: in STD_LOGIC;
    --mem phase
    in_mem_control: in STD_LOGIC_VECTOR(1 downto 0);
    --wb phase
    in_regwrite: in STD_LOGIC;
    in_regwrite_addr: in STD_LOGIC_VECTOR(3 downto 0);

    --forward unit 
    in_rega: in STD_LOGIC_VECTOR(3 downto 0);
    in_regb: in STD_LOGIC_VECTOR(3 downto 0);
    
    
        
    out_alu_op: out STD_LOGIC_VECTOR(15 downto 0);
    out_a :out STD_LOGIC_VECTOR(15 downto 0);
    out_b :out STD_LOGIC_VECTOR(15 downto 0);
    out_imm:out STD_LOGIC_VECTOR(15 downto 0);
    out_rega: out STD_LOGIC_VECTOR(3 downto 0);
    out_regb: out STD_LOGIC_VECTOR(3 downto 0);
    out_alu_b_src: out STD_LOGIC;
    out_mem_control: out STD_LOGIC_VECTOR(1 downto 0);
    out_regwrite: out STD_LOGIC;
    out_regwrite_addr: out STD_LOGIC_VECTOR(3 downto 0)    
  );
end ID_EXE_Register;

architecture behavioral of ID_EXE_Register is
begin
  process(clk)
  begin
    if rising_edge(clk) then
      out_alu_op <= in_alu_op;
      out_a <= in_a;
      out_b <= in_b;
      out_imm <= in_imm;
      out_alu_b_src <= in_alu_b_src;
      out_mem_control <= in_mem_control;
      out_regwrite <= in_regwrite;
      out_regwrite_addr <= in_regwrite_addr;
      out_rega <= in_rega;
      out_regb <= in_regb;
    end if;
  end process;
end behavioral;