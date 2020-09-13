--MSX SVI-728. Specs:
--	• Microprocessor T80 3.57 MHz
--	• 32 KB ROM SVI-728 spanish, Slot 0
--	• 64 KB RAM, Slot 3
--	• PPI I82C55
--	• VDP TMS9918A outputs VGA + HDMI, 640x480x60 Hz
--	• PSG YM2149
--	• Serial Port
--	• Cassette input
--Javier Abadía / jabadiagm@gmail.com
--Structure based on Multicomputer by Grant Searle:
--           http://searle.x10host.com/Multicomp/index.html


library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_UNSIGNED.all; --enable "+" over std_logic_vector
Library UNISIM; --OBUFDS to drive hdmi signals
use UNISIM.vcomponents.all;

entity MSX_SVI728 is
	port(
		ex_n_reset		: in std_logic:='1';
		clk125			: in std_logic:='0';
		rxd1			: in std_logic:='1';
		txd1			: out std_logic:='1';
		serialClockout		: out  std_logic;
		cpuClockout: out std_logic;
		sdClockout    : out std_logic;
		
		ex_vgaVsync   : out std_logic;
		ex_vgaHsync   : out std_logic;
		ex_vgaRed0    : out std_logic;
		ex_vgaRed1    : out std_logic;
		ex_vgaRed2    : out std_logic;
		ex_vgaRed3    : out std_logic;
		ex_vgaGreen0  : out std_logic;
		ex_vgaGreen1  : out std_logic;
		ex_vgaGreen2  : out std_logic;
		ex_vgaGreen3  : out std_logic;
		ex_vgaBlue0   : out std_logic;
		ex_vgaBlue1   : out std_logic;
		ex_vgaBlue2   : out std_logic;
		ex_vgaBlue3   : out std_logic;
		
		ex_pwmOut     : out std_logic;
		ex_pwmEnable  : out std_logic:='1';
		
		--SPI bus for keyboard
        ex_SPI_SS_n   : in STD_LOGIC;
        ex_SPI_MOSI   : in STD_LOGIC;
        ex_SPI_CLK    : in STD_LOGIC;		
        
        --hdmi out
        data_p    : out  STD_LOGIC_VECTOR(2 downto 0);
        data_n    : out  STD_LOGIC_VECTOR(2 downto 0);
        clk_p          : out    std_logic;
        clk_n          : out    std_logic;        
        
        --cassette input
        ex_cassetteIn : in std_logic:='0';
		
		ex_led0           : out std_logic:='0';
		ex_led1           : out std_logic:='0';
		ex_led2           : out std_logic:='0';
		ex_led3           : out std_logic:='0';
		ex_led4           : out std_logic:='0';
		ex_led5           : out std_logic:='0'

	);
end MSX_SVI728;

architecture struct of MSX_SVI728 is

  attribute DONT_TOUCH : string;
--  attribute DONT_TOUCH of  cpu1 : label is "TRUE";
--  attribute DONT_TOUCH of  ram1 : label is "TRUE";
--  attribute DONT_TOUCH of  rom1 : label is "TRUE";
--  attribute DONT_TOUCH of  io1 : label is "TRUE";
--  attribute DONT_TOUCH of  ppi1 : label is "TRUE";
--  attribute DONT_TOUCH of  vdp1 : label is "TRUE";


	signal n_WR							: std_logic;
	signal n_RD							: std_logic;
	signal cpuAddress					: std_logic_vector(15 downto 0);
	signal cpuDataOut					: std_logic_vector(7 downto 0);
	signal cpuDataIn					: std_logic_vector(7 downto 0);

--	signal basRomData					: std_logic_vector(7 downto 0);
	signal internalRam1DataOut		   : std_logic_vector(7 downto 0);
	signal internalRam2DataOut		   : std_logic_vector(7 downto 0);
	signal interface1DataOut		 : std_logic_vector(7 downto 0);
--	signal interface2DataOut		 : std_logic_vector(7 downto 0);
--	signal sdCardDataOut				: std_logic_vector(7 downto 0);

	signal n_memWR						: std_logic :='1';
	signal n_memRD 					: std_logic :='1';

	signal n_ioWR						: std_logic :='1';
	signal n_ioRD 						: std_logic :='1';
	
	signal n_MREQ						: std_logic :='1';
	signal n_IORQ						: std_logic :='1';	

	signal n_int1						: std_logic :='1';	
	signal n_int2						: std_logic :='1';	
	
	signal n_externalRamCS			: std_logic :='1';
	signal n_internalRam1CS			: std_logic :='1';
	--signal n_internalRam2CS			: std_logic :='1';
