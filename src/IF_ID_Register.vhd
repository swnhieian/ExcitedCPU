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
    InPC : in STD_LOGIC_VECTOR(15 downto 0);
    --check if need to insert nop
    stay : in STD_LOGIC;
    --here handle interrupt
    PC_INT : out STD_LOGIC;
    OutPC : out STD_LOGIC_VECTOR(15 downto 0);
    OutInst : out STD_LOGIC_VECTOR(15 downto 0)
  );
end IF_ID_Register;

architecture behavioral of IF_ID_Register is
  signal tmp_inst: std_logic_vector(15 downto 0);
  signal state: std_logic_vector(3 downto 0);
  signal start : std_logic_vector(3 downto 0);
begin
  process(clk, rst, state)
  begin
    if rst = '0' then
      state <= "0000";
      OutPC <= ZERO;
    elsif clk'event and clk='1' then        
      case state is
        when "0000" => state<=start;
        when "1111" => state<=start;
        when "0001" => state<="0010";
        when "0010" => state<="0011";
        when "0100" => state<="0101";
        when "0101" => state<="0110";
        when "0110" => state<="0111";
        when others => state<="0000";
      end case;
      OutPC <= InPC;
      OutInst <= tmp_inst;
    end if;
  end process;
  with state select
    PC_INT <= '1' when "0000",
              '1' when "1111",--??not sure this line needs or not
              '0' when others;
  process(stay, InInst, clk)
  begin
--    if clk'event and clk='1' then
      if stay='1' then
        start <= "1111";
      elsif stay='0' then
        case InInst(15 downto 11) is
          when INST_INT => start<="0001";
          when others   => start<="0000";
        end case;
      end if;
  --  end if;
  end process;
  with state select
    tmp_inst <= MFPC_R6     when  "0001",
                ADDSP_FF    when  "0010",  
                SW_SP_R6_0  when  "0011",
                LI_PART&InInst(3 downto 0) when  "0100",
                SW_SP_R6_0  when "0101",
                LI_R6_7     when "0110",
                JR_R6       when "0111",
                NOP         when "1111",
                InInst      when others;
end behavioral;