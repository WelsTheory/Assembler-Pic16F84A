;**************** THE WELS THEORY ******************
;Descripción: El LED conectado al PORTB-RB7 se enciende
;durante 300ms y se apaga durante 400ms.
; 200 ms + 100ms -> 2x200ms
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A ; Procesador PIC16f84A
#include "p16f84a.inc" ;Incluye las librerias 
    
; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

;Variables
CBLOCK   0X0C       ;RAM USUARIOS
ENDC      
 
 
;CODIGO
    ORG	    0
INICIO
    BSF	    STATUS,RP0
    CLRF    TRISB	;PORTB todo como salida
    MOVLW   B'00011111'
    MOVWF   TRISA	; PORTA todo como entrada
    BCF	    STATUS,RP0

START
    BSF	    PORTB,7
    CALL    RETARDO_200ms
    CALL    RETARDO_100ms
    BCF	    PORTB,7
    CALL    RETARDO_200ms
    CALL    RETARDO_200ms
    GOTO    START
    
    
;     
;Retardo			;call 2cm
 ; MOVLW   d'X'	;1cm 
  ; MOVWF   Contador	;1cm		
;RegresaCuenta   
 ;  NOP			;1cm 	
  ; DECFSZ  Contador,F	;1cm - 2cm	
  ; GOTO    RegresaCuenta ;2cm CALL RETURN btfsc 		
  ; RETURN		;2cm 
   
   ; Tiempo = 4*(1/f)*1cm = 4*(4MHz)*1 = 1us -> 1cm = 1us 
   ; 2cm + 1cm + 1cm + 10*1 + (10-1)*1 + 2cm + 2cm*(10-1) + 2cm = 45cm = 45us
   ; 2cm + 1cm + 1cm + x + (x-1)* + 2cm + 2cm(x-1) + 2cm = 5 + 4x 
   ; Tiempo = 4x + 5 -> 1ms = 1000us = 5 + 4x -> 248,7 = 249
   ; 4(249)+5 = 1001cm = 1001us = 1ms 
 
    
CBLOCK 
    Contador
    Contador_2
ENDC
    
RETARDO_200ms			
    MOVLW   d'200'		; X		
    GOTO    Retardos_ms	
RETARDO_100ms			
    MOVLW   d'100'		
    GOTO    Retardos_ms	
    
Retardos_ms   
    MOVWF   Contador_2		
Regresa_Cuenta_2
    MOVLW   d'249'		; Y		 
    MOVWF   Contador			
Regresa_Cuenta
    NOP				
    DECFSZ  Contador,F		
    GOTO    Regresa_Cuenta		
    DECFSZ  Contador_2,F		
    GOTO    Regresa_Cuenta_2 	
    RETURN
    
; 2cm + 1cm + 2cm + (2+ 4x + 4xy) -> x=100 y=249
; 5 + ( 2 + 400 + 99600) = 100007cm = 100ms 
; 5 + (2 + 800 + 199200) = 200007cm = 200ms 


   END
   