--	signal n_basRomCS					: std_logic :='1';
	signal n_interface1CS			: std_logic :='1';
	--signal n_interface2CS			: std_logic :='1';
	--signal n_sdCardCS					: std_logic :='1';

	signal serialClkCount			: std_logic_vector(15 downto 0):=(others=>'0');
	signal cpuClkCount				: std_logic_vector(15 downto 0); 
	signal sdClkCount					: std_logic_vector(5 downto 0); 	
	signal serialClock				: std_logic;
	signal nose1                       : std_logic;
	signal nose2                       : std_logic;
	signal nose3                       : std_logic;
	
	signal n_reset : std_logic:='0';
	signal reset2 : std_logic:='0';
	signal reset3 : std_logic;
	signal resetCount : std_logic_vector(15 downto 0):=(others=>'0');
	signal rts1			             :  std_logic;
	--signal sramData		              :  std_logic_vector(7 downto 0);
	signal locked_nose:  std_logic;
	--MSX
	--clocks
	signal clk100  :std_logic;
	signal clk50   : std_logic; 
	signal clk10	: std_logic; --10 MHz. uart and pwm
	signal clk3_6 : std_logic:='0'; --cpu clock 100/(14*2)=3.57 MHz
	signal clk36Counter : std_logic_vector (3 downto 0):=x"0"; 
	signal clk1_8 : std_logic:='0'; --psg clock 3.57/2 = 1.8MHz
	signal sdClock						: std_logic;
	signal clk44K : std_logic:='0'; --pwm clock = 44kHz
	signal clk44KCounter : std_logic_vector (10 downto 0):=(others=>'0'); 
	signal clk125dvi : std_logic; --hdmi encoder
	signal clk125ndvi : std_logic;
	signal clkvga : std_logic;
	--Reset signals
