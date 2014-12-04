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
    --debug
	   debug_pc: out STD_LOGIC_VECTOR(15 downto 0);
	 --debug
    RAM2_EN: out STD_LOGIC;
    RAM2_WE: out STD_LOGIC;
    RAM2_OE: out STD_LOGIC;
    RAM2_Data: inout STD_LOGIC_VECTOR(15 downto 0);
    RAM2_Addr: out STD_LOGIC_VECTOR(15 downto 0);
    tsre,tbre,data_ready:in std_logic;
    ram1_en,ram1_oe,ram1_we,port_oe,port_we:out std_logic;
	 MemAddrM:out std_logic_vector(15 downto 0);
    MemDataM:inout std_logic_vector(15 downto 0)
  );
end CPU;

architecture behavioral of CPU is
  component pc
  port(
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    
    pc_in : in STD_LOGIC_VECTOR(15 downto 0);
    stay : in STD_LOGIC;
    jump: in STD_LOGIC;
    jump_addr: in STD_LOGIC_VECTOR(15 downto 0);
    
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
    JumpType: out STD_LOGIC_VECTOR(2 downto 0);
    IS_SW: out STD_LOGIC
  );
  end component;
  
  component comparator is
    port(
      rst : in STD_LOGIC;
    JumpType :in STD_LOGIC_VECTOR(2 downto 0);
    RegA : in STD_LOGIC_VECTOR(15 downto 0);
    RegB : in STD_LOGIC_VECTOR(15 downto 0);
    --actually jump or not
    Jump: out STD_LOGIC
    );
  end component;
  
  component id_exe_register is
    port(
    clk, rst: in STD_LOGIC;
    --for exe
    In_ALU_A, In_ALU_B, In_Imm: in STD_LOGIC_VECTOR(15 downto 0);
    In_ALU_B_Src: in STD_LOGIC;
    In_ALU_Op: in STD_LOGIC_VECTOR(3 downto 0);
    In_JumpType: in STD_LOGIC_VECTOR(2 downto 0);
    In_Jump: in STD_LOGIC;
    In_IS_SW: in STD_LOGIC;
    In_Rs, In_Rt: in STD_LOGIC_VECTOR(3 downto 0);
    
    --for mem
    In_RAM1_Control: in STD_LOGIC_VECTOR(1 downto 0);
    
    --for wb
    In_MemtoReg : in STD_LOGIC;
    In_RegWrite: in STD_LOGIC;
    In_RegWriteAddr: in STD_LOGIC_VECTOR(3 downto 0);
    --out for exe
    Out_ALU_A, Out_ALU_B, Out_Imm: out STD_LOGIC_VECTOR(15 downto 0);
    Out_ALU_B_Src: out STD_LOGIC;
    Out_ALU_Op: out STD_LOGIC_VECTOR(3 downto 0);
    Out_JumpType: out STD_LOGIC_VECTOR(2 downto 0);
    Out_Jump: out STD_LOGIC;
    OUT_IS_SW: out STD_LOGIC;
    Out_Rs, Out_Rt: out STD_LOGIC_VECTOR(3 downto 0);
    --out for mem
    Out_RAM1_Control: out STD_LOGIC_VECTOR(1 downto 0);
    
    --out for wb
    Out_MemtoReg : out STD_LOGIC;
    Out_RegWrite: out STD_LOGIC;
    Out_RegWriteAddr: out STD_LOGIC_VECTOR(3 downto 0) 
    );
  end component; 
  
  component alu is
    port(
    srcA : in STD_LOGIC_VECTOR(15 downto 0);
    srcB : in STD_LOGIC_VECTOR(15 downto 0);
    op   : in STD_LOGIC_VECTOR(3 downto 0);
    
    result : out STD_LOGIC_VECTOR(15 downto 0)
    );
  end component;
  
  component JumpAddrMux is
  port(
    ALUresult: in STD_LOGIC_VECTOR(15 downto 0);
    JumpType: in STD_LOGIC_VECTOR(2 downto 0);
    ALU_B: in STD_LOGIC_VECTOR(15 downto 0);
    
    OutAddr: out STD_LOGIC_VECTOR(15 downto 0)    
  );
end component;

