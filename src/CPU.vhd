library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity CPU is
  port(
    clk_ori: in STD_LOGIC;
    rst: in STD_LOGIC;
    
    RAM2_EN: out STD_LOGIC;
    RAM2_WE: out STD_LOGIC;
    RAM2_OE: out STD_LOGIC;
    RAM2_Data: inout STD_LOGIC_VECTOR(15 downto 0);
    RAM2_Addr: out STD_LOGIC_VECTOR(15 downto 0)
  );
end CPU;

architecture behavioral of CPU is
  component pc
  port(
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
     
    pc_in : in STD_LOGIC_VECTOR(15 downto 0);
    stay : in STD_LOGIC;
      
    pc_plus_one: out STD_LOGIC_VECTOR(15 downto 0);
    pc_out : out STD_LOGIC_VECTOR(15 downto 0)
  );
  end component;
  
  component registerfile
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
  end component;
  
  component fredivider
  port(
    clkin:in STD_LOGIC;
    clkout:out STD_LOGIC
  );
  end component;
  
  component ram2
  port(
    clk : in STD_LOGIC;
    RAM2_Control: in STD_LOGIC_VECTOR(1 downto 0);
    RAM2_InData: in STD_LOGIC_VECTOR(15 downto 0);
    RAM2_InAddr: in STD_LOGIC_VECTOR(15 downto 0);
    
    RAM2_EN: out STD_LOGIC;
    RAM2_WE: out STD_LOGIC;
    RAM2_OE: out STD_LOGIC;
    RAM2_Data: inout STD_LOGIC_VECTOR(15 downto 0);
    RAM2_Addr: out STD_LOGIC_VECTOR(15 downto 0)
  );
  end component;
  
  component IF_ID_Register
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
  end component;
  
  component controller
  port(
    CTRL_Inst: in STD_LOGIC_VECTOR(15 downto 0); -- Instruction from IF
    
    ALU_Op: out STD_LOGIC_VECTOR(3 downto 0);
    REGF_A: out STD_LOGIC_VECTOR(3 downto 0);
    REGF_B: out STD_LOGIC_VECTOR(3 downto 0);
    Imm: out STD_LOGIC_VECTOR(15 downto 0);
    ALU_B_Src: out STD_LOGIC;
    MEMControl: out STD_LOGIC_VECTOR(1 downto 0);
    RegWrite : out STD_LOGIC;
    RegWrite_Addr: out STD_LOGIC_VECTOR(3 downto 0);
    MemtoReg: out STD_LOGIC;
    JumpType: out STD_LOGIC_VECTOR(2 downto 0)
  );
  end component;
  
  component PCAdder
  port(
    rst : in STD_LOGIC;
    PC_PLUS_ONE :in STD_LOGIC_VECTOR(15 downto 0);
    JumpType :in STD_LOGIC_VECTOR(2 downto 0);
    Imm : in STD_LOGIC_VECTOR(15 downto 0);
    RegA : in STD_LOGIC_VECTOR(15 downto 0);
    RegB : in STD_LOGIC_VECTOR(15 downto 0);
    
    Out_PC : out STD_LOGIC_VECTOR(15 downto 0)
  );
  end component;
    
  
  
  signal clk :std_logic;
  signal next_pc, pc_plus_oneF, pc_plus_oneD, pc_to_ram2: std_logic_vector(15 downto 0):=ZERO;
  signal instD: std_logic_vector(15 downto 0):=NOP;
  signal ALU_OpD: std_logic_vector(3 downto 0):=ALUOP_NULL;
  signal REGF_AD, REGF_BD: std_logic_vector(3 downto 0):=REGF_NULL;
  signal ImmD:std_logic_vector(15 downto 0):=ZERO;
  signal ALU_B_SrcD, RegWriteD, MemtoRegD:std_logic;
  signal RegWrite_AddrD:std_logic_vector(3 downto 0);
  signal MEMControlD: std_logic_vector(1 downto 0);
  signal JumpTypeD: std_logic_vector(2 downto 0);
  signal REGF_OutAD, REGF_OutBD: std_logic_vector(15 downto 0):=ZERO;
  signal JumpD: std_logic;
begin
  ufredivider:
    fredivider port map(
      clkin=>clk_ori,clkout=>clk
    );
    
  upc:
    pc port map(
      clk=>clk, rst=>rst, pc_in=>next_pc, stay=>??, pc_plus_one=>pc_plus_oneF,
      pc_out => pc_to_ram2
    );
    
  uram2:
    ram2 port map(
      clk=>clk, RAM2_Control=>???,RAM2_InData=>??,
      RAM2_InAddr=>??, RAM2_EN=>RAM2_EN, RAM2_WE=>RAM2_EN,
      RAM2_OE=>RAM2_OE, RAM2_Data=>RAM2_Data, RAM2_Addr=>RAM2_Addr
    );
    
  uif_id_register:
    if_id_register port map(
      clk=>clk, rst=>rst, InInst=>??, InPC=>pc_plus_oneF, stay=>??,
      PC_, OutPC=>pc_plus_oneD, OutInst=>instD
    );
  
  ucontroller:
    controller port map(
      CTRL_Inst=>instD, ALU_Op=>ALU_opD, REGF_A=>REGF_AD,
      REGF_B=>REGF_BD, Imm=>ImmD, ALU_B_Src=>ALU_B_SrcD,
      MEMControl=>MEMControlD, RegWrite=>RegWriteD,
      RegWrite_Addr=>RegWrite_AddrD, MemtoReg=>MemtoRegD,
      JumpType=>JumpTypeD
    );
    
  uregisterfile:
    registerfile port map(
      clk=>clk, rst=>rst, REGF_SrcA=>REGF_AD, REGF_B=>REGF_BD,
      REGF_InAddr=>RegWrite_AddrW, REGF_WE=>RegWriteW,
      REGF_InData=>??(from mux), REGF_InPC=>pc_plus_oneD,
      REGF_OutA=>REGF_OutAD?(needs forward), REGF_OutB=>REGF_OutBD?(needs forward)
    );
    
  upcadder:
    pcadder port map(
      rst=>rst, PC_PLUS_ONE=>pc_plus_oneD, JumpType=>JumpTypeD,
      Imm=>ImmD, RegA=>REGF_OutAD>(needs forward),RegB=>REGF_OutBD?(needs forward),
      Jump=>JumpD, Out_PC=>next_pc
    );
    
  uid_exe_register:
    id_exe_register port map(
      REGF_
    );
    
  ualu:
    alu port map(
      
    );
  
  uexe_mem_register:
  
  uram1:
  
  uhazard:
  
  
    
    
  
end behavioral;