--	TYPE TypeResetState IS (RSNotStarted, RSCounting, RSStarted);  -- resetstate machine
--	signal ResetState : TypeResetState:=RSNotStarted;
--	signal StartReset : std_logic:='1';
	--ram slot signals
	signal SlotNumber  :std_logic_vector(1 downto 0);
	signal n_SL0   :std_logic;
	signal n_SL1   :std_logic;
	signal n_SL2   :std_logic;
	signal n_SL3   :std_logic;
	
	--8255 PPI signals
	signal n_PPIW : std_logic:='1'; --PPI write request
	signal n_PPIR : std_logic:='1'; --PPI read request
	signal PPI_PA : std_logic_vector (7 downto 0); --PPI output port A
	signal PPI_PB : std_logic_vector (7 downto 0); --PPI input port B
	signal PPI_PC : std_logic_vector (7 downto 0); --PPI output port C
	signal PPI_Reset : std_logic:='1'; --non inverting Reset
	signal PPIDataOut	: std_logic_vector(7 downto 0);
	signal n_PPIEna  : std_logic:='1'; --enable slot signals
	
	--TMS9918 VDP signals
	signal n_CSW : std_logic:='1'; --VDP write request
	signal n_CSR : std_logic:='1'; --VDP read request	
	signal VDPCSW : std_logic:='1'; --VDP write request noninverting
	signal VDPCSR : std_logic:='1'; --VDP read request noninverting	
	signal VDPDataOut : std_logic_vector (15 downto 0); --VDP output (top 8 correspond to 8-bit interface)	
	signal n_VDPInt  :std_logic:='1'; --VDP interrupt request
	signal VDPRed :std_logic_vector (2 downto 0); --VDP red channel
	signal VDPGreen :std_logic_vector (2 downto 0); --VDP green channel
	signal VDPBlue :std_logic_vector (1 downto 0); --VDP blue channel
	signal VDPDebug :std_logic_vector (7 downto 0); --reg7 debug
    signal VDPVgaHsync   : std_logic := '0';
    signal VDPVgaVsync   : std_logic := '0';
    signal VDPVgaBlank   : std_logic := '0';	
    --HDMI signals
    signal hdmiRed   :  std_logic_vector(7 downto 0);
    signal hdmiGreen   :  std_logic_vector(7 downto 0);
    signal hdmiBlue   :  std_logic_vector(7 downto 0);
    signal hdmiRed_s   : std_logic;
    signal hdmiGreen_s : std_logic;
    signal hdmiBlue_s  : std_logic;
    signal hdmiClock_s : std_logic;	
	
	--AY-3-8910 PSG signals
	signal psgBc1 : std_logic:='0'; --psg chip select & mode 1/2
	signal psgBdir : std_logic:='0'; --psg chip select & mode 2/2
	signal psgDataOut : std_logic_vector (7 downto 0); --psg output
	signal psgSound1 : std_logic_vector (7 downto 0); --psg output sound channel 1
	signal psgSound2 : std_logic_vector (7 downto 0); --psg output sound channel 2
	signal psgSound3 : std_logic_vector (7 downto 0); --psg output sound channel 3
	signal psgPA : std_logic_vector (7 downto 0); --psg port a
	signal psgPB : std_logic_vector (7 downto 0):=x"ff"; --psg port b
	signal psgDebug : std_logic_vector (7 downto 0);
	
	--pwm & output sound signals
	signal pwmOut : std_logic;
	signal pwmCounter : std_logic_vector (7 downto 0); --pwm ramp
	
	
	
	--MSX ROM signals
	signal msxRomData : std_logic_vector(7 downto 0);  --MSX Basic
	signal n_msxRomCS : std_logic:='1';
	
	--MSX RAM signals
	signal msxRamWren : std_logic:='0';
	signal msxRamDataOut: std_logic_vector(7 downto 0);  --MSX ram in slot 3
	signal n_msxRamCS : std_logic:='1';
	
	--msx wait signals
	signal waitM1 : std_logic:='1';
	signal waitD1 : std_logic:='1';
	signal waitD2 : std_logic:='1';
	signal waitCpu_n : std_logic:='1';
	
	--msx joystick signals
	signal joyFwd1 : std_logic:='1';
	signal joyBack1 : std_logic:='1';
	signal joyLeft1 : std_logic:='1';
	signal joyRight1 : std_logic:='1';
	signal joyTrgA1 : std_logic:='1';
	signal joyTrgB1 : std_logic:='1';
	signal joyFwd2 : std_logic:='1';
	signal joyBack2 : std_logic:='1';
	signal joyLeft2 : std_logic:='1';
	signal joyRight2 : std_logic:='1';
	signal joyTrgA2 : std_logic:='1';
	signal joyTrgB2 : std_logic:='1';	
	
	--msx slot signals
	signal slotCS1_n : std_logic:='1';
	signal slotCS2_n : std_logic:='1';
	signal slotCS12_n : std_logic:='1';
	signal slotSLTSL_n : std_logic:='1';
	signal slotWAIT_n : std_logic:='1';
	signal slotM1_n : std_logic:='1';
	signal slotIORQ_n : std_logic:='1';
	signal slotMERQ_n : std_logic:='1';
	signal slotRD_n : std_logic:='1';
	signal slotWR_n : std_logic:='1';
	signal slotRFSH_n : std_logic:='1';
	signal slotINT_n : std_logic:='1';
	signal slotBUSDIR_n : std_logic:='1';
	signal slotRESET_n : std_logic:='1';
	signal slotA : std_logic_vector(15 downto 0);
	signal slotD : std_logic_vector(7 downto 0);
	signal slotCLOCK : std_logic;
	signal slotSW1 : std_logic:='1';
	signal slotSW2 : std_logic:='1';
	
	--miscellaneous signals
	signal led0 : std_logic:='0';
    signal led1 : std_logic:='0';
    signal led2 : std_logic:='0';
    signal led3 : std_logic:='0';
    signal led4 : std_logic:='0';
    signal led5 : std_logic:='0';
    
    --avoid optimizations on this net
    attribute dont_touch of clk3_6 : signal is "TRUE";
	
	component clk_wiz_1
        Port ( 
        clk125 : in STD_LOGIC;
        clk50 : out STD_LOGIC;
        clk100: out std_logic;
        clk125dvi: out std_logic;
        clk125ndvi: out std_logic
           );
    end component;
 
 component RAM_64kb 
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;   
    
component bufferedUART 
	port (
		clk     : in std_logic;
		n_wr    : in  std_logic;
		n_rd    : in  std_logic;
		regSel  : in  std_logic;
		dataIn  : in  std_logic_vector(7 downto 0);
		dataOut : out std_logic_vector(7 downto 0);
		n_int   : out std_logic; 
		rxClock : in  std_logic; -- 16 x baud rate
		txClock : in  std_logic; -- 16 x baud rate
		rxd     : in  std_logic;
		txd     : out std_logic;
		n_rts   : out std_logic :='0';
		n_cts   : in  std_logic; 
		n_dcd   : in  std_logic
   );