component EXE_MEM_Register is
  port(
    clk,rst: in STD_LOGIC;
    
    --for mem
    In_RAM1_Control: in STD_LOGIC_VECTOR(1 downto 0);
    In_RAM1_Addr: in STD_LOGIC_VECTOR(15 downto 0);
    In_RAM1_InData: in STD_LOGIC_VECTOR(15 downto 0);    
    
    --for wb
    In_MemtoReg : in STD_LOGIC;
    In_ALUResult: in STD_LOGIC_VECTOR(15 downto 0);
    In_RegWrite: in STD_LOGIC;
    In_RegWriteAddr: in STD_LOGIC_VECTOR(3 downto 0);
    --out for mem
    Out_RAM1_Control: out STD_LOGIC_VECTOR(1 downto 0);
    Out_RAM1_Addr: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RAM1_InData: out STD_LOGIC_VECTOR(15 downto 0);  
    
    --out for wb
    Out_MemtoReg : out STD_LOGIC;
    Out_ALUResult: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RegWrite: out STD_LOGIC;
    Out_RegWriteAddr: out STD_LOGIC_VECTOR(3 downto 0) 
  );
end component;

component MEM_WB_Register is
  port(
    clk,rst: in STD_LOGIC;
    
    In_MemtoReg : in STD_LOGIC;
    In_ALUResult: in STD_LOGIC_VECTOR(15 downto 0);
    In_RegWrite: in STD_LOGIC;
    In_MemData: in STD_LOGIC_VECTOR(15 downto 0);
    In_RegWriteAddr: in STD_LOGIC_VECTOR(3 downto 0);

    Out_MemtoReg : out STD_LOGIC;
    Out_ALUResult: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RegWrite: out STD_LOGIC;
    Out_MemData: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RegWriteAddr: out STD_LOGIC_VECTOR(3 downto 0) 
  );
end component;

component Hazard is
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
end component;
  
