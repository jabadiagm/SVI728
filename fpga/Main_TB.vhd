-- Testbench created online at:
--   www.doulos.com/knowhow/perl/testbench_creation/
-- Copyright Doulos Ltd
-- SD, 03 November 2002

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity MSX_SVI728_tb is
end;

architecture bench of MSX_SVI728_tb is

  component MSX_SVI728
  	port(
  		ex_n_reset      : in std_logic:='1';
  		clk125	        : in std_logic:='0';
  		rxd1            : in std_logic:='0';
  		txd1			: out std_logic:='0';
  		serialClockout	: out  std_logic;
  		cpuClockout     : out std_logic;
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
        ex_SPI_SS_n   : in std_logic;
        ex_SPI_MOSI   : in std_logic;
        ex_SPI_CLK    : in std_logic;	
        data_p    : out  STD_LOGIC_VECTOR(2 downto 0);
        data_n    : out  STD_LOGIC_VECTOR(2 downto 0);
        clk_p          : out    std_logic;
        clk_n          : out    std_logic;       
        ex_cassetteIn : in std_logic:='0';  		 		
		ex_led0           : out std_logic:='0';
		ex_led1           : out std_logic:='0';
		ex_led2           : out std_logic:='0';
		ex_led3           : out std_logic:='0';
		ex_led4           : out std_logic:='0';
		ex_led5           : out std_logic:='0'  	
		);
  end component;

    signal ex_n_reset: std_logic:='1';
    signal clk125: std_logic:='0';
    signal rxd1: std_logic:='0';
    signal txd1: std_logic:='0';
    signal serialClockout: std_logic;
    signal cpuClockout: std_logic;
    signal sdClockout: std_logic;
    signal ex_vgaVsync   : std_logic;
    signal ex_vgaHsync   :  std_logic;
    signal ex_vgaRed0    :  std_logic;
    signal ex_vgaRed1    :  std_logic;
    signal ex_vgaRed2    :  std_logic;
    signal ex_vgaRed3    :  std_logic;
    signal ex_vgaGreen0  :  std_logic;
    signal ex_vgaGreen1  :  std_logic;
    signal ex_vgaGreen2  :  std_logic;
    signal ex_vgaGreen3  :  std_logic;
    signal ex_vgaBlue0   :  std_logic;
    signal ex_vgaBlue1   :  std_logic;
    signal ex_vgaBlue2   :  std_logic;
    signal ex_vgaBlue3   :  std_logic;
    signal ex_pwmOut    : std_logic;   
    signal ex_pwmEnable  :  std_logic;
    signal ex_SPI_SS_n   :  STD_LOGIC;
    signal ex_SPI_MOSI   :  STD_LOGIC;
    signal ex_SPI_CLK    :  STD_LOGIC;	
    signal data_p    :   STD_LOGIC_VECTOR(2 downto 0);
    signal data_n    :   STD_LOGIC_VECTOR(2 downto 0);
    signal clk_p          :     std_logic;
    signal clk_n          :    std_logic; 
    signal ex_cassetteIn : std_logic;        
    signal ex_led0:std_logic;
    signal ex_led1:std_logic;
    signal ex_led2:std_logic;
    signal ex_led3:std_logic;
    signal ex_led4:std_logic;
    signal ex_led5:std_logic;    
    constant clock_period: time := 8 ns;
    signal stop_the_clock: boolean;

begin

  uut: MSX_SVI728 port map ( ex_n_reset        => ex_n_reset,
                                clk125         => clk125,
                                rxd1           => rxd1,
                                txd1           => txd1,
                                serialClockout => serialClockout,
                                cpuClockout    => cpuClockout,
                                sdClockout     => sdClockout,
                                ex_vgaVsync     => ex_vgaVsync,
                                ex_vgaHsync     => ex_vgaHsync,
                                ex_vgaRed0      => ex_vgaRed0,
                                ex_vgaRed1      => ex_vgaRed1,
                                ex_vgaRed2      => ex_vgaRed2,
                                ex_vgaRed3      => ex_vgaRed3,
                                ex_vgaGreen0    => ex_vgaGreen0,
                                ex_vgaGreen1    => ex_vgaGreen1,
                                ex_vgaGreen2    => ex_vgaGreen2,
                                ex_vgaGreen3    => ex_vgaGreen3,
                                ex_vgaBlue0     => ex_vgaBlue0,
                                ex_vgaBlue1     => ex_vgaBlue1,
                                ex_vgaBlue2     => ex_vgaBlue2,
                                ex_vgaBlue3     => ex_vgaBlue3,
                                ex_pwmOut       => ex_pwmOut,    
                                ex_pwmEnable    => ex_pwmEnable,
                                ex_SPI_SS_n     => ex_SPI_SS_n,
                                ex_SPI_MOSI     => ex_SPI_MOSI,
                                ex_SPI_CLK      => ex_SPI_CLK,
                                data_p          => data_p,
                                data_n          => data_n,
                                clk_p           => clk_p,
                                clk_n           => clk_n,
                                ex_cassetteIn   => ex_cassetteIn,
                                ex_led0         =>ex_led0,
                                ex_led1         =>ex_led1,
                                ex_led2         =>ex_led2,
                                ex_led3         =>ex_led3,
                                ex_led4         =>ex_led4,
                                ex_led5         =>ex_led5
                                );

  stimulus: process
  begin
  
    -- Put initialisation code here
    ex_n_reset<='0';
    wait for 80ns;
    ex_n_reset<='1';
    wait for 1000 ms;
    
    -- Put test bench stimulus code here

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk125 <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;