end component;	

    component I82C55 
      port (
    
        I_ADDR            : in    std_logic_vector(1 downto 0); -- A1-A0
        I_DATA            : in    std_logic_vector(7 downto 0); -- D7-D0
        O_DATA            : out   std_logic_vector(7 downto 0);
        O_DATA_OE_L       : out   std_logic;
    
        I_CS_L            : in    std_logic;
        I_RD_L            : in    std_logic;
        I_WR_L            : in    std_logic;
    
        I_PA              : in    std_logic_vector(7 downto 0);
        O_PA              : out   std_logic_vector(7 downto 0);
        O_PA_OE_L         : out   std_logic_vector(7 downto 0);
    
        I_PB              : in    std_logic_vector(7 downto 0);
        O_PB              : out   std_logic_vector(7 downto 0);
        O_PB_OE_L         : out   std_logic_vector(7 downto 0);
    
        I_PC              : in    std_logic_vector(7 downto 0);
        O_PC              : out   std_logic_vector(7 downto 0);
        O_PC_OE_L         : out   std_logic_vector(7 downto 0);
    
        RESET             : in    std_logic;
        ENA               : in    std_logic; -- (CPU) clk enable
        CLK               : in    std_logic
        );
    end component;
    
    component tms9918h 
        Port (  clk 		: in  STD_LOGIC;
                reset 		: in  STD_LOGIC;
                mode 		: in 	STD_LOGIC; -- 1 for registers, 0 for memory
                addr		: in  STD_LOGIC_VECTOR(7 downto 0); -- extension, 8 bit address in
                data_in 	: in  STD_LOGIC_VECTOR (7 downto 0);
                data_out 	: out  STD_LOGIC_VECTOR (15 downto 0);	-- extended to 16-bits (top 8 correspond to 8-bit interface)
                wr 			: in  STD_LOGIC;	-- high for 1 clock cycle to write
                rd 			: in  STD_LOGIC;	-- can be high multiple cycles. high-to-low transition increments addr for data reads
                
                reg1_nose: out std_logic_vector(7 downto 0);
                clkvga : out std_logic; --pixel clock
                vga_vsync : out  STD_LOGIC;
                vga_hsync : out  STD_LOGIC;
                vga_blank : out std_logic;
                debug1		: out STD_LOGIC;
                debug2		: out STD_LOGIC;
                int_out   : out STD_LOGIC;	-- interrupt out, high means interrupt pending
                vga_red 	: out  STD_LOGIC_VECTOR (2 downto 0);
                vga_green : out  STD_LOGIC_VECTOR (2 downto 0);
                vga_blue 	: out  STD_LOGIC_VECTOR (1 downto 0));
    
    end component;    
    
    component dvid 
        Port ( clk       : in  STD_LOGIC;
               clk_n     : in  STD_LOGIC;
               clk_pixel : in  STD_LOGIC;
               red_p     : in  STD_LOGIC_VECTOR (7 downto 0);
               green_p   : in  STD_LOGIC_VECTOR (7 downto 0);
               blue_p    : in  STD_LOGIC_VECTOR (7 downto 0);
               blank     : in  STD_LOGIC;
               hsync     : in  STD_LOGIC;
               vsync     : in  STD_LOGIC;
               red_s     : out STD_LOGIC;
               green_s   : out STD_LOGIC;
               blue_s    : out STD_LOGIC;
               clock_s   : out STD_LOGIC);
    end component;
    
    component YM2149 
      port (
      -- data bus
      I_DA                : in  std_logic_vector(7 downto 0);
      O_DA                : out std_logic_vector(7 downto 0);
      O_DA_OE_L           : out std_logic;
      -- control
      I_A9_L              : in  std_logic;
      I_A8                : in  std_logic;
      I_BDIR              : in  std_logic;
      I_BC2               : in  std_logic;
      I_BC1               : in  std_logic;
      I_SEL_L             : in  std_logic;
    
      O_AUDIO             : out std_logic_vector(7 downto 0);
      -- port a
      I_IOA               : in  std_logic_vector(7 downto 0);
      O_IOA               : out std_logic_vector(7 downto 0);
      O_IOA_OE_L          : out std_logic;
      -- port b
      I_IOB               : in  std_logic_vector(7 downto 0);
      O_IOB               : out std_logic_vector(7 downto 0);
      O_IOB_OE_L          : out std_logic;
    
      ENA                 : in  std_logic; -- clock enable for higher speed operation
      RESET_L             : in  std_logic;
      CLK                 : in  std_logic;  -- note 6 Mhz;
      clkHigh             : in std_logic;  --to avoid problems when cpu clk is slower than psg clk
      debug               : out std_logic_vector(7 downto 0)
      );
    end component;
    
    component Keybd 
        Port (
           --control pins
           Reset_n : in STD_LOGIC; 
           CLK: in STD_LOGIC;
           --spi pins 
           SPI_SS_n : in STD_LOGIC;
           SPI_MOSI : in STD_LOGIC;
           SPI_CLK : in STD_LOGIC;
           --msx pins
           rowIn : in STD_LOGIC_VECTOR (3 downto 0);    --row selector
           rowOut : out STD_LOGIC_VECTOR (7 downto 0)); --row output
    end component;    
	
