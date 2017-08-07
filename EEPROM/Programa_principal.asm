;**************** THE WELS THEORY ******************
;Descripción: Nuestro programa sólo funcionará 3 veces
;por lo que si lo reseteamos más, no funcionará.
; 
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A ; Procesador PIC16f84A
#include "p16f84a.inc" ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

CBLOCK	0x0C
CONTADOR
ENDC

ORG	0x2100	 ; Corresponde a la dirección 0 de la EEPROM 
DE	0x00	 ; El contador en principi

NUM_SEC	    EQU	    .4
 
;CODIGO
    ORG	0
INICIO
    CALL    LCD_Inicializa
    CLRW			; W = 0
    CALL    EEPROM_LeeDato	;Lee la primera posición de la memoria EEPROM
    MOVWF   CONTADOR		;El dato es guardado en CONTADOR
    MOVLW   NUM_SEC		
    SUBWF   CONTADOR,W		;Compara CONTADOR con NUM_SEC
    BTFSC   STATUS,C		;Si llegó al máximo de intentos se bloquea
    GOTO    BLOQUEADO
    MOVF    CONTADOR,W		
    ANDLW   B'00001111'		;MULTIPLICAR MASCARA
    CALL    NUMERO		;Obtenemos el valor
    CALL    LCD_Caracter	;Se visualiza
    movlw   MENSAJE_RESETEADO
    CALL    LCD_Mensaje
    INCF    CONTADOR,F		;Incrementa el contador
    MOVF    CONTADOR,W			
    CALL    EEPROM_EscribeDato	;Guardamos el dato del Contador
START
    SLEEP
    GOTO    START

BLOQUEADO
    MOVLW   MENSAJE_BLOQUEADO	    ;Sólo grabando nuevamente el programa
    CALL    LCD_Mensaje		    ;se puede salir del bloqueo
    SLEEP
    GOTO    BLOQUEADO
    
NUMERO    
    ADDWF   PCL,F 
    DT "0","1","2","3",  0x00
    
Mensajes
    ADDWF   PCL,F
MENSAJE_RESETEADO
    DT " RESETEADO", 0x00
MENSAJE_BLOQUEADO
    DT "ESTOY BLOQUEADO!!", 0x00	
	
    INCLUDE  <E:\PIC16F84A\Librerias\RETARDOS.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\EEPROM.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD_Mensaje.INC>
    END
