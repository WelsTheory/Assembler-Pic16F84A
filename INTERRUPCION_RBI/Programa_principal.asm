;**************** THE WELS THEORY ******************
;Descripción: Los pines RB6 y RB7 están conectados a dos pulsadores,
;cada vez que son presionados producen una interrupción enviando diferentes
;mensajes a la LCD.
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A			    ; Procesador PIC16f84A
#include "p16f84a.inc"		    ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

;Definimos Variables 
CBLOCK  0x0C
ENDC
 
;Variables definidas
#DEFINE  Pulsador1	PORTB,7
#DEFINE  Pulsador2	PORTB,6

;CODIGO
    ORG		0
    GOTO        INICIO
    ORG		4
    GOTO	ServicioInterrupcion
INICIO
    CALL    LCD_Inicializa
    MOVLW   Mensaje_1
    CALL    LCD_Mensaje
    CALL    LCD_Linea2
    MOVLW   .8
    CALL    LCD_PosicionLinea2
    MOVLW   Mensaje_2
    CALL    LCD_Mensaje
    BSF	    STATUS,RP0
    BSF	    Pulsador1		;Entradas Pulsador1 y Pulsado 2
    BSF	    Pulsador2
    BCF	    STATUS,RP0		; Acceso al Banco 0.
    MOVLW   B'10001000'		;GIE = 1 - RBI = 1
    MOVWF   INTCON	
START
    SLEEP
    GOTO    START

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
ServicioInterrupcion
    CALL    Retardo_20ms	;Rebotes
    BTFSS   Pulsador1		;
    CALL    Mensaje_pulsador1
    BTFSS   Pulsador2
    CALL    Mensaje_pulsador2
    RETFIE			;GIE = 1 

Mensaje_pulsador1
    CALL    LCD_Borra
    MOVLW   Mensaje_pulsador1_1
    CALL    LCD_Mensaje
    CALL    LCD_Linea2
    MOVLW   Mensaje_pulsador1_2
    CALL    LCD_Mensaje
    RETURN
Mensaje_pulsador2
    CALL    LCD_Borra
    MOVLW   Mensaje_pulsador2_1
    CALL    LCD_Mensaje
    CALL    LCD_Linea2
    MOVLW   Mensaje_pulsador2_2
    CALL    LCD_Mensaje
    RETURN

;Mensajes    
Mensajes
    ADDWF   PCL,F
Mensaje_1
    DT "Presiona un",0x00
Mensaje_2
    DT "Pulsador",0x00
Mensaje_pulsador1_1
    DT "   SUSCRIBETE",0x00
Mensaje_pulsador1_2 
    DT "   WELS THEORY",0x00
Mensaje_pulsador2_1
    DT "   EUREKA!!!",0x00
Mensaje_pulsador2_2
    DT "   FUNCIONA!!=D",0x00

	
    INCLUDE  <E:\PIC16F84A\Librerias\RETARDOS.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD.INC>
    ;INCLUDE  <E:\PIC16F84A\Librerias\BIN_BCD.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD_Mensaje.INC>
    END