begin

    sdClockout<=sdClock;
    serialClockout<=serialClock;
    cpuClockout<=clk3_6;
-- ____________________________________________________________________________________
-- RELOJ DE 125 A 125, 125n, 100 y 50 MHz. módulo xilinx

    clockgen: clk_wiz_1 port map ( 
        clk125       => clk125,
        clk50      => clk50,
        clk100      => clk100,
        clk125dvi   => clk125dvi,
        clk125ndvi  => clk125ndvi
        );


-- ____________________________________________________________________________________
-- CPU CHOICE GOES HERE
cpu1 : entity work.t80s
    generic map(mode => 0, t2write => 0, iowait => 1)
    port map(
        reset_n => n_reset,
        clk_n => clk3_6,
        wait_n => waitCpu_n,
        int_n => n_VDPInt, --'1',
        nmi_n => '1',
        busrq_n => '1',
        M1_n => waitM1,
        mreq_n => n_MREQ,
        iorq_n => n_IORQ,
        rd_n => n_RD,
        wr_n => n_WR,
        a => cpuAddress,
        di => cpuDataIn,
        do => cpuDataOut
    );
-- ____________________________________________________________________________________
-- msx rom	
    
msx_rom1 : entity work.msx_rom  --32k MSX
    port map (
        address => cpuAddress(14 downto 0),
        clock => clk3_6,
        q => msxRomData
    );        
    
-- ____________________________________________________________________________________
-- ram

nose1<=not(n_memWR or n_internalRam1CS);


--ram grant searle
ram1: RAM_64kb
    port map
    (
        address => cpuAddress(15 downto 0),
        clock => clk3_6,
        data => cpuDataOut,
        wren => nose1,
        q => internalRam1DataOut
    );

--ram msx
msxRamWren<=not(n_memWR or n_msxRamCS);
ram2: RAM_64kb
    port map
    (
        address => cpuAddress(15 downto 0),
        clock => clk3_6,
        data => cpuDataOut,
        wren => msxRamWren,
        q => msxRamDataOut
    );
-- ____________________________________________________________________________________
-- INPUT/OUTPUT DEVICES GO HERE	

nose2<=n_interface1CS or n_ioWR;
nose3<=n_interface1CS or n_ioRD;

io1 : bufferedUART
    port map(
        clk => clk10,
        n_wr => nose2,
        n_rd => nose3,
        n_int => n_int1,
        regSel => cpuAddress(0),
        dataIn => cpuDataOut,
        dataOut => interface1DataOut,
        rxClock => serialClock,
        txClock => serialClock,
        rxd => rxd1,
        txd => txd1,
        n_cts => '0',
        n_dcd => '0',
        n_rts => rts1
    );	


-- ____________________________________________________________________________________
-- MEMORY READ/WRITE LOGIC GOES HERE
n_ioWR <= n_WR or n_IORQ;
n_memWR <= n_WR or n_MREQ;
n_ioRD <= n_RD or n_IORQ;
n_memRD <= n_RD or n_MREQ;
-- ____________________________________________________________________________________
-- CHIP SELECTS GO HERE

--grant's computer
---8k Basic
--n_basRomCS <= '0' when cpuAddress(15 downto 13) = "000" and n_SL0='0' else '1'; --8K at bottom of memory
---8k RAM upper slot 0
--n_internalRam1CS <= '0' when cpuAddress(15 downto 13) = "001" and (n_memWR='0' or n_memRD = '0') and n_SL0='0' else '1'; --56K at top of memory

--32k MSX Basic
n_msxRomCS <= '0' when cpuAddress(15) = '0' and (n_memWR='0' or n_memRD = '0') and n_SL0='0' else '1'; --lower 32K in slot 0

n_interface1CS <= '0' when cpuAddress(7 downto 1) = "1000000" and (n_ioWR='0' or n_ioRD = '0') else '1'; -- 2 Bytes $80-$81
--4k RAM
--n_internalRam1CS <= '0' when cpuAddress(15 downto 12) = "0010" and (n_memWR='0' or n_memRD = '0') else '1';
--64k RAM slot 3
n_msxRamCS <= '0' when (n_memWR='0' or n_memRD = '0') and n_SL3='0' else '1'; --64K full slot

