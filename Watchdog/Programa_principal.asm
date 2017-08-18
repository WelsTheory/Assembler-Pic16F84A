;**************** THE WELS THEORY ******************
;Descripción: Se visualizará un contador cada vez que se presione
;un pulsador. Si en 1 segundo no se presiona, se activa el Watchdog
;y aparecerá un mensaje.
;
;Para este ejemplo estoy usando un Prescaler de 128. Si cada periodo
;dura 18ms -> 18ms x 128 = 2,3s sería la temporización del watchdog
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

List P=16F84A ; Procesador PIC16f84A
#include "p16f84a.inc" ;Incluye las librerias 

; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_ON & _PWRTE_ON & _CP_OFF ;Se habilita el watchdog

;Definimos salida del LED
#DEFINE	    Pulsador	    PORTA,4
 
;Variable cuenta declarada
CBLOCK	0x0C
Cuenta
ENDC	
 
;CODIGO
    ORG	0
INICIO
    CALL    LCD_Inicializa	    
    BTFSS   STATUS,NOT_TO	    ;Se reseteo por Watchdogo? TO = 0 
    GOTO    Watchdog_Activo	    ;Sí
    MOVLW   Mensaje_Contador	    ;No, entonces se muestra el mensaje contador
    CALL    LCD_Mensaje	    
    BSF	    STATUS,RP0
    BSF	    Pulsador		    ;Pulsador como entrada
    MOVLW   B'00001111'		    ;Configuración con prescaler 128
    MOVWF   OPTION_REG		    
    BCF	    STATUS,RP0
    CLRF    Cuenta		    ;Reinicia el contador
    CALL    Visualiza_Cuenta	    ;Visualiza la cuenta
    CALL    Retardo_2s		    ;Retardo inicial de 1s
START
    BTFSS   Pulsador		    ;Pulsador presionado?
    CALL    Incrementa_Cuenta	    ;Sí, incrementa cuenta
    GOTO    START		    ;No, regresa a Start

;Si el Watchdog es activado aparece un mensaje y sólo se puede salir de esto
;reseteando o apagando el sistema.
Watchdog_Activo
    MOVLW   Mensaje_Watchdog	    ;Si el watchdog se desbordó aparece un
    CALL    LCD_Mensaje		    ;mensaje en el LCD
    SLEEP

;Subrutina para incrementar la cuenta
Incrementa_Cuenta
    CLRWDT			    ;Resetea el Watchdog    
    CALL    Retardo_20ms	    ;Retardo para los rebotes
    BTFSC   Pulsador		    ;Pulsador presionado?
    GOTO    Fin_Cuenta		    ;No. Vamos a fin de cuenta
    INCF    Cuenta,F		    ;Sí.Incrementa cuenta
Visualiza_Cuenta
    CALL    LCD_Linea1
    MOVF    Cuenta,W		    
    CALL    BIN_a_BCD
    CALL    LCD_Byte		    ;Se visualiza en la primera linea en BCD
Dejamos_Pulsar			    
    CLRWDT			    ;Resetea el pulsador mientras esté pulsado
    BTFSS   Pulsador		    ;Se dejó de presionar?
    GOTO    Dejamos_Pulsar	    ;No. Esperamos a que deje de pulsarse
Fin_Cuenta
    RETURN

;Mensajes a visualizar 
Mensajes
    ADDWF   PCL,F
Mensaje_Contador		    ;Mensaje para aumentar la cuenta
    DT "    Cuenta ",0x00
Mensaje_Watchdog		    ;Mensajes cuando se reinicia por Watchdog
    DT "Muy lento eres",0x00

    INCLUDE  <E:\PIC16F84A\Librerias\RETARDOS.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\BIN_BCD.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD_Mensaje.INC>
    END