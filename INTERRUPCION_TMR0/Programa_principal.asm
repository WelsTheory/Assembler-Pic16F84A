;**************** THE WELS THEORY ******************
;Descripción: Un led conectado a línea 3 del puerto B se
;enciende cada 600ms y apaga durante otros 300ms. Usar la
;interrupción del Time0 
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A			    ; Procesador PIC16f84A
#include "p16f84a.inc"		    ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

;Definimos Variables 
CBLOCK  0x0C
Reg_Tiempos
ENDC

;Valores de definidos 
Periodo_50ms EQU d'195' ; 195*256= 49920us = 50ms 
Periodo_600ms EQU d'12';  50ms*12=600ms
Periodo_300ms EQU d'6';  50ms * 6 = 300ms
#DEFINE LED PORTB,3; SALIDA DEL LED
 
;CODIGO
    ORG		0
    GOTO        INICIO
    ORG		4
    GOTO	TMR0_INT

INICIO
    BSF	    STATUS,RP0
    BCF	    LED
    MOVLW   B'00000111'; 256 PRESCALER TMR0
    MOVWF   OPTION_REG 
    BCF	    STATUS,RP0
    MOVLW   Periodo_50ms
    MOVWF   TMR0
    MOVLW   Periodo_300ms
    MOVWF   Reg_Tiempos
    MOVLW   B'10100000'
    MOVWF   INTCON	    ;T0IE - GIE 
START
    GOTO    $

;INTERRUPCION
TMR0_INT
    MOVLW   Periodo_50ms
    MOVWF   TMR0
    DECFSZ  Reg_Tiempos,F
    GOTO    FIN_INT
    BTFSC   LED		;ESTADO DEL LED
    GOTO    ENCENDIDO
APAGADO
    BSF	    LED
    MOVLW   Periodo_600ms
    GOTO    Var_Tiempos
ENCENDIDO
    BCF	    LED
    MOVLW   Periodo_300ms
Var_Tiempos
    MOVWF   Reg_Tiempos
FIN_INT
    BCF	    INTCON,T0IF
    RETFIE		;GIE

    END