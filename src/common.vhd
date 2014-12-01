library IEEE;
use IEEE.STD_LOGIC_1164.all;

package common is
  constant ZERO : std_logic_vector(15 downto 0) := "0000000000000000";
  
  constant ALUOP_ADD : std_logic_vector(2 downto 0) := "000";
  constant ALUOP_SUB : std_logic_vector(2 downto 0) := "001";
  constant ALUOP_AND : std_logic_vector(2 downto 0) := "010";
  constant ALUOP_OR  : std_logic_vector(2 downto 0) := "011";
  constant ALUOP_NOT : std_logic_vector(2 downto 0) := "100";
  constant ALUOP_SLL : std_logic_vector(2 downto 0) := "101";
  constant ALUOP_SRA  : std_logic_vector(2 downto 0) := "110";
  constant ALUOP_NULL : std_logic_vector(2 downto 0) := "111";
  --control signals
  constant ALU_B_SRC_IMM: std_logic := '1';
  constant ALU_B_SRC_REGF: std_logic := '0';
  constant REGWRITE_YES : std_logic:='1';
  constant REGWRITE_NO : std_logic:='0';
  constant MEMTOREG_ALU : std_logic:='0';
  constant MEMTOREG_MEM : std_logic:='1';
  constant IS_JUMP_YES: std_logic:='0';
  constant IS_JUMP_NO : std_logic:='1';
  --about register files --
  constant REGF_REGNUM : integer := 15;  --start from 0
    --0 to 7 common registers
    --8 IH
  constant REGF_IH : std_logic_vector(3 downto 0) := "1000";
    --9 T
  constant REGF_T : std_logic_vector(3 downto 0) := "1001";
    --10 SP
  constant REGF_SP : std_logic_vector(3 downto 0) := "1010";
    --11 JA
  constant REGF_JA : std_logic_vector(3 downto 0) := "1011";
    --12 PC
  constant REGF_PC : std_logic_vector(3 downto 0) := "1100";
  constant REGF_NULL : std_logic_vector(3 downto 0) := "1101";

  --instructions--  
  constant INST_NOP         : std_logic_vector(4 downto 0) := "00001";
  constant INST_B           : std_logic_vector(4 downto 0) := "00010";
  constant INST_BEQZ        : std_logic_vector(4 downto 0) := "00100";
  constant INST_BNEZ        : std_logic_vector(4 downto 0) := "00101";
  constant INST_SHIFT_M     : std_logic_vector(4 downto 0) := "00110"; --SRA, SLL
  constant INST_ADDIU3      : std_logic_vector(4 downto 0) := "01000";
  constant INST_ADDIU       : std_logic_vector(4 downto 0) := "01001";  
  constant INST_BRANCH_M    : std_logic_vector(4 downto 0) := "01100"; --BTEQZ, BTNEZ, MTSP, ADDSP
  constant INST_LI          : std_logic_vector(4 downto 0) := "01101";
  constant INST_LW_SP       : std_logic_vector(4 downto 0) := "10010";
  constant INST_LW          : std_logic_vector(4 downto 0) := "10011";
  constant INST_SP          : std_logic_vector(4 downto 0) := "11010";
  constant INST_SW          : std_logic_vector(4 downto 0) := "11011";
  constant INST_OPU_M       : std_logic_vector(4 downto 0) := "11100"; --SUBU, ADDU
  constant INST_LOGICJUMP_M : std_logic_vector(4 downto 0) := "11101"; --AND, CMP, JALR, JR, JRRA, MFPC, NOT, OR, SLTU
  constant INST_IH_M        : std_logic_vector(4 downto 0) := "11110"; --MTIH, MFIH
  constant INST_INT         : std_logic_vector(4 downto 0) := "11111";
  
  --about interrupt --
  constant MFPC_R6          : std_logic_vector(15 downto 0) := "1110111001000000";
  constant ADDSP_FF         : std_logic_vector(15 downto 0) := "0110001111111111";
  constant SW_SP_R6_0       : std_logic_vector(15 downto 0) := "1101011000000000";
  constant LI_R6_7          : std_logic_vector(15 downto 0) := "0110111000000111";
  constant JR_R6            : std_logic_vector(15 downto 0) := "1110111000000000";
  constant LI_PART          : std_logic_vector(11 downto 0) := "011011100000";
  constant NOP              : std_logic_vector(15 downto 0) := "0000100000000000";
  
  
  --about mem--
  constant HIGH_Z : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";
  constant MEMCONTROL_READ : std_logic_vector(1 downto 0):= "01";
  constant MEMCONTROL_WRITE: std_logic_vector(1 downto 0):= "10";
  constant MEMCONTROL_DISABLE: std_logic_vector(1 downto 0):= "11";
  
  type control_signals is
  record
    ALU_Op: STD_LOGIC_VECTOR(2 downto 0);
    --two read address to register files
    REGF_A: STD_LOGIC_VECTOR(3 downto 0);
    REGF_B: STD_LOGIC_VECTOR(3 downto 0);
    --immediate number after extend
    Imm: STD_LOGIC_VECTOR(15 downto 0);
    --ALU_B from immediate number or register files
    ALU_B_Src: STD_LOGIC;
    --MEM control signals
    MEMControl: STD_LOGIC_VECTOR(1 downto 0);
    --need to write back to register files or not
    RegWrite : STD_LOGIC;
    --which register to write data
    RegWrite_Addr: STD_LOGIC_VECTOR(3 downto 0);
    --write data from ALU result or MEM
    MemtoReg: STD_LOGIC;
    --is jump or branch instruction
    IS_Jump : STD_LOGIC;
  end record;
  function generate_control(
    ALU_OP: in STD_LOGIC_VECTOR(2 downto 0);
    REGF_A: in STD_LOGIC_VECTOR(3 downto 0);
    REGF_B: in STD_LOGIC_VECTOR(3 downto 0);
    Imm: in STD_LOGIC_VECTOR(15 downto 0);
    ALU_B_Src: in STD_LOGIC;
    MEMControl: in STD_LOGIC_VECTOR(1 downto 0);
    RegWrite: in STD_LOGIC;
    RegWrite_Addr: in STD_LOGIC_VECTOR(3 downto 0);
    MemtoReg: in STD_LOGIC;
    IS_Jump: in STD_LOGIC
  ) return control_signals;
end common;
package body common is
  function generate_control(
    ALU_OP: in STD_LOGIC_VECTOR(2 downto 0);
    REGF_A: in STD_LOGIC_VECTOR(3 downto 0);
    REGF_B: in STD_LOGIC_VECTOR(3 downto 0);
    Imm: in STD_LOGIC_VECTOR(15 downto 0);
    ALU_B_Src: in STD_LOGIC;
    MEMControl: in STD_LOGIC_VECTOR(1 downto 0);
    RegWrite: in STD_LOGIC;
    RegWrite_Addr: in STD_LOGIC_VECTOR(3 downto 0);
    MemtoReg: in STD_LOGIC;
    IS_Jump: in STD_LOGIC
  ) return control_signals is
    variable tmp: control_signals;
  begin
    tmp.ALU_OP := ALU_OP;
    tmp.REGF_A := REGF_A;
    tmp.REGF_B := REGF_B;
    tmp.Imm := Imm;
    tmp.ALU_B_Src := ALU_B_Src;
    tmp.MEMControl := MEMControl;
    tmp.RegWrite := RegWrite;
    tmp.RegWrite_Addr:= RegWrite_Addr;
    tmp.MemtoReg := MemtoReg;
    tmp.IS_Jump := IS_Jump;
    return tmp;
  end generate_control;
   
end common;
