# SVI728
Recreación de un MSX Spectravideo SVI-728 con FPGA Xilinx

![SVI728](/SVI728.jpg)

Agrupación de los componentes básicos que forman un MSX, utilizando módulos disponibles por internet, incluyendo la Bios de un SVI-728 español. El código VHDL está hecho para placas Xilinx. La comunicación entre el teclado y la FPGA se hace a través de una raspberry pi.

Las características de este ordenador son:
• Microprocesador T80 a 3.6 MHz
• 32 KB ROM SVI-728 en español, Slot 0
• 64 KB RAM, Slot 3
• PPI I82C55
• VDP TMS9918A con salidas VGA y HDMI, 640x480x60 Hz
• PSG YM2149
• Puerto serie
• Entrada de cassette
• Teclado USB