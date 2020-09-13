#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
08-11-2019
prueba de las rutinas de conversión entre teclado PC
y teclado msx. la entrada es la lista de teclas pulsadas
y la salida es una lista de bytes con los valores de la
matriz de teclado MSX, en binario

@author: javier
"""

#carga las constantes de teclado del PC
from pygame.locals import *
import pygame
import time
import platform
import subprocess
if platform.system()=='Linux':
    import spidev
    import RPi.GPIO as GPIO
    GPIO.setmode(GPIO.BOARD)
    GPIO.setup(7,GPIO.OUT)

#la clase tecla evita duplicar tablas
class Tecla():
    def __init__ (self,codig,nombr):
        self.codigo=codig
        self.nombre=nombr
    def codigo(self): #número de tecla
        return self.codigo
    def nombre(self): #nombre de tecla
        return self.nombre

#teclado msx
M_F1F6=Tecla(1,'M_F1F6')
M_F2F7=Tecla(2,'M_F2F7')
M_F3F8=Tecla(3,'M_F3F8')
M_F4F9=Tecla(4,'M_F4F9')
M_F5F10=Tecla(5,'M_F5F10')
M_STOP=Tecla(6,'M_STOP')
M_BACKSLASH=Tecla(7,'M_BACKSLASH')
M_TILDE=Tecla(8,'M_TILDE')
M_CUT=Tecla(9,'M_CUT')
M_ESCAPE=Tecla(10,'M_ESCAPE')
M_1=Tecla(11,'M_1')
M_2=Tecla(12,'M_2')
M_3=Tecla(13,'M_3')
M_4=Tecla(14,'M_4')
M_5=Tecla(15,'M_5')
M_6=Tecla(16,'M_6')
M_7=Tecla(17,'M_7')
M_8=Tecla(18,'M_8')
M_9=Tecla(19,'M_9')
M_0=Tecla(20,'M_0')
M_MINUS=Tecla(21,'M_MINUS')
M_EQUAL=Tecla(22,'M_EQUAL')
M_BACKSPACE=Tecla(23,'M_BACKSPACE')
M_TAB=Tecla(24,'M_TAB')
M_Q=Tecla(25,'M_Q')
M_W=Tecla(26,'M_W')
M_E=Tecla(27,'M_E')
M_R=Tecla(28,'M_R')
M_S=Tecla(29,'M_S')
M_T=Tecla(30,'M_T')
M_Y=Tecla(31,'M_Y')
M_U=Tecla(32,'M_U')
M_I=Tecla(33,'M_I')
M_O=Tecla(34,'M_O')
M_P=Tecla(35,'M_P')
M_LBRACKET=Tecla(36,'M_LBRACKET')
M_RBRACKET=Tecla(37,'M_RBRACKET')
M_SEMICOLON=Tecla(38,'M_SEMICOLON')
M_CAPSLOCK=Tecla(39,'M_CAPSLOCK')
M_CONTROL=Tecla(40,'M_CONTROL')
M_A=Tecla(41,'M_A')
M_S=Tecla(42,'M_S')
M_D=Tecla(43,'M_D')
M_F=Tecla(44,'M_F')
M_G=Tecla(45,'M_G')
M_H=Tecla(46,'M_H')
M_J=Tecla(47,'M_J')
M_K=Tecla(48,'M_K')
M_L=Tecla(49,'M_L')
M_Ñ=Tecla(50,'M_Ñ') #sólo en versión españa
M_QUOTE=Tecla(51,'M_QUOTE')   #'
M_ENTER=Tecla(52,'M_ENTER')
M_SHIFT=Tecla(53,'M_SHIFT')
M_Z=Tecla(54,'M_Z')
M_X=Tecla(55,'M_X')
M_C=Tecla(56,'M_C')
M_V=Tecla(57,'M_V')
M_V=Tecla(58,'M_V')
M_B=Tecla(59,'M_B')
M_N=Tecla(60,'M_N')
M_M=Tecla(61,'M_M')
M_COMMA=Tecla(62,'M_COMMA')
M_DOT=Tecla(63,'M_DOT')
M_SLASH=Tecla(64,'M_SLASH')   #/
M_GRAPH=Tecla(65,'M_GRAPH')
M_CODE=Tecla(66,'M_CODE')
M_SPACE=Tecla(67,'M_SPACE')
M_COPY=Tecla(68,'M_COPY')
M_UP=Tecla(69,'M_UP')
M_PASTE=Tecla(70,'M_PASTE')
M_SELECT=Tecla(71,'M_SELECT')
M_LEFT=Tecla(72,'M_LEFT')
M_DOWN=Tecla(73,'M_DOWN')
M_RIGHT=Tecla(74,'M_RIGHT')
M_DIVIDE=Tecla(75,'M_DIVIDE')
M_KP7=Tecla(76,'M_KP7')
M_KP8=Tecla(77,'M_KP8')
M_KP9=Tecla(78,'M_KP9')
M_MULTIPLY=Tecla(79,'M_MULTIPLY')
M_KP4=Tecla(80,'M_KP4')
M_KP5=Tecla(81,'M_KP5')
M_KP6=Tecla(82,'M_KP6')
M_PLUS=Tecla(83,'M_PLUS')
M_KP1=Tecla(84,'M_KP1')
M_KP2=Tecla(85,'M_KP2')
M_KP3=Tecla(86,'M_KP3')
M_MINUS=Tecla(87,'M_MINUS')
M_KP0=Tecla(88,'M_KP0')
M_KPCOMMA=Tecla(89,'M_KPCOMMA') #,
M_KPDOT=Tecla(90,'M_KPDOT') #.
M_BACKQUOTE=Tecla(91,'M_BACKQUOTE') #` sólo en versión internacional

#•teclado USB
tecladoUsb={
    K_ESCAPE:'K_ESCAPE',
    K_F1:'K_F1',
    K_F2:'K_F2',
    K_F3:'K_F3',
    K_F4:'K_F4',
    K_F5:'K_F5',
    K_F6:'K_F6',
    K_F7:'K_F7',
    K_F8:'K_F8',
    K_F9:'K_F9',
    K_F10:'K_F10',
    K_F11:'K_F11',
    K_F12:'K_F12',
    K_DELETE:'K_DELETE',
    K_BACKQUOTE:'K_BACKQUOTE',
    K_1:'K_1',
    K_2:'K_2',
    K_3:'K_3',
    K_4:'K_4',
    K_5:'K_5',
    K_6:'K_6',
    K_7:'K_7',
    K_8:'K_8',
    K_9:'K_9',
    K_0:'K_0',
    K_MINUS:'K_MINUS',
    K_EQUALS:'K_EQUALS',
    K_BACKSPACE:'K_BACKSPACE',
    K_HOME:'K_HOME',
    K_TAB:'K_TAB',
    K_q:'K_q',
    K_w:'K_w',
    K_e:'K_e',
    K_r:'K_r',
    K_t:'K_t',
    K_y:'K_y',
    K_u:'K_u',
    K_i:'K_i',
    K_o:'K_o',
    K_p:'K_p',
    K_LEFTBRACKET:'K_LEFTBRACKET',
    K_RIGHTBRACKET:'K_RIGHTBRACKET',
    K_BACKSLASH:'K_BACKSLASH',
    K_PAGEUP:'K_PAGEUP',
    K_CAPSLOCK:'K_CAPSLOCK',
    K_a:'K_a',
    K_s:'K_s',
    K_d:'K_d',
    K_f:'K_f',
    K_g:'K_g',
    K_h:'K_h',
    K_j:'K_j',
    K_k:'K_k',
    K_l:'K_l',
    K_SEMICOLON:'K_SEMICOLON',
    K_QUOTE:'K_QUOTE',
    K_RETURN:'K_RETURN',
    K_PAGEDOWN:'K_PAGEDOWN',
    K_LSHIFT:'K_LSHIFT',
    K_z:'K_z',
    K_x:'K_x',
    K_c:'K_c',
    K_v:'K_v',
    K_b:'K_b',
    K_n:'K_n',
    K_m:'K_m',
    K_COMMA:'K_COMMA',
    K_PERIOD:'K_PERIOD',
    K_SLASH:'K_SLASH',
    K_RSHIFT:'K_RSHIFT',
    K_UP:'K_UP',
    K_END:'K_END',
    K_LCTRL:'K_LCTRL',
    K_LSUPER:'K_LSUPER',
    K_LALT:'K_LALT',
    K_SPACE:'K_SPACE',
    K_RALT:'K_RALT',
    K_RCTRL:'K_RCTRL',
    K_LEFT:'K_LEFT',
    K_DOWN:'K_DOWN',
    K_RIGHT:'K_RIGHT'
        }





#relación entre las teclas del PC y las teclas de MSX
#una tecla puede dar lugar a más de una pulsación,
#por ejemplo F6 da lugar a SHIFT+F1
#por eso, el valor de salida es una lista
mappingUsa={
        K_ESCAPE:[M_ESCAPE],
        K_F1:[M_F1F6],
        K_F2:[M_F2F7],
        K_F3:[M_F3F8],
        K_F4:[M_F4F9],
        K_F5:[M_F5F10],
        K_F6:[M_SHIFT,M_F1F6],
        K_F7:[M_SHIFT,M_F2F7],
        K_F8:[M_SHIFT,M_F3F8],
        K_F9:[M_SHIFT,M_F4F9],
        K_F10:[M_SHIFT,M_F5F10],
        K_F11:[M_BACKSLASH],
        K_F12:[M_TILDE],
        K_DELETE:[M_CUT],
        K_BACKQUOTE:[M_BACKQUOTE], 
        K_1:[M_1],
        K_2:[M_2],
        K_3:[M_3],
        K_4:[M_4],
        K_5:[M_5],
        K_6:[M_6],
        K_7:[M_7],
        K_8:[M_8],
        K_9:[M_9],
        K_0:[M_0],
        K_MINUS:[M_MINUS],
        K_EQUALS:[M_EQUAL],
        K_BACKSPACE:[M_BACKSPACE],
        K_HOME:[M_STOP], #HOME/PAUSE
        K_TAB:[M_TAB],
        K_q:[M_Q],
        K_w:[M_W],
        K_e:[M_E],
        K_r:[M_R],
        K_t:[M_T],
        K_y:[M_Y],
        K_u:[M_U],
        K_i:[M_I],
        K_o:[M_O],
        K_p:[M_P],
        K_LEFTBRACKET:[M_LBRACKET],
        K_RIGHTBRACKET:[M_RBRACKET],
        K_BACKSLASH:[M_BACKSLASH],
        K_PAGEUP:[M_COPY],
        #K_CAPSLOCK:[M_CAPSLOCK],  #capslock se procesa aparte, distinto comportamiento
        K_a:[M_A],
        K_s:[M_S],
        K_d:[M_D],
        K_f:[M_F],
        K_g:[M_G],
        K_h:[M_H],
        K_j:[M_J],
        K_k:[M_K],
        K_l:[M_L],
        K_SEMICOLON:[M_SEMICOLON],
        K_QUOTE:[M_QUOTE],
        K_RETURN:[M_ENTER],
        K_PAGEDOWN:[M_PASTE],
        K_LSHIFT:[M_SHIFT],
        K_z:[M_Z],
        K_x:[M_X],
        K_c:[M_C],
        K_v:[M_V],
        K_b:[M_B],
        K_n:[M_N],
        K_m:[M_M],
        K_COMMA:[M_COMMA],
        K_PERIOD:[M_DOT],
        K_SLASH:[M_SLASH],
        K_RSHIFT:[M_SHIFT],
        K_UP:[M_UP],
        K_END:[M_SELECT],
        K_LCTRL:[M_CONTROL],
        K_LSUPER:[], #windows. no asignada/asignable
        K_LALT:[M_GRAPH],
        K_SPACE:[M_SPACE],
        K_RALT:[M_GRAPH],
        K_RCTRL:[M_CODE],
        K_LEFT:[M_LEFT],
        K_DOWN:[M_DOWN],
        K_RIGHT:[M_RIGHT]
        }

mappingEsp={
        K_ESCAPE:[M_ESCAPE],
        K_F1:[M_F1F6],
        K_F2:[M_F2F7],
        K_F3:[M_F3F8],
        K_F4:[M_F4F9],
        K_F5:[M_F5F10],
        K_F6:[M_SHIFT,M_F1F6],
        K_F7:[M_SHIFT,M_F2F7],
        K_F8:[M_SHIFT,M_F3F8],
        K_F9:[M_SHIFT,M_F4F9],
        K_F10:[M_SHIFT,M_F5F10],
        K_F11:[M_BACKSLASH],
        K_F12:[M_TILDE],
        K_DELETE:[M_CUT],
        K_BACKQUOTE:[M_Ñ], 
        K_1:[M_1],
        K_2:[M_2],
        K_3:[M_3],
        K_4:[M_4],
        K_5:[M_5],
        K_6:[M_6],
        K_7:[M_7],
        K_8:[M_8],
        K_9:[M_9],
        K_0:[M_0],
        K_MINUS:[M_MINUS],
        K_EQUALS:[M_EQUAL],
        K_BACKSPACE:[M_BACKSPACE],
        K_HOME:[M_STOP], #HOME/PAUSE
        K_TAB:[M_TAB],
        K_q:[M_Q],
        K_w:[M_W],
        K_e:[M_E],
        K_r:[M_R],
        K_t:[M_T],
        K_y:[M_Y],
        K_u:[M_U],
        K_i:[M_I],
        K_o:[M_O],
        K_p:[M_P],
        K_LEFTBRACKET:[M_LBRACKET],
        K_RIGHTBRACKET:[M_RBRACKET],
        K_BACKSLASH:[M_BACKSLASH],
        K_PAGEUP:[M_COPY],
        #K_CAPSLOCK:[M_CAPSLOCK],  #capslock se procesa aparte, distinto comportamiento
        K_a:[M_A],
        K_s:[M_S],
        K_d:[M_D],
        K_f:[M_F],
        K_g:[M_G],
        K_h:[M_H],
        K_j:[M_J],
        K_k:[M_K],
        K_l:[M_L],
        K_SEMICOLON:[M_SEMICOLON],
        K_QUOTE:[M_QUOTE],
        K_RETURN:[M_ENTER],
        K_PAGEDOWN:[M_PASTE],
        K_LSHIFT:[M_SHIFT],
        K_z:[M_Z],
        K_x:[M_X],
        K_c:[M_C],
        K_v:[M_V],
        K_b:[M_B],
        K_n:[M_N],
        K_m:[M_M],
        K_COMMA:[M_COMMA],
        K_PERIOD:[M_DOT],
        K_SLASH:[M_SLASH],
        K_RSHIFT:[M_SHIFT],
        K_UP:[M_UP],
        K_END:[M_SELECT],
        K_LCTRL:[M_CONTROL],
        K_LSUPER:[], #windows. no asignada/asignable
        K_LALT:[M_GRAPH],
        K_SPACE:[M_SPACE],
        K_RALT:[M_GRAPH],
        K_RCTRL:[M_CODE],
        K_LEFT:[M_LEFT],
        K_DOWN:[M_DOWN],
        K_RIGHT:[M_RIGHT]
        }

matrizSvi728Usa=[
        [M_7,M_6,M_5,M_4,M_3,M_2,M_1,M_0], #Y0
        [M_SEMICOLON,M_RBRACKET,M_LBRACKET,M_BACKSLASH,M_EQUAL,M_MINUS,M_9,M_8], #Y1
        [M_B,M_A,M_TILDE,M_SLASH,M_DOT,M_COMMA,M_BACKQUOTE,M_QUOTE], #Y2
        [M_J,M_I,M_H,M_G,M_F,M_E,M_D,M_C], #Y3
        [M_R,M_Q,M_P,M_O,M_N,M_M,M_L,M_K], #Y4
        [M_Z,M_Y,M_X,M_W,M_V,M_U,M_T,M_S], #Y5
        [M_F3F8,M_F2F7,M_F1F6,M_CODE,M_CAPSLOCK,M_GRAPH,M_CONTROL,M_SHIFT], #Y6
        [M_ENTER,M_SELECT,M_BACKSPACE,M_STOP,M_TAB,M_ESCAPE,M_F5F10,M_F4F9], #Y7
        [M_RIGHT,M_DOWN,M_UP,M_LEFT,M_CUT,M_PASTE,M_COPY,M_SPACE], #Y8
        [0,0,0,0,0,0,0,0] #Y9
        #[M_B,M_A,M_TILDE,M_SLASH,M_A,M_A,M_A,M_A],
        ]

matrizSvi728Esp=[
        [M_7,M_6,M_5,M_4,M_3,M_2,M_1,M_0], #Y0
        [M_Ñ,M_RBRACKET,M_LBRACKET,M_BACKSLASH,M_EQUAL,M_MINUS,M_9,M_8], #Y1
        [M_B,M_A,M_TILDE,M_SLASH,M_DOT,M_COMMA,M_SEMICOLON,M_QUOTE], #Y2
        [M_J,M_I,M_H,M_G,M_F,M_E,M_D,M_C], #Y3
        [M_R,M_Q,M_P,M_O,M_N,M_M,M_L,M_K], #Y4
        [M_Z,M_Y,M_X,M_W,M_V,M_U,M_T,M_S], #Y5
        [M_F3F8,M_F2F7,M_F1F6,M_CODE,M_CAPSLOCK,M_GRAPH,M_CONTROL,M_SHIFT], #Y6
        [M_ENTER,M_SELECT,M_BACKSPACE,M_STOP,M_TAB,M_ESCAPE,M_F5F10,M_F4F9], #Y7
        [M_RIGHT,M_DOWN,M_UP,M_LEFT,M_CUT,M_PASTE,M_COPY,M_SPACE], #Y8
        [0,0,0,0,0,0,0,0] #Y9
        #[M_B,M_A,M_TILDE,M_SLASH,M_A,M_A,M_A,M_A],
        ]



#funciones de manejo de bits
# testBit() returns a nonzero result, 2**offset, if the bit at 'offset' is one.

def testBit(int_type, offset):
    mask = 1 << offset
    return(int_type & mask)

# setBit() returns an integer with the bit at 'offset' set to 1.

def setBit(int_type, offset):
    mask = 1 << offset
    return(int_type | mask)

# clearBit() returns an integer with the bit at 'offset' cleared.

def clearBit(int_type, offset):
    mask = ~(1 << offset)
    return(int_type & mask)

# toggleBit() returns an integer with the bit at 'offset' inverted, 0 -> 1 and 1 -> 0.

def toggleBit(int_type, offset):
    mask = 1 << offset
    return(int_type ^ mask)


#pruebas de funciones de matriz
mapping=mappingEsp
matriz=matrizSvi728Esp


def formarFila(pulsadas,filaMatriz):
    salida=[]
    for contador in range (8):
        salida.append(not filaMatriz[contador] in pulsadas)
    return salida


def fila2byte (fila):
    retorno=0
    for nbit in range (8):
        if fila[7-nbit]==True:
            retorno=setBit(retorno,nbit)
    return retorno

#devuelve los identificadores de las teclas pulsadas
def leerPulsadas(teclasPulsadas):
    resultado=[]
    for contador in range(len(teclasPulsadas)):
        if teclasPulsadas[contador]!=0:
            resultado.append(contador)
    return resultado

def leerNombresTeclasUsb(teclasPulsadas):
    resultado=[]
    for tecla in teclasPulsadas:
        if tecla in tecladoUsb:
            resultado.append(tecladoUsb[tecla])
    return resultado

def leerNombresTeclasMsx(teclasPulsadas):
    resultado=[]
    for tecla in teclasPulsadas:
        resultado.append(tecla.nombre)
        #print(tecla2.nombre)
    return resultado


def leerTeclasMsx(teclasPulsadas):
    resultado=[]
    for tecla in teclasPulsadas:
        if tecla in mapping:
            teclas=mapping[tecla]
            for tecla2 in teclas:
                resultado.append(tecla2)
                #print(tecla2.nombre)
    return resultado
    
#convierte una lista de teclas del teclado de origen en una
#lista de declas del teclado de destino
def mapearTeclas(origen):
    resultado=[]
    for tecla in origen:
        destino=mapping[tecla]
        resultado.append(destino)
    return resultado



#proceso de la tecla capslock. los teclados modernos tienen su propio
#control de la tecla capslock y su led. cuando se pulsa la tecla capslock,
#se enciende el led y se fija el estado de la tecla al de pulsado
#aunque se suelte la tecla, se sigue indicando tecla pulsada, hasta que 
#se vuelve a pulsar y se desconecta
#en el teclado msx, la tecla capslock es una tecla normal, su estado depende
#de si está pulsada o no, y el led lo controla la cpu
#así que el proceso consiste en detectar el cambio de estado y crear un pulso
#de duración fija en ON y en OFF. al terminar estos dos pulsos,
#se comprueba el estado de la teclado real. si ha habido más pulsaciones
#durante los pulsos, puede ser que el estado haya cambiado. si es así,
#vuelve a generar los pulsos ON/OFF
procesoCapsLock=0   #0=off/esperando
                    #1=conmutación a on
                    #2=temporización en on
                    #3=conmutación a off
                    #4=temporización en off
                    #5=comprobación de estado real

duracionCapsLock=0.8 #segundos
origenTiempoCapsLock=0 #instante en el que capslock ha cambiado
estadoCapsLockAnterior=False #valor de capslock en el ciclo anterior
estadoCapsLockActual=False #valor de capslock en el ciclo anterior
estadoCapsLockEstimado=False #valor de capslock suponiendo que no hay 
                             #pulsaciones extras durante las temporizaciones
capsLock=False #valor final de la tecla. si es true, aparece pulsada en msx

#devuelve el estado del led de capslock. sólo en plataforma línux
def leerEstadoCapslock():
    if platform.system()=='Linux':
        if subprocess.getoutput('xset q | grep LED')[65]=='1':
            return True
        else:
            return False
    return False #depuración

def procesarCapsLock(teclasPulsadas):
    global procesoCapsLock
    global estadoCapsLockAnterior
    global estadoCapsLockEstimado
    global capsLock
    global origenTiempoCapsLock
    estadoCapsLockActual=K_CAPSLOCK in teclasPulsadas
    #print(estadoCapsLockActual)
    if procesoCapsLock==0: 
        #buscando un cambio de estado o pulsos perdidos
        if estadoCapsLockAnterior!=estadoCapsLockActual or estadoCapsLockActual!=estadoCapsLockEstimado:
            procesoCapsLock=1 
    elif procesoCapsLock==1: #conmutación a on
            origenTiempoCapsLock=time.time()
            capsLock=True
            procesoCapsLock=2
            #print ("CapsLock=True")
            if platform.system()=='Linux':
                GPIO.output(7,GPIO.HIGH)
    elif procesoCapsLock==2: #temporización en on
        if (time.time()-origenTiempoCapsLock)>duracionCapsLock:
            procesoCapsLock=3
    elif procesoCapsLock==3: #conmutación a off
            origenTiempoCapsLock=time.time()
            capsLock=False
            #print ("CapsLock=False")
            procesoCapsLock=4
    elif procesoCapsLock==4: #temporización en off      
        if (time.time()-origenTiempoCapsLock)>duracionCapsLock:
            procesoCapsLock=5
    elif procesoCapsLock==5: #comprobación de estado real
        #ha terminado un ciclo, capslock ha cambiado de estado
        estadoCapsLockEstimado=not estadoCapsLockEstimado
        #print ("CapsLock=Fin de ciclo")
        print ("CapsLock actual="+str(estadoCapsLockEstimado))
        if platform.system()=='Linux':
            GPIO.output(7,GPIO.LOW)        
        procesoCapsLock=0
    else: #aquí no debería llegar
        print('Error extraño')
    estadoCapsLockAnterior=estadoCapsLockActual
        
def spi_write_pot(input):
    msb = input >> 8
    lsb = input & 0xFF
    if platform.system()=='Linux':
        spi.xfer([msb, lsb])




if platform.system()=='Linux':
    spi = spidev.SpiDev()
    spi.open(0, 0)
    spi.max_speed_hz = 488000
    spi.bits_per_word=8
    spi.mode= 0b00
estadoCapsLockEstimado=leerEstadoCapslock()
estadoCapsLockAnterior=estadoCapsLockEstimado
estadoCapsLockActual=estadoCapsLockEstimado
pygame.init()
pygame.key.set_repeat() #evita repetición
BLACK = (0,0,0)
WIDTH = 111
HEIGHT = 111
windowSurface = pygame.display.set_mode((WIDTH, HEIGHT), 0, 32)
windowSurface.fill(BLACK)
pygame.display.flip()
windowSurface.fill(BLACK)
teclasDestino=[]
while True:
#for prueba in range(100000):
    teclasOrigen=leerPulsadas(pygame.key.get_pressed())
    #print (pygame.key.get_pressed())
    procesarCapsLock(teclasOrigen)
    if len(teclasOrigen)>0 or capsLock==True:
        teclasDestino=leerTeclasMsx(teclasOrigen)
        if capsLock==True:
            teclasDestino.append(M_CAPSLOCK)
        #if len(teclasDestino)>0:
            #print ('origen:'+str(leerNombresTeclasUsb(teclasOrigen)))
            #print ('destino:'+str(leerNombresTeclasMsx(teclasDestino)))
    else:
        teclasDestino.clear()
    for contador in range(10):
        filabin=fila2byte(formarFila(teclasDestino,matriz[contador]))
        palabra=(filabin<<8) + contador
        spi_write_pot(palabra)
        #print (format(palabra,'#020b'))
        #print (contador<<4)
    #print ("---")
    for event in pygame.event.get():
        if event.type == KEYDOWN:
            #print ("666")
            key = event.key
            #print(event.key)
            if key==13: #ENTER
                nose=pygame.key.get_pressed()
            #elif key==27: #ESC
            #    pygame.quit()
        elif event.type == KEYUP:
            key = event.key
            #print(event.key)
    #time.sleep(0.2)
pygame.quit()    
print("666")




























