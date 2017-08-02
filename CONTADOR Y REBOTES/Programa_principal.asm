;**************** THE WELS THEORY ******************
;Descripción: Mientras se presione el pulsador se contará
;de 0 a 9 manteniendose cada valor por 200ms. Cuando se deje
;de presionar el pulsador se detendrá en el ultimo valor.
; 
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A ; Procesador PIC16f84A
#include "p16f84a.inc" ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

;Variables
CBLOCK  0x0C
CONTADOR			; Variable que se visualizará
ENDC

;Definimos pulsador y salida de Display 
#DEFINE PULSADOR	PORTA,4		; Pulsador = PORTA-4.
#DEFINE DISPLAY		PORTB		; Display = PORTB.
 
;CODIGO
    ORG	0
INICIO
    BSF	    STATUS,RP0		
    CLRF    DISPLAY		; PORTB = DISPLAY -> Como salida
    BSF	    PULSADOR		; PORTA-4 = PULSADOR -> Como entrada
    BCF	    STATUS,RP0		
   
    CALL    INICIO_CUENTA	; INCIAMOS LA CUENTA
START
    BTFSC   PULSADOR		; ¿SE PRESIONÓ EL PULSADOR? -> PULSADOR = 0
    GOTO    FINAL		; NO, VAMOS HASTA FINAL
    CALL    Retardo_20ms	; QUE SE ESTABILICEN LOS NIVELES
    BTFSC   PULSADOR		; COMPROBAMOS SI NO FUE UN ERROR O REBOTE
    GOTO    FINAL		; ERA UN REBOTE, VAMOS HASTA FINAL
    CALL    INCREMENTA_CUENTA	; NO ERA UN ERROR, INCREMENTAMOS EL CONTADOR
    CALL    Retardo_200ms	; SE ESPERAN 200ms PARA DEJAR DE PULSAR
FINAL 
    GOTO    START		; REGRESAMOS AL INICIO DEL PROGRAMA

; SUBRUTINA ---------------------------------------------------------

INCREMENTA_CUENTA
    INCF    CONTADOR,F		; INCREMENTAMOS EL CONTADOR
    MOVLW   D'10'		; W = 10
    SUBWF   CONTADOR,W		; RESTAMOS -> W = CONTADOR - W 
    BTFSC   STATUS,C		; ¿RESTA NEGATIVA?
INICIO_CUENTA
    CLRF    CONTADOR		; ERA IGUAL O MAYOR -> RESETEAMOS CONTADOR
VISUALIZAR
    MOVF    CONTADOR,W		; CONTADOR -> W
    CALL    Numero_a_7Segmentos	; CONVERTIMOS NUMERO A 7 SEGMENTOS 
    MOVWF   DISPLAY		; VISUALIZAMOS EN EL DISPLAY
    RETURN

INCLUDE  <E:\PIC16F84A\Librerias\DISPLAY_7S.INC>
INCLUDE  <E:\PIC16F84A\Librerias\RETARDOS.INC>
    
END