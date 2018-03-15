;;**************** WELS THEORY ******************
;Descripción: Medir distancias con un ultrasonido HC-SR04 con el PIC16F84A
;Mostrando la distancia en un LCD. 
; 
; Autor:           Wels (@soywels) 
; 
; Copyright: 	   Wels Theory 2018
;
; Fecha	           14 de Marzo del 2018
;  
; Facebook:        https://www.facebook.com/welstheory
; 
; Youtube:         https://www.youtube.com/wels_theory
; 
; Instagram:       https://www.instagram.com/wels_theory/  
;
__CONFIG _XT_OSC & _WDTE_OFF & _PWRTE_ON & _CP_OFF
LIST P=16F84A
INCLUDE <P16F84A.INC>
   
CBLOCK 0XC
    VAR_DISTANCIA
ENDC
    
#DEFINE TRIGGER PORTA,3
#DEFINE ECHO	PORTA,4
;Distancia Min. y Max. del Ultrasonido
DIST_MIN EQU .2
DIST_MAX EQU .400
    
;TIMER 0 -> 58us - 60us
; temporizador = 58us = 1us*2*(256-x)
;   x = 256 - 29 = 227
TMR0_CARGA58 EQU -d'29' ; d'227'
    
;ZONA DE CODIGO
    ORG	    0
    GOTO    INICIO
    ORG	    4
    GOTO    INTERRUPCIONES
    
INICIO
    CALL    LCD_Inicializa
    BSF	    STATUS,RP0
    BCF	    TRIGGER	;TRIGGER -> SALIDA
    BSF	    ECHO	;ECHO ->ENTRADA
    MOVLW   B'00000000'	;TMR0 -> PRESCALER 2 
    MOVWF   OPTION_REG
    BCF	    STATUS,RP0
    BCF	    TRIGGER	;APAGAMOS TRIGGER
START
    CLRF    VAR_DISTANCIA
    BSF	    TRIGGER
    CALL    Retardo_10micros
    BCF	    TRIGGER
ECHO_ES_1
    BTFSS   ECHO
    GOTO    ECHO_ES_1
    MOVLW   TMR0_CARGA58
    MOVWF   TMR0
    MOVLW   B'10100000'
    MOVWF   INTCON	;HABILITAR A QUE PUEDAN HABER INTERRUPCIONES
ECHO_ES_0
    BTFSC   ECHO
    GOTO    ECHO_ES_0
    CLRF    INTCON	;DETENER LAS INT.
    CALL    LCD_MUESTRA
    CALL    Retardo_2s
    GOTO    START

;INTERRUPCION    
INTERRUPCIONES    
    MOVLW   TMR0_CARGA58
    MOVWF   TMR0
    MOVLW   .1
    ADDWF   VAR_DISTANCIA,F
    MOVLW   DIST_MAX
    BTFSC   STATUS,C
    MOVWF   VAR_DISTANCIA
    BCF	    INTCON,T0IF
    RETFIE

LCD_MUESTRA
    CALL	LCD_Borra
    MOVLW	DIST_MIN
    SUBWF	VAR_DISTANCIA,W ; DIST MIN - VAR DISTANCIA = W
    BTFSS	STATUS,C
    GOTO	MENOR
    MOVF	VAR_DISTANCIA,W
    SUBLW	DIST_MAX
    BTFSC	STATUS,C
    GOTO	DISTANCIA_CORRECTA
MAYOR
    MOVLW	DIST_MAX
    MOVWF	VAR_DISTANCIA
    MOVLW	Mensaje_distMax
    GOTO	MUESTRA_DISTANCIA
MENOR
    MOVLW	DIST_MIN
    MOVWF	VAR_DISTANCIA
    MOVLW	Mensaje_distMin
    GOTO	MUESTRA_DISTANCIA
DISTANCIA_CORRECTA
    MOVLW	Mensaje_dist
MUESTRA_DISTANCIA
    CALL	LCD_Mensaje
    MOVLW	.5
    CALL	LCD_PosicionLinea2
    MOVF	VAR_DISTANCIA,W
    CALL	BIN_a_BCD
    MOVF	BCD_Centenas,W
    BTFSS	STATUS,Z
    GOTO	CENTENAS
    MOVF	VAR_DISTANCIA,W
    CALL	BIN_a_BCD
    CALL	LCD_Byte
    GOTO	CENTIMETROS
CENTENAS
    CALL	LCD_Nibble
    MOVF	VAR_DISTANCIA,W
    CALL	BIN_a_BCD
    CALL	LCD_ByteCompleto
CENTIMETROS
    MOVLW	Mensaje_cm
    CALL	LCD_Mensaje
    RETURN	

Mensajes
	addwf	PCL,F
Mensaje_dist
	DT "La distancia es:", 0x00
Mensaje_cm
	DT " cm", 0x00
Mensaje_distMin
	DT "R-min superado:", 0x00
Mensaje_distMax
	DT "R-max superado:", 0x00
	
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD.INC>
	INCLUDE  <LCD_Mensaje.INC>
	INCLUDE  <BIN_BCD.INC>
	END    
    
    
    
    
    
    