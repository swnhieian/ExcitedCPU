library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity freDivider is
  port(
    clkin:in STD_LOGIC;
    clkout:out STD_LOGIC
  );
end freDivider;

architecture behavioral of freDivider is
  signal data:integer range 0 to 1;
  signal q:STD_LOGIC:='0';
begin 
  process(clkin)
  begin
    if rising_edge(clkin) then
      if (data = 1) then
        data<=0;
        q<=not q;
      else
        data<=data+1;
      end if;
    end if;
    clkout<=q;
  end process;  
end behavioral;