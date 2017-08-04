;**************** THE WELS THEORY ******************
;Descripción: La bomba! Te muestra un mensaje por 2s
;donde tienes que desactivar una bomba dependiendo
;la combinación de pulsadores.
; 
; PULSADOR1 (RA3) - PULSADOR (RA4)
;	0		0	    = BOOM!! 
;	0		1	    = BYEBYE:)	
;	1		0	    = CORRECTO
;	1		1	    = FALTAN 10S
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A ; Procesador PIC16f84A
#include "p16f84a.inc" ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

;Variables
CBLOCK  0x0C			; Variable que se visualizará
ENDC

;Definimos pulsador y salida de Display 
#DEFINE PUL1		PORTA,3		; Pulsador1 = PORTA-3.
#DEFINE PUL2		PORTA,4		; Pulsador2 = PORTA-4.
 
;CODIGO
    ORG	0
INICIO
    BSF	    STATUS,RP0		
    BSF	    PUL1		; PORTA-3 = PULSADOR1 -> Como entrada
    BSF	    PUL2		; PORTA-4 = PULSADOR2 -> Como entrada
    BCF	    STATUS,RP0		
    CALL    LCD_Inicializa	; Iniciamos LCD
    CALL    LCD_CursorOFF	; Cursor apagado
BOMBA
    CALL    LCD_Borra
    CALL    Retardo_500ms
    MOVLW   'D'
    CALL    LCD_Caracter
    MOVLW   'E'
    CALL    LCD_Caracter
    MOVLW   'S'
    CALL    LCD_Caracter
    MOVLW   'A'
    CALL    LCD_Caracter
    MOVLW   'C'
    CALL    LCD_Caracter
    MOVLW   'T'
    CALL    LCD_Caracter
    MOVLW   'I'
    CALL    LCD_Caracter
    MOVLW   'V'
    CALL    LCD_Caracter
    MOVLW   'A'
    CALL    LCD_Caracter
    CALL    Retardo_10ms
    MOVLW   7
    CALL    LCD_PosicionLinea2
    MOVLW   'L'
    CALL    LCD_Caracter
    MOVLW   'A'
    CALL    LCD_Caracter
    CALL    LCD_UnEspacioBlanco
    MOVLW   'B'
    CALL    LCD_Caracter
    MOVLW   'O'
    CALL    LCD_Caracter
    MOVLW   'M'
    CALL    LCD_Caracter
    MOVLW   'B'
    CALL    LCD_Caracter
    MOVLW   'A'
    CALL    LCD_Caracter
    CALL    Retardo_1s
BOMBA2
    CALL    LCD_Borra
    MOVLW   'I'
    CALL    LCD_Caracter
    MOVLW   'N'
    CALL    LCD_Caracter
    MOVLW   'G'
    CALL    LCD_Caracter
    MOVLW   'R'
    CALL    LCD_Caracter
    MOVLW   'E'
    CALL    LCD_Caracter
    MOVLW   'S'
    CALL    LCD_Caracter
    MOVLW   'A'
    CALL    LCD_Caracter
    CALL    Retardo_10ms
    MOVLW   4
    CALL    LCD_PosicionLinea2
    MOVLW   'C'
    CALL    LCD_Caracter
    MOVLW   'O'
    CALL    LCD_Caracter
    MOVLW   'M'
    CALL    LCD_Caracter
    MOVLW   'B'
    CALL    LCD_Caracter
    MOVLW   'I'
    CALL    LCD_Caracter
    MOVLW   'N'
    CALL    LCD_Caracter
    MOVLW   'A'
    CALL    LCD_Caracter
    MOVLW   'C'
    CALL    LCD_Caracter
    MOVLW   'I'
    CALL    LCD_Caracter
    MOVLW   'O'
    CALL    LCD_Caracter
    MOVLW   'N'
    CALL    LCD_Caracter
    CALL    Retardo_1s
PULSADORES
    CALL    Retardo_20ms	; Un retardo de 20ms para los rebotes
    BTFSC   PUL1		; PULSADOR1 = 0
    GOTO    PRUEBA2		; NO, PULSADOR1 ES 1
    BTFSC   PUL2		; PULSADOR2 = 0
    GOTO    ENTRADA_1		; PULSADOR1 = 0 Y PULSADOR2 = 1		
    GOTO    ENTRADA_0		; PULSADOR1 = 0 y PULSADOR2 = 0
    GOTO    BOMBA		; REGRESAMOS AL INICIO DEL PROGRAMA
PRUEBA2
    BTFSC   PUL2		; 
    GOTO    ENTRADA_3		; PULSADOR1 = 1 Y PULSADOR2 = 1
    GOTO    ENTRADA_2		; PULSADOR1 = 1 Y PULSADOR2 = 0

ENTRADA_0
    CALL    LCD_Borra
    MOVLW   'B'
    CALL    LCD_Caracter
    MOVLW   'O'
    CALL    LCD_Caracter
    MOVLW   'O'
    CALL    LCD_Caracter
    MOVLW   'M'
    CALL    LCD_Caracter
    MOVLW   '!'
    CALL    LCD_Caracter
    MOVLW   '!'
    CALL    LCD_Caracter
    CALL    Retardo_200ms
    GOTO    PULSADORES
    
ENTRADA_1
    CALL    LCD_Borra
    MOVLW   'B'
    CALL    LCD_Caracter
    MOVLW   'Y'
    CALL    LCD_Caracter
    MOVLW   'E'
    CALL    LCD_Caracter
    MOVLW   'B'
    CALL    LCD_Caracter
    MOVLW   'Y'
    CALL    LCD_Caracter
    MOVLW   'E'
    CALL    LCD_Caracter
    MOVLW   ':'
    CALL    LCD_Caracter
    MOVLW   ')'
    CALL    LCD_Caracter
    CALL    Retardo_200ms
    GOTO    PULSADORES

ENTRADA_2
    CALL    LCD_Borra
    MOVLW   'C'
    CALL    LCD_Caracter
    MOVLW   'O'
    CALL    LCD_Caracter
    MOVLW   'R'
    CALL    LCD_Caracter
    MOVLW   'R'
    CALL    LCD_Caracter
    MOVLW   'E'
    CALL    LCD_Caracter
    MOVLW   'C'
    CALL    LCD_Caracter
    MOVLW   'T'
    CALL    LCD_Caracter
    MOVLW   'O'
    CALL    LCD_Caracter
    MOVLW   '!'
    CALL    LCD_Caracter
    CALL    Retardo_200ms
    GOTO    PULSADORES
    
ENTRADA_3
    CALL    LCD_Borra
    MOVLW   'F'
    CALL    LCD_Caracter
    MOVLW   'A'
    CALL    LCD_Caracter
    MOVLW   'L'
    CALL    LCD_Caracter
    MOVLW   'T'
    CALL    LCD_Caracter
    MOVLW   'A'
    CALL    LCD_Caracter
    MOVLW   'N'
    CALL    LCD_UnEspacioBlanco
    CALL    LCD_Caracter
    MOVLW   '1'
    CALL    LCD_Caracter
    MOVLW   '0'
    CALL    LCD_Caracter
    MOVLW   'S'
    CALL    LCD_Caracter
    CALL    Retardo_200ms
    GOTO    PULSADORES

    INCLUDE  <E:\PIC16F84A\Librerias\RETARDOS.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD.INC>
    END
