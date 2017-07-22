;**************** THE WELS THEORY ******************
;Descripción: Se compara un Numero con el puerto A
;si PORTA = Numero -> Se encienden todos los LEDS
;si PORTA > Numero -> Se encienden los leds pares
;si PORTA < Numero -> Se encienden los leds MSB
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A ; Procesador PIC16f84A
#include "p16f84a.inc" ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF
 
;Variable
Numero EQU B'00001000' ;PORTA -> 5bits 
 
;CODIGO

    ORG	    0
INICIO
    BSF	    STATUS,RP0
    CLRF    TRISB	;PORTB todo como salida
    MOVLW   B'00011111'
    MOVWF   TRISA	; PORTA todo como entrada
    BCF	    STATUS,RP0

START
    ; Si la resta = positiva, C=1 Z=0
    ; Si la resta = cero, C=1 Z=1
    ; Si la resta = negativo, C=0 Z=0
    MOVLW   Numero ; Numero -> W
    SUBWF   PORTA,W ; PORTA - Numero = se almacena en W
    MOVLW   B'11110000'; PORTA < Numero 
    BTFSC   STATUS,C 
    MOVLW   B'01010101'; PORTA > Numero
    BTFSC   STATUS,Z  
    MOVLW   B'11111111'; PORTA = Numero
    MOVWF   PORTB;  W -> PORTB
    GOTO    START
    END
    
    
    
    
		    
    