process (clk3_6) --reset at startup
begin
    if rising_edge(clk3_6) then
        if resetCount<6 then
            resetCount<=resetCount+1;
        else
            reset2<='1';        
        end if;
    end if;    
end process ;

n_reset<=reset2 and ex_n_reset;


-- ____________________________________________________________________________________
-- BUS ISOLATION GOES HERE
cpuDataIn <=
interface1DataOut when n_interface1CS = '0' else
--basRomData when n_basRomCS = '0' else
internalRam1DataOut when n_internalRam1CS= '0' else
msxRamDataOut when n_msxRamCS= '0' else
ppiDataOut when n_PPIR='0' else
vdpDataOut(15 downto 8) when n_CSR='0' else
msxRomData when n_msxRomCS='0' else
psgDataOut when psgBc1='1' and psgBdir='0' else 
x"FF";
-- ____________________________________________________________________________________
-- SYSTEM CLOCKS GO HERE
-- SUB-CIRCUIT CLOCK SIGNALS
serialClock <= serialClkCount(15);
process (clk50)
begin
if rising_edge(clk50) then
    if cpuClkCount < 4 then -- 4 = 10MHz, 3 = 12.5MHz, 2=16.6MHz, 1=25MHz
        cpuClkCount <= cpuClkCount + 1;
    else
        cpuClkCount <= (others=>'0');
    end if;
    if cpuClkCount < 2 then -- 2 when 10MHz, 2 when 12.5MHz, 2 when 16.6MHz, 1 when 25MHz
        clk10 <= '0';
    else
        clk10 <= '1';
    end if;
    
    if sdClkCount < 49 then -- 1MHz
        sdClkCount <= sdClkCount + 1;
        else
        sdClkCount <= (others=>'0');
    end if;
    if sdClkCount < 25 then
        sdClock <= '0';
        else
        sdClock <= '1';
    end if;
    
    -- Serial clock DDS
    -- 50MHz master input clock:
    -- Baud Increment
    -- 115200 2416
    -- 38400 805
    -- 19200 403
    -- 9600 201
    -- 4800 101
    -- 2400 50
    serialClkCount <= serialClkCount + 2416;
end if;
end process;

--MSX

--system clocks
process (clk100)
begin
    if rising_edge(clk100) then
        if clk36Counter<13 then
            clk36Counter<=clk36Counter+1;
        else
            clk36Counter<=x"0";
            clk3_6 <= not clk3_6;
            if clk3_6='1' then
                clk1_8<=not clk1_8;
            end if;            
        end if;
        if clk44KCounter<1136 then
            clk44KCounter<=clk44KCounter+1;
        else
            clk44KCounter<=(others => '0');
            clk44K<= not clk44K;
        end if;
    end if;
end process;

--8255 PPI & signals
n_PPIW<= '0' when cpuAddress (7 downto 2) = "101010" and (n_ioWR='0') else '1'; -- I/O:A8-ABh / PPI(8255)
n_PPIR<= '0' when cpuAddress (7 downto 2) = "101010" and (n_ioRD='0') else '1'; -- I/O:A8-ABh / PPI(8255)
PPI_Reset<=not n_reset;
ppi1 : I82C55
    port map(
    I_ADDR => cpuAddress (1 downto 0),
    I_DATA => cpuDataOut,
    O_DATA => PPIDataOut,
    O_DATA_OE_L => open,
    I_CS_L => '0',
    I_RD_L => n_PPIR,
    I_WR_L => n_PPIW,
    I_PA => PPI_PA,
    O_PA => PPI_PA,
    O_PA_OE_L => open,
    I_PB => PPI_PB,
    O_PB => open,
    O_PB_OE_L => open,
    I_PC => PPI_PC,
    O_PC => PPI_PC,
    O_PC_OE_L => open,
    RESET => PPI_Reset,
    ENA => '1',
    CLK => clk3_6
    );
--during reset, slot slector must be fixed to 0
--after reset, slot selection works after first write to PPI
process (n_reset,clk3_6,n_PPIW)
    begin
        if n_reset='0' then
            n_PPIEna<='1';
        elsif rising_edge(clk3_6) then
            if n_PPIW='0' then
                n_PPIEna<='0';
            end if;
        end if;
end process;
--ram slot selectiom
SlotNumber <= "00" when (n_PPIEna='1' or n_MREQ='1') else
              PPI_PA(1 downto 0) when  cpuAddress (15 downto 14)="00" else
              PPI_PA(3 downto 2) when  cpuAddress (15 downto 14)="01" else
              PPI_PA(5 downto 4) when  cpuAddress (15 downto 14)="10" else
              PPI_PA(7 downto 6) ;
