;**************** THE WELS THEORY ******************
;Descripción: Contador de Timer 0 a través de la entrada
;RA4. Además se visualizará la cuenta en el LCD.
; 
;		   TEORIA
;Timer0 tiene dos maneras de trabajar como temporizador y como contador.
;En este caso se usa el contador. Se conecta a través RA4 el cual
;cuenta los impulsos, estos impulsos pueden ser ascendentes o descendentes.
; 
;Registro OPTION: En la librería del pic16f84a se le nombre OPTION_REG
;Tiene 8 bits los cuales se pueden configurar de la siguiente manera:
;	    
;	   |RBPU|INTEDG|T0CS|T0SE|PSA |PS2 |PS1 |PS0 | 
;	   |Bit7| Bit6 |Bit5|Bit4|Bit3|Bit2|Bit1|Bit0|
;
;PS2:PS0 -> Bits para seleccionar los valores del Prescaler
;Lo configuraremos como 000 para tener el divisor WDT 1:1
;    
;PSA -> 0 = El divisor de frecuencia lo asigna el TMR0
;	1 = El divisor de frecuencia lo asigna el WDT    
;    
;T0SE -> 0 = TMR0 se incrementa con flanoc ascendente -> 1
;	 1 = TMR0 se incrementa con flanco descendente -> 0
;    
;T0CS -> 0 = Pulsos del reloj interno Fosc/4 (Temporizador)
;	 1 = Pulsos a través del Pin RA4 (Contador)
;    
;Lo estoy configurando como:
;	   |RBPU|INTEDG|T0CS|T0SE|PSA |PS2 |PS1 |PS0 | 
;	   |  0 |   0  |  1 |  1 |  1 |  0 |  0 |  0 |
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A ; Procesador PIC16f84A
#include "p16f84a.inc" ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

CBLOCK	0x0C
ENDC

;CODIGO
    ORG	0
INICIO
    CALL    LCD_Inicializa
    BSF	    STATUS,RP0
    MOVLW   B'00111000'		; TMR0 como contador por flanco descendente
    MOVWF   OPTION_REG		; Se configura los datos en OPTION_REG
    BCF	    STATUS,RP0		
    CLRF    TMR0		; Contador iniciado
START
    CALL    LCD_Linea1		; Comienza en la primera línea
    MOVLW   2
    CALL    LCD_PosicionLinea1
    MOVLW   Mensaje_contador	; Mensaje "Contador"
    CALL    LCD_Mensaje
    CALL    LCD_Linea2		; Comienza en la segunda línea
    MOVLW   3			; Que comience en la posición 2
    CALL    LCD_PosicionLinea2
    MOVLW   Mensaje_pulsador	; Mensaje "Van"	
    CALL    LCD_Mensaje
    MOVF    TMR0,W		; Lee el Timer 0
    CALL    BIN_a_BCD		; Se pasa de Binario a BCD
    CALL    LCD_Byte		; Visualiza apagando las decenas en caso sean  0
    GOTO    START
    
Mensajes
    ADDWF   PCL,F
Mensaje_contador
    DT "Contador de", 0x00
Mensaje_pulsador
    DT "Pulsos:", 0x00   
	
    INCLUDE  <E:\PIC16F84A\Librerias\RETARDOS.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\BIN_BCD.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD_Mensaje.INC>
    END
