;**************** THE WELS THEORY ******************
;Descripción: Encendido y apagado de los LEDS del 
;puerto B dependiendo de las entradas puerto A
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A ; Procesador PIC16f84A
#include "p16f84a.inc" ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

;CODIGO

    ORG	    0
INICIO
    BSF	    STATUS,RP0
    CLRF    TRISB
    MOVLW   B'00011111'
    MOVWF   TRISA; PORTA TIENE 5 PUERTOS
    BCF	    STATUS,RP0

START
    MOVF    PORTA,W; PORTA se almacena en W
    MOVWF   PORTB; W -> PORTB
    GOTO    START
    END