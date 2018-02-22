;;**************** WELS THEORY ******************
;Descripción: Control de 2 Motores DC con el L293D
;Los motores pueden avanzar, retroceder, girar a la izquierda, derecha
;o detenerse.
; 
; Autor:           Wels (@soywels) 
; 
; Copyright: 	   Wels Theory 2018
;
; Fecha	           28 de Febrero del 2018
;  
; Facebook:        https://www.facebook.com/welstheory
; 
; Youtube:         https://www.youtube.com/wels_theory
; 
; Instagram:       https://www.instagram.com/wels_theory/  
;
; CONFIG
; __config 0xFFF1
__CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF
LIST P=16F84A
INCLUDE <P16F84A.INC>

	
;STOP
#DEFINE STOP PORTA,3	
;Motor 1
#DEFINE MOTOR1 PORTA,0
;Motor 2
#DEFINE MOTOR2 PORTA,1
;
;
;SI STOP = 1 -> MODULOS HABILITADOS
; MOTOR1 - MOTOR2 = SALIDA
;   0    -   0    = RETROCESO
;   0    -   1    = IZQUIERDA
;   1    -   0    = DERECHA
;   1    -   1    = ADELANTE
;
;SI STOP = 0 -> MODULOS DESHABILITADOS
;
;
;RB0 = Enable 1 -> RB2 y RB3 controlan el giro Motor1
;RB7 = Enable 2 -> RB4 y RB5 controlan el giro Motor2
;
; ZONA DE CÓDIGOS ********************************************************************
	ORG 	0
INICIO
	BSF	STATUS,RP0
	BSF	STOP	    ;ENTRADA
	BSF	MOTOR1
	BSF	MOTOR2
	CLRF	PORTB	    ;SALIDA
	BCF	STATUS,RP0
START
	BTFSS	STOP	    ;STOP = 1?
	GOTO	DETENER	    ;STOP = 0
	BTFSC	MOTOR1	    ;MOTOR1 = 0?
	GOTO	DIRECCION   ;MOTOR1 = 1
	BTFSC	MOTOR2	    ;MOTOR2 = 0?
	GOTO	IZQUIERDA   ;MOTOR1 = 0 - MOTOR2 = 1
	GOTO	ATRAS	    ;MOTOR1 = 0 - MOTOR2 = 0
	
IZQUIERDA
	MOVLW	B'10010001'
	GOTO	SALIDA
DERECHA
	MOVLW	B'10001001'
	GOTO	SALIDA

ATRAS
	MOVLW	B'10100101'
	GOTO	SALIDA
	
DETENER
	CLRW		    ;W = 0
	GOTO	SALIDA
	
DIRECCION
	BTFSS	MOTOR2	    ;MOTOR2=1?
	GOTO	DERECHA	    ;MOTOR1 = 1 - MOTOR2 =0
	MOVLW	B'10011001' ;MOTOR1 = 1 - MOTOR2 = 1
SALIDA			    ;RB7 - RB0 
	MOVWF	PORTB
	GOTO	START
	END