component memtoregMux2 is
  port (
    alu, mem: in STD_LOGIC_VECTOR(15 downto 0);
    memtoreg: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;  

component alubsrcMux2 is
  port (
    reg, imm: in STD_LOGIC_VECTOR(15 downto 0);
    alu_b_src: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;

component forwardEMux4 is
  port (
    ori, alu, mem: in STD_LOGIC_VECTOR(15 downto 0);
    s: in STD_LOGIC_VECTOR(1 downto 0);
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;


component forwardDMux2 is
  port (
    reg, alu: in STD_LOGIC_VECTOR(15 downto 0);
    s: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;

component pcwriteMux2 is
  port (
    pc, write: in STD_LOGIC_VECTOR(15 downto 0);
    s: in STD_LOGIC_VECTOR(1 downto 0);
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;

component RAM1 is
    port(
        -- input
		  rst : in std_logic;
        clk : in std_logic;
        reg_addr, reg_data : inout std_logic_vector(15 downto 0);
        read_write : inout std_logic_vector(1 downto 0);
        tsre, tbre : in std_logic;
        data_ready : in std_logic;
  
        -- output  		  
        ram1_en : out std_logic;
        ram1_oe, ram1_we : out std_logic;
        port_oe, port_we : out std_logic; -- port_oe = rdn, port_we = wrn
        mem_addr : out std_logic_vector(15 downto 0);
        mem_data : inout std_logic_vector(15 downto 0)
    );
end component;

  
  
  signal clk :std_logic;
  signal next_pc, pc_plus_oneF, pc_to_ram2: std_logic_vector(15 downto 0):=ZERO;
  signal instD: std_logic_vector(15 downto 0):=NOP;
  signal ALU_OpD: std_logic_vector(3 downto 0):=ALUOP_NULL;
  signal REGF_AD, REGF_BD: std_logic_vector(3 downto 0):=REGF_NULL;
  signal ImmD:std_logic_vector(15 downto 0):=ZERO;
  signal ALU_B_SrcD, ALU_B_SRCE, RegWriteD, MemtoRegD:std_logic;
  signal RegWriteAddrD, regWriteAddrE, RegWriteAddrW, RegWriteAddrM:std_logic_vector(3 downto 0);
  signal MEMControlD: std_logic_vector(1 downto 0);
  signal JumpTypeD: std_logic_vector(2 downto 0);
  signal REGF_OutAD, REGF_OutBD: std_logic_vector(15 downto 0):=ZERO;
  signal JumpD, JumpE: std_logic;
  signal RAM2Control: std_logic_vector(1 downto 0):=MEMCONTROL_READ;
  signal IS_SWD,IS_SWE:std_logic;
  signal RegWriteW, regwriteE, regwriteM:std_logic;
  signal rega_mux, regb_mux, ALU_AE, ALU_BE, alua_mux, alub_mux:std_logic_vector(15 downto 0);
  signal ImmE:std_logic_vector(15 downto 0);
  signal RsE, RtE: std_logic_vector(3 downto 0);
  signal RAM1_ControlE, RAM1_ControlM:std_logic_vector(1 downto 0);
  signal memtoregE, memtoregM, MemtoRegW:std_logic;
  signal ALU_ResultE, ALU_ResultM, ALU_ResultW:std_logic_vector(15 downto 0);
  signal ALU_OpE:std_logic_vector(3 downto 0);
  signal JumpTypeE:std_logic_vector(2 downto 0);
  signal forwardae,forwardbe:std_logic_vector(1 downto 0);
  signal forwardad,forwardbd:std_logic;
  signal alu_b_te, alu_a_te, Memdataw:std_logic_vector(15 downto 0);
  signal ram1_indataM, regf_inDataW:std_logic_vector(15 downto 0);
  signal hazard_if_id_pause, hazard_pc_pause, if_id_register_int:std_logic;
  signal hazard_RAM2_Control:std_logic_vector(1 downto 0);
  signal Jump_AddrE, hazard_ram2_Indata_mux, pcd:std_logic_vector(15 downto 0);
  signal pcstay, ifidstay:std_logic;
  signal ram1_addrM, pc_or_write_mux:std_logic_vector(15 downto 0);
  
begin
  --debug
  debug_pc<=alua_mux;
  --debug
  ufredivider:
    fredivider port map(
      clkin=>clk_ori,clkout=>clk
    );
  pcstay <=hazard_pc_pause or if_id_register_int;
  upc:
    pc port map(
      clk=>clk, rst=>rst, pc_in=>pc_plus_oneF, stay=>pcstay, jump=>JumpD, jump_addr=>Jump_AddrE,
      pc_plus_one=>pc_plus_oneF, pc_out => pc_to_ram2
    );
    
  uram2:
    ram2 port map(
      clk=>clk, RAM2_Control=>hazard_RAM2_Control,RAM2_InData=>RAM1_InDataM,
      RAM2_InAddr=>pc_or_write_mux, RAM2_EN=>RAM2_EN, RAM2_WE=>RAM2_WE,
      RAM2_OE=>RAM2_OE, RAM2_Data=>RAM2_Data, RAM2_Addr=>RAM2_Addr
    );
    
  upcwriteMux2:
    pcwriteMux2 port map(
      pc=>pc_to_ram2,write=>RAM1_AddrM,
      s=>hazard_RAM2_Control,y=>pc_or_write_mux
    );
   
    
    
  ifidstay <=jumpD or jumpE or hazard_if_id_pause or IS_SWD or IS_SWE;  --??is it right?
  uif_id_register:
    if_id_register port map(
      clk=>clk, rst=>rst, InInst=>RAM2_Data, InPC=>pc_plus_oneF,
      stay=>ifidstay, PC_INT=>if_id_register_int, OutPC=>pcD, OutInst=>instD
    );
  
  ucontroller:
    controller port map(
      CTRL_Inst=>instD, ALU_Op=>ALU_opD, REGF_A=>REGF_AD,
      REGF_B=>REGF_BD, Imm=>ImmD, ALU_B_Src=>ALU_B_SrcD,
      MEMControl=>MEMControlD, RegWrite=>RegWriteD,
      RegWrite_Addr=>RegWriteAddrD, MemtoReg=>MemtoRegD,
      JumpType=>JumpTypeD, IS_SW=>IS_SWD
    );
    
  uregisterfile:
    registerfile port map(
      clk=>clk, rst=>rst, REGF_SrcA=>REGF_AD, REGF_SrcB=>REGF_BD,
      REGF_InAddr=>RegWriteAddrW, REGF_WE=>RegWriteW,
      REGF_InData=>REGF_InDataW, REGF_InPC=>pcD,
      REGF_OutA=>REGF_OutAD, REGF_OutB=>REGF_OutBD
    );
    
  ucomparator:
    comparator port map(
      rst=>rst, JumpType=>JumpTypeD, RegA=>rega_mux, RegB=>regb_mux, Jump=>JumpD
    );
    
  uid_exe_register:
    id_exe_register port map(
      clk=>clk, rst=>rst,
      In_ALU_A=>rega_mux, In_ALU_B=>regb_mux, In_Imm=>ImmD,
      In_ALU_B_Src=>ALU_B_SrcD, In_ALU_Op=>ALU_OpD, In_JumpType=>JumpTypeD,
      In_Jump=>JumpD,
      In_IS_SW=>IS_SWD, In_Rs=>REGF_AD,In_Rt=>REGF_BD,In_RAM1_Control=>MEMControlD,
      In_MemtoReg=>MemtoRegD, In_RegWrite=>RegWriteD, 
      In_RegWriteAddr=>RegWriteAddrD, Out_ALU_A=>ALU_AE,
      Out_ALU_B=>ALU_BE, Out_Imm=>ImmE, Out_ALU_B_Src=>ALU_B_SrcE,
      Out_ALU_Op=>ALU_OpE, Out_JumpType=>JumpTypeE, Out_Jump=>JumpE,
      Out_IS_SW=>IS_SWE, Out_Rs=>RsE, Out_Rt=>RtE, Out_RAM1_Control=>RAM1_ControlE,
      Out_MemtoReg=>MemtoRegE, Out_RegWrite=>RegWriteE,
      Out_RegWriteAddr=>RegWriteAddrE
    );
    
  ualu:
    alu port map(
      srcA=>alua_mux,srcB=>alub_mux,op=>ALU_OpE,
      result=>ALU_ResultE      
    );
  
  uJumpAddrMux:
    JumpAddrMux port map(
      ALUResult=>ALU_ResultE, JumpType=>JumpTypeE,
      ALU_B=>ALU_B_TE, OutAddr=>Jump_AddrE
    );
  
  uexe_mem_register:
    EXE_MEM_REGISTER port map(
      clk=>clk, rst=>rst,
      In_RAM1_Control=>RAM1_ControlE, In_RAM1_Addr=>ALU_ResultE,
      In_RAM1_InData=>ALU_BE, In_MemtoReg=>MemtoRegE, In_ALUResult=>ALU_ResultE,
      In_RegWrite=>RegWriteE, In_RegWriteAddr=> RegWriteAddrE,
      Out_RAM1_Control=>RAM1_ControlM, Out_RAM1_Addr=>RAM1_AddrM,
      Out_RAM1_InData=>RAM1_InDataM, Out_MemtoReg=>MemtoRegM, Out_ALUResult=>ALU_ResultM,
      Out_RegWrite=>RegWriteM, Out_RegWriteAddr=>RegWriteAddrM
    );
  
  uram1:
    ram1 port map(
      rst=>rst, clk=>clk,
      reg_addr=>RAM1_AddrM,reg_data=>RAM1_InDataM,
      read_write=>RAM1_ControlM,tsre=>tsre,tbre=>tbre,
      data_ready=>data_ready,ram1_en=>ram1_en,
      ram1_oe=>ram1_oe, ram1_we=>ram1_we, port_oe=>port_oe, port_we=>port_we,
      mem_addr=>MemAddrM,mem_data=>MemDataM
    );
    
  umem_wb_register:
    MEM_WB_Register port map(
      clk=>clk, rst=>rst,
      In_MemtoReg=>MemtoRegM, In_ALUResult=>ALU_ResultM,
      In_RegWrite=>RegWriteM, In_MemData=>MemDataM, In_RegWriteAddr=>RegWriteAddrM,
      Out_MemtoReg=>MemtoRegW, Out_ALUResult=>ALU_ResultW,
      Out_RegWrite=>RegWriteW, Out_MemData=>MemDataW, Out_RegWriteAddr=>RegWriteAddrW
      );
  
  uhazard:
    Hazard port map(
      rsD=>REGF_AD,rtD=>REGF_BD,rsE=>RsE,rtE=>RtE,
      writeregE=>RegWriteAddrE, writeregM=>RegWriteAddrM, writeregW=>RegWriteAddrW,
      RegWriteE=>regWriteE,RegWriteM=>regWriteM,RegWriteW=>regWriteW,
      memtoregE=>memtoregE,memtoregM=>memtoregM,jump=>JumpD,
      memcontrolD=>MEMControlD, WriteAddr=>ALU_ResultE,
      forwardaD=>forwardaD,forwardbD=>forwardbD,
      forwardaE=>forwardaE,forwardbE=>forwardbE,
      PC_Pause=>hazard_pc_pause,IF_ID_pause=>hazard_if_id_pause,
      RAM2_Control=>hazard_RAM2_Control
    );   
    
  umemtoregmux2:
    memtoregMux2 port map(
      alu=>ALU_ResultW,mem=>MemDataW,memtoreg=>MemtoRegW,
      y=> REGF_InDataW
    );
    
  ualubsrcMux2:
    alubsrcMux2 port map(
      reg=>ALU_BE, imm=>ImmE, alu_b_src=>ALU_B_SRCE,
      y=>ALU_B_TE
    );
  
  uforwardAE:
    forwardEMux4 port map(
      ori=>ALU_AE,alu=>ALU_ResultM,mem=>REGF_InDataW,
      s=>forwardaE,y=>alua_mux
    );
  uforwardBe:
    forwardEMux4 port map(
      ori=>ALU_B_TE,alu=>ALU_ResultM,mem=>REGF_InDataW,
      s=>forwardbE,y=>alub_mux
    );
    
  uforwardAD:
    forwardDMux2 port map(
     reg=>REGF_OutAD,alu=>ALU_ResultM,s=> forwardaD,
     y=>rega_mux
     );
      
  uforwardBD:
    forwardDMux2 port map(
      reg=>REGF_OutBD,alu=>ALU_ResultM,s=> forwardbD,
     y=>regb_mux
    );
     
  
  
    
    
  
end behavioral;
