----------------------------------------------------------------------------------
-- msx link to external keyboard
--
-- this block behaves like an msx keyboard. there are four lines to select row
-- and 8 lines with the row data. this row data is received by spi port.
-- spi slave receives 16 bits words with row data in bits 15..8 and row number
-- in bits 3..0. rest of bits are unused.
-- mind that spi slave is reading only. data received is stored in internal 
-- registers for a fast response.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Keybd is
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
end Keybd;

architecture Behavioral of Keybd is
    signal SPI_Data : std_logic_vector (15 downto 0); --keyboard data. bits 15..8 = row output. bits 3..0=row number
    signal SPI_Ready: STD_LOGIC;
    type  array10x8   is array (0 to 9) of std_logic_vector(7 downto 0);
    signal rowData : array10x8:=(others=>(others=>'1')); --all keys releaded
    signal nose: std_logic_vector(3 downto 0):="0000";
    signal nosenose : std_logic;
begin

--SPI module, receiving only
spi1: entity work.SPI_SLAVE
    generic map(
        NBITS => 16
    )
    Port map (
        CLK_in => CLK,
        RESET_n => RESET_n,
        -- SPI SLAVE INTERFACE
        SPI_CLK => SPI_CLK,
        SPI_SS =>SPI_SS_n,
        SPI_MOSI => SPI_MOSI,
        SPI_MISO => open,
        SPI_DONE => SPI_Ready,
        -- USER INTERFACE
        DataToTx => x"FFFF",
        DataToTxLoad => '0',
        DataRxd => SPI_Data
    );
    
    rowData(0)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="0000" ) else  rowData(0)(7 downto 0);
    rowData(1)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="0001" ) else  rowData(1)(7 downto 0);
    rowData(2)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="0010" ) else  rowData(2)(7 downto 0);
    rowData(3)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="0011" ) else  rowData(3)(7 downto 0);
    rowData(4)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="0100" ) else  rowData(4)(7 downto 0);
    rowData(5)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="0101" ) else  rowData(5)(7 downto 0);
    rowData(6)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="0110" ) else  rowData(6)(7 downto 0);
    rowData(7)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="0111" ) else  rowData(7)(7 downto 0);
    rowData(8)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="1000" ) else  rowData(8)(7 downto 0);
    rowData(9)(7 downto 0)<=SPI_Data(15 downto 8) when  (SPI_Ready='1' and SPI_Data(3 downto 0)="1001" ) else  rowData(9)(7 downto 0);
    
    rowOut <= rowData(0) when rowIn(3 downto 0)="0000" else
              rowData(1) when rowIn(3 downto 0)="0001" else
              rowData(2) when rowIn(3 downto 0)="0010" else
              rowData(3) when rowIn(3 downto 0)="0011" else
              rowData(4) when rowIn(3 downto 0)="0100" else
              rowData(5) when rowIn(3 downto 0)="0101" else
              rowData(6) when rowIn(3 downto 0)="0110" else
              rowData(7) when rowIn(3 downto 0)="0111" else
              rowData(8) when rowIn(3 downto 0)="1000" else
              rowData(9) when rowIn(3 downto 0)="1001" else x"ff";
    
    
    

end Behavioral;
