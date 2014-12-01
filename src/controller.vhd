library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity controller is
  port(
    CTRL_Inst: in STD_LOGIC_VECTOR(15 downto 0); -- Instruction from IF
    
    ALU_Op: out STD_LOGIC_VECTOR(2 downto 0);
    REGF_A: out STD_LOGIC_VECTOR(3 downto 0);
    REGF_B: out STD_LOGIC_VECTOR(3 downto 0);
    Imm: out STD_LOGIC_VECTOR(15 downto 0);
    ALU_B_Src: out STD_LOGIC;
    MEMControl: out STD_LOGIC_VECTOR(1 downto 0);
    RegWrite : out STD_LOGIC;
    RegWrite_Addr: out STD_LOGIC_VECTOR(3 downto 0);
    MemtoReg: out STD_LOGIC
    
    
    
    
  );
end controller;

architecture behavioral of controller is
  signal IMM_12: std_logic_vector(11 downto 0);
  signal IMM_8: std_logic_vector(7 downto 0);
begin
  process(CTRL_Inst)
    variable cs: control_signals;
  begin
    case (CTRL_Inst(15 downto 11)) is
      when INST_NOP          =>
        cs:=generate_control(ALUOP_NULL, REGF_NULL, REGF_NULL, ZERO, ALU_B_SRC_REGF, 
                             MEMCONTROL_DISABLE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU, IS_JUMP_NO);
      when INST_B            =>
        --???
        --cs:=generate_control(ALUOP_
      when INST_BEQZ         =>
        --???
      when INST_BNEZ         =>
        --???
      when INST_ADDIU3       =>
        IMM_12 <= (others => CTRL_Inst(3));
        cs:=generate_control(ALUOP_ADD, CTRL_Inst(10 downto 8), REGF_NULL, IMM_12&CTRL_Inst(3 downto 0), 
                             ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(7 downto 5),MEMTOREG_ALU, IS_JUMP_NO);
      when INST_ADDIU        =>
        IMM_8 <= (others => CTRL_Inst(7));
        cs:=generate_control(ALUOP_ADD, CTRL_Inst(10 downto 8), REGF_NULL, IMM_8&CTRL_Inst(7 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8),MEMTOREG_ALU, IS_JUMP_NO);
      when INST_LI           =>
        IMM_8 <= (others => '0');
        cs:=generate_control(ALUOP_NULL, REGF_NULL, REGF_NULL, IMM_8&CTRL_Inst(7 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8),MEMTOREG_ALU, IS_JUMP_NO);
      when INST_LW_SP        =>
      when INST_LW           =>
      when INST_SP           =>
      when INST_SW           =>
      -- multiple instructions--
      when INST_SHIFT_M      =>
      when INST_BRANCH_M     =>
      when INST_OPU_M        =>
      when INST_LOGICJUMP_M  =>
      when INST_IH_M         =>
      when others            =>
    end case;
  end process;
end behavioral;
