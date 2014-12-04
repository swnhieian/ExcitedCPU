library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;
entity Hazard is
  port(
    rsD, rtD, rsE, rtE: in STD_LOGIC_VECTOR(3 downto 0);
    writeregE, writeregM, writeregW: in STD_LOGIC_VECTOR(3 downto 0);
    RegWriteE, RegWriteM, regWriteW: in STD_LOGIC;
    memtoregE, memtoregM, jump: in STD_LOGIC;
    memcontrolD: in STD_LOGIC_VECTOR(1 downto 0);
    WriteAddr: in STD_LOGIC_VECTOR(15 downto 0);
    forwardaD, forwardbD: out STD_LOGIC;
    forwardaE, forwardbE: out STD_LOGIC_VECTOR(1 downto 0);
    
    PC_pause, IF_ID_pause: out STD_LOGIC;
    RAM2_Control:out STD_LOGIC_VECTOR(1 downto 0)
    
  );
end Hazard;
architecture behavioral of Hazard is
  signal lwstall, swstall, branchstall:std_logic;
begin
  forwardaD <= FORWARDD_ALU when ((rsD /= REGF_NULL) and (rsD = writeregM) and
                                    (regwriteM = REGWRITE_YES))
                             else FORWARDD_REGF;
  forwardbD <= FORWARDD_ALU when ((rtD /= REGF_NULL) and (rtD = writeregM) and
                                   (regwriteM = REGWRITE_YES))
                             else FORWARDD_REGF;
  process(rsE, rtE, writeregM, regwriteM, writeregW, regwriteW, memcontrolD, WriteAddr)
  begin
    forwardaE <= FORWARDE_REGF;
    forwardbE <= FORWARDE_REGF;
    if (rsE /= REGF_NULL) then
      if  ((rsE = writeregM) and (regwriteM='1')) then
        forwardaE <= FORWARDE_ALU;
      elsif ((rsE = writeregW) and (regwriteW='1')) then
        forwardaE <= FORWARDE_WB;
      end if;
    end if;
    if (rtE /= REGF_NULL) then
      if ((rtE = writeregM) and (regwriteM='1')) then
        forwardbE <= FORWARDE_ALU;
      elsif ((rtE =  writeregW) and (regwriteW ='1')) then
        forwardbE <= FORWARDE_WB;
      end if;
    end if;      
  end process;
  lwstall <= '1' when ((memtoregE = MEMTOREG_MEM) and ((rtE = rsD) or (rtE = rtD)))
               else '0';
  branchstall <= '1' when ((jump='1') and
                          (
                          ((regwriteE ='1') and ((writeregE=rsD)or(writeregE=rtD)))
                          or ((memtoregM = MEMTOREG_MEM) and ((writeregM = rsD) or (writeregM = rtD)))))
                   else  '0';
  swstall <= '1' when ((memcontrolD = MEMCONTROL_WRITE) and ((WriteAddr>=USERPROGRAM_BEGIN)and(WriteAddr<USERPROGRAM_END)))
               else '0';                            
  PC_pause <= lwstall or  branchstall or swstall;
  IF_ID_pause <= lwstall or branchstall or swstall;
  with swstall select
    Ram2_Control<= MEMCONTROL_READ when '0',
                   MEMCONTROL_WRITE when others;
end behavioral;