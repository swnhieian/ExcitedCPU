library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity IF_ID_Register is
  port(
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    InInst : in STD_LOGIC_VECTOR(15 downto 0);
    stay : in STD_LOGIC;
    InPC : in STD_LOGIC_VECTOR(15 downto 0);
    --here handle interrupt
    PC_INT : out STD_LOGIC;
    OutPC : out STD_LOGIC_VECTOR(15 downto 0);
    OutInst : out STD_LOGIC_VECTOR(15 downto 0)
  );
end IF_ID_Register;

architecture behavioral of IF_ID_Register is
  signal tmp_inst: std_logic_vector(15 downto 0);
  signal state: std_logic_vector(2 downto 0);
  signal int : std_logic_vector(2 downto 0);
begin
  process(clk, rst, state)
  begin
    if rst = '0' then
      state <= "000";
      OutPC <= ZERO;
    elsif clk'event and clk='1' then
      case state is
        when "000" => state<=int;
        when "001" => state<="010";
        when "010" => state<="011";
        when "100" => state<="101";
        when "101" => state<="110";
        when "110" => state<="111";
        when others => state<="000";
      end case;
      OutPC <= InPC;
      OutInst <= tmp_inst;
    end if;
  end process;
  with state select
    PC_INT <= '1' when "000",
              '0' when others;
  with InInst(15 downto 11) select
    int  <= "001" when INST_INT,
            "000" when others;
  with state select
    tmp_inst <= MFPC_R6     when  "001",
                ADDSP_FF    when  "010",  
                SW_SP_R6_0  when  "011",
                LI_PART&InInst(3 downto 0) when  "100",
                SW_SP_R6_0  when "101",
                LI_R6_7     when "110",
                JR_R6       when "111",
                InInst      when others;
end behavioral;