n_SL0 <= '0' when SlotNumber="00" else '1';
n_SL1 <= '0' when SlotNumber="01" else '1';
n_SL2 <= '0' when SlotNumber="10" else '1';
n_SL3 <= '0' when SlotNumber="11" else '1';    

--TMS9918A VDP and signals
n_CSW<= '0' when cpuAddress (7 downto 2) = "100110" and (n_ioWR='0') else '1'; -- I/O:98-9Bh / VDP(TMS9918A)
n_CSR<= '0' when cpuAddress (7 downto 2) = "100110" and (n_ioRD='0') else '1'; -- I/O:98-9Bh / VDP(TMS9918A)
VDPCSW<=not n_CSW;
VDPCSR<=not n_CSR;
ex_vgaRed0<='0';
ex_vgaRed1<=VDPRed(0);
ex_vgaRed2<=VDPRed(1);
ex_vgaRed3<=VDPRed(2);
ex_vgaGreen0<='0';
ex_vgaGreen1<=VDPGreen(0);
ex_vgaGreen2<=VDPGreen(1);
ex_vgaGreen3<=VDPGreen(2);
ex_vgaBlue0<='0';
ex_vgaBlue1<='0';
ex_vgaBlue2<=VDPBlue(0);
ex_vgaBlue3<=VDPBlue(1);
--poner comentarios a partir de aquí para usar el original
ex_vgaHsync<=VDPVgaHsync;
ex_vgaVsync<=VDPVgaVsync;
vdp1: tms9918h 
      port map ( 
      clk       => clk100,
      reset     => PPI_Reset,
      mode      => cpuAddress(0),
      addr      => x"00",
      data_in   => cpuDataOut,
      data_out  => VDPDataOut,
      wr        => VDPCSW,
      rd        => VDPCSR,
      reg1_nose => VDPDebug,
      clkvga     => clkvga,
      vga_vsync => VDPVgaVsync,
      vga_hsync => VDPVgaHsync,
      vga_blank => VDPVgaBlank,
      debug1    => open,
      debug2    => open,
      int_out   => n_VDPInt,
      vga_red   => VDPRed,
      vga_green => VDPGreen,
      vga_blue  => VDPBlue 
  );
  
--  vdp1: entity work.tms9918 
--      port map ( 
--      clk       => clk100,
--      reset     => PPI_Reset,
--      mode      => cpuAddress(0),
--      addr      => x"00",
--      data_in   => cpuDataOut,
--      data_out  => VDPDataOut,
--      wr        => VDPCSW,
--      rd        => VDPCSR,
--      reg1_nose => VDPDebug,
--      vga_vsync => ex_vgaVsync,
--      vga_hsync => ex_vgaHsync,
--      debug1    => open,
--      debug2    => open,
--      int_out   => n_VDPInt,
--      vga_red   => VDPRed,
--      vga_green => VDPGreen,
--      vga_blue  => VDPBlue 
--  );
  
--HDMI extension and signals  
hdmiRed<=VDPRed & "00000";
hdmiGreen<=VDPGreen & "00000";
hdmiBlue<=VDPBlue & "000000";
hdmi1: dvid
    port map (
           clk          => clk125dvi,
           clk_n        => clk125ndvi,
           clk_pixel    => clkvga,
           red_p        => hdmiRed,
           green_p      => hdmiGreen,
           blue_p       => hdmiBlue,
           blank        => VDPvgaBlank,
           hsync        => VDPvgaHsync,
           vsync        => VDPvgaVsync,
           red_s        => hdmiRed_s,
           green_s      => hdmiGreen_s,
           blue_s       => hdmiBlue_s,
           clock_s      => hdmiClock_s
    );  
OBUFDS_blue  : OBUFDS port map ( O  => DATA_P(0), OB => DATA_N(0), I  => hdmiBlue_s  );
OBUFDS_red   : OBUFDS port map ( O  => DATA_P(1), OB => DATA_N(1), I  => hdmiGreen_s );
OBUFDS_green : OBUFDS port map ( O  => DATA_P(2), OB => DATA_N(2), I  => hdmiRed_s   );
OBUFDS_clock : OBUFDS port map ( O  => CLK_P, OB => CLK_N, I  => hdmiClock_s );    

