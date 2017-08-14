;**************** THE WELS THEORY ******************
;Descripción: Encendemos un led cada 30ms. La temporización
;conseguimos con el Timer0
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A ; Procesador PIC16f84A
#include "p16f84a.inc" ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

;Definimos salida del LED
#DEFINE	    LED	    PORTB,4
 
CBLOCK	0x0C
ENDC

;CODIGO
    ORG	0
INICIO
    BSF	    STATUS,RP0
    BCF	    LED
    MOVLW   B'00000101'
    MOVWF   OPTION_REG		;Prescaler de 64 asigando al TMR0
    BCF	    STATUS,RP0
START
    BCF	    LED			;Comienza apagado
    CALL    Timer0_10ms		;Esperamos 10ms
    CALL    Timer0_10ms		;Esperamos 10ms
    CALL    Timer0_10ms		;Esperamos 10ms
    BSF	    LED			;Encendemos el LED
    CALL    Timer0_10ms		;Esperamos 10ms
    CALL    Timer0_10ms		;Esperamos 10ms
    CALL    Timer0_10ms		;Esperamos 10ms
    GOTO    START
  
; Subrutina "Timer0_1ms" -------------------------------------------------------
; 
; Haremos los calculos para un temporizador de 1ms con un prescaler de 4.
; Temporizador = Tcm * Prescaler (256- Carga_TMR0)
; 1ms = 1000us = 1us * 4 (256 - Carga_TMR0)
; 4*Carga_TMR0 = 1024 - 1000
; Carga_TMR0 = 6
;
; Necesitamos que el valor de Carga_TMR0 sea 6 para un prescaler de 4 

; Subrutina "Timer0_5ms" -------------------------------------------------------
; 
; Haremos los calculos para un temporizador de 1ms con un prescaler de 32.
; Temporizador = Tcm * Prescaler (256- Carga_TMR0)
; 5ms = 5000us = 1us * 32 (256 - Carga_TMR0)
; 32*Carga_TMR0 = 8192 - 5000
; Carga_TMR0 = 99.75 = 100
;
; Necesitamos que el valor de Carga_TMR0 sea 100 para un prescaler de 32 

;TMR0_Carga1ms	EQU	.6	
;Timer0_1ms
;    MOVLW   TMR0_Carga1ms	    ;Carga el Timer0 con el valor que queremos
;    MOVWF   TMR0
;    BCF	    INTCON,T0IF		    ;Reseteamos el Flag de desbordamiento del TMR0
;Timer0_Desbordamiento
;    BTFSS   INTCON,T0IF		    ;¿Se ha desbordado el TMR0?
;    GOTO    Timer0_Desbordamiento   ;Aún no, Repite.
;    RETURN
    
;TMR0_Carga5ms	EQU	.100	
;Timer0_5ms
;    MOVLW   TMR0_Carga5ms	    ;Carga el Timer0 con el valor que queremos
;    MOVWF   TMR0
;    BCF	    INTCON,T0IF		    ;Reseteamos el Flag de desbordamiento del TMR0
;Timer0_Desbordamiento
;    BTFSS   INTCON,T0IF		    ;¿Se ha desbordado el TMR0?
;    GOTO    Timer0_Desbordamiento   ;Aún no, Repite.
;    RETURN

; Subrutina "Timer0_10ms" -------------------------------------------------------
; 
; Haremos los calculos para un temporizador de 1ms con un prescaler de 64.
; Temporizador = Tcm * Prescaler (256- Carga_TMR0)
; 10ms = 10000us = 1us * 64 (256 - Carga_TMR0)
; 64*Carga_TMR0 = 16384 - 10000
; Carga_TMR0 = 99.75 = 100
;
; Necesitamos que el valor de Carga_TMR0 sea 100 para un prescaler de 64     
    
TMR0_Carga10ms	EQU	.100	
Timer0_10ms
    MOVLW   TMR0_Carga10ms	    ;Carga el Timer0 con el valor que queremos
    MOVWF   TMR0
    BCF	    INTCON,T0IF		    ;Reseteamos el Flag de desbordamiento del TMR0
Timer0_Desbordamiento
    BTFSS   INTCON,T0IF		    ;¿Se ha desbordado el TMR0?
    GOTO    Timer0_Desbordamiento   ;Aún no, Repite.
    RETURN
    

    END
