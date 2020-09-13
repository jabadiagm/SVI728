library ieee;
use ieee.std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity msx_rom is
	port(
	   address:in std_logic_vector(14 downto 0);
	   clock		: IN STD_LOGIC  := '1';
	   q:out std_logic_vector(7 downto 0));
end entity;

architecture rtl of msx_rom is
	component msx_rom_xilinx  port (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
  end component;
begin
    rom1: msx_rom_xilinx port map (
        clka=>clock,
        addra=>address,
        douta =>q   
    );




	
end architecture;