--AY-3-8910 PSG and signals
psgBdir <= '1' when cpuAddress (7 downto 3) = "10100" and (n_ioWR='0') and cpuAddress(1)='0' else '0'; -- I/O:A0-A2h / PSG(AY-3-8910) bdir = 1 when writing to &HA0-&Ha1
psgBc1 <= '1' when cpuAddress (7 downto 3) = "10100" and ((n_ioRD='0' and cpuAddress(1)='1') or (cpuAddress(1)='0' and n_ioWR='0' and cpuAddress(0)='0')) else '0'; -- I/O:A0-A2h / PSG(AY-3-8910) bc1 = 1 when writing A0 or reading A2
psgPA(0)<=joyFwd1 when psgPB(6)='0' else joyFwd2;
psgPA(1)<=joyBack1 when psgPB(6)='0' else joyBack2;
psgPA(2)<=joyLeft1 when psgPB(6)='0' else joyLeft2;
psgPA(3)<=joyRight1 when psgPB(6)='0' else joyRight2;
psgPA(4)<=joyTrga1 when (psgPB(6)='0' and psgPB(0)='1')
     else joyTrga2 when (psgPB(6)='1' and psgPB(2)='1')
     else '0';
psgPA(5)<=joyTrgb1 when (psgPB(6)='0' and psgPB(1)='1')
     else joyTrgb2 when (psgPB(6)='1' and psgPB(3)='1')
     else '0';
psgPA(6)<='0';
psgPA(7)<=ex_cassetteIn;


psg1: YM2149
    port map (
        -- data bus
        I_DA        => cpuDataOut,
        O_DA        => psgDataOut,
        O_DA_OE_L   => open,
        -- control
        I_A9_L      => '0',
        I_A8        => '1',
        I_BDIR      => psgBdir,
        I_BC2       => '1',
        I_BC1       => psgBc1,
        I_SEL_L     => '1',
        
        O_AUDIO     => psgSound1,
        -- port a
        I_IOA       => psgPA,
        O_IOA       => open,
        O_IOA_OE_L  => open,
        -- port b
        I_IOB       => psgPB,
        O_IOB       => psgPB,
        O_IOB_OE_L  => open,
        
        ENA         => '1', -- clock enable for higher speed operation
        RESET_L     => n_reset,
        CLK         => clk1_8,
        clkHigh     => clk50,
        debug       => psgDebug
    );

keybd1: Keybd
    port map (
       --control pins
       Reset_n => n_reset,
       CLK => clk3_6,
       --spi pins 
       SPI_SS_n => ex_SPI_SS_n,
       SPI_MOSI => ex_SPI_MOSI,
       SPI_CLK => ex_SPI_CLK,
       --msx keyboard pins
       rowIn => PPI_PC(3 downto 0),
       rowOut => PPI_PB    
    );

--pwm sound system
    pwmOut <= '1' when (pwmCounter < psgSound1) else '0';
    ex_pwmOut <= pwmOut;
    simplePWM: process (clk10, PPI_Reset, psgSound1) begin
        if PPI_Reset = '1' then
            pwmCounter <= (others => '0');
        elsif rising_edge(clk10) then
            pwmCounter <= pwmCounter + 1;
        end if;
    end process;
    
--wait process
waitCpu_n<=waitD1;
process (clk3_6, slotWait_n, waitD2)
begin
    if slotWait_n='0' then
        waitD1 <='0';
    elsif waitD2='0' then
        waitD1<='1';
    elsif rising_edge(clk3_6) then
        waitD1<=waitM1;
    end if;    
end process ;     
process (clk3_6, slotWait_n)
begin
    if slotWait_n='0' then
        waitD2 <='1';
    elsif rising_edge(clk3_6) then
        waitD2<=waitD1;
    end if;    
end process ;    
    
    -- Asignación de señales --

--lednova<=ex_n_reset;

--process (n_PPIW)
--    begin
--    if falling_edge(n_PPIW) then --or n_PPIR='0'  then
--        led1<='1';
--    end if;
--end process;

--process (n_PPIR)
--    begin
--    if falling_edge(n_PPIR) then --or n_PPIR='0'  then
--        led2<='1';
--    end if;
--end process;

process (psgBdir)
begin
    if rising_edge(psgBdir) then
        --led1<= not led1;
    end if;
end process;

process (psgBc1)
begin
    if rising_edge(psgBc1) then
        --led2<='1';
    end if;
end process;



--lednova<=led1 or led2;



led0<=PPI_PA(0);
led1<=PPI_PA(1);
led2<=PPI_PA(2);
led3<=PPI_PA(3);
led4<=PPI_PA(4);


ex_led0<=VDPDebug(0);
ex_led1<=VDPDebug(1);
ex_led2<=VDPDebug(2);
ex_led3<=VDPDebug(3);
ex_led4<=VDPDebug(4);
ex_led5<=VDPDebug(5);

--PPI_PB<=x"BF" when PPI_PC(3 downto 0)="0010" else x"FF";

end;
