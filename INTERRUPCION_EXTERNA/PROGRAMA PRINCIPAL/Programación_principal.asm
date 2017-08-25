;**************** THE WELS THEORY ******************
;Descripción: Cada vez que presiona el pulsador conectado al pin RB0/INT 
;se enciende y apaga un led, además se mostrará un mensaje en cada pulsación
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

LIST	   P=16F84A		;Procesador PIC16f84A
INCLUDE  <P16F84A.INC>		;Incluye las librerias 

; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF
 
;Definimos donde se conectará el pulsador
#DEFINE	    Pulsador 	PORTB,0
#DEFINE	    LED		PORTB,1
	
CBLOCK  0x0C
Activador				;Haré los cambios en el código
ENDC	

;CODIGO
    ORG	    0
    GOTO    INICIO
    ORG	    4				;Vector de la interrupción
    GOTO    ServicioInterrupcion	
INICIO
    CALL    LCD_Inicializa
    BSF	    STATUS,RP0			;Accedemos al Banco 1
    BSF	    Pulsador			;El puerto RB0 se coloca como entrada
    BCF	    LED				;RB1 como salida
    BCF	    OPTION_REG,NOT_RBPU		;Activamos las resistencias Pull-Up
    BCF	    OPTION_REG,INTEDG		;Interrupción INT con flanco descendente
    BCF	    STATUS,RP0			;Accedemos al Banco 0
    CLRF    Activador
    MOVLW   B'10010000'			;Habilita la interrupción INT y GIE
    MOVWF   INTCON
START
    CALL    LCD_Linea1
    MOVLW   Mensaje_Predeterminado	
    BTFSC   Activador,0			
    MOVLW   Mensaje_Secundario		
    CALL    LCD_Mensaje
    CALL    LCD_Linea2
    MOVLW   Mensaje_SegundaLinea	
    CALL    LCD_Mensaje
    CALL    Retardo_200ms
    CALL    LCD_Linea2
    BTFSC   Activador,0
    CALL    LCD_LineaEnBlanco
    CALL    Retardo_200ms
    GOTO    START

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
; Rutina predeterminada por MICROCHIP
    CBLOCK	
    Guarda_W
    Guarda_STATUS
    Guarda_R_ContA
    Guarda_R_ContB
    ENDC

ServicioInterrupcion			; Conmuta el valor "Intermitencia",
    movwf   Guarda_W			; Guarda W y STATUS.
    swapf   STATUS,W			; Ya que "movf STATUS,W", corrompe el bit Z.
    movwf   Guarda_STATUS
    bcf	    STATUS,RP0			; Para asegurarse que trabaja con el banco 0.
    movf    R_ContA,W			; Guarda los registros utilizados en esta 
    movwf   Guarda_R_ContA		; subrutina y también en la principal.
    movf    R_ContB,W
    movwf   Guarda_R_ContB

;Acá comienza el código que deseamos que haga cuando aparece la interrupción
    CALL    Retardo_20ms
    BTFSC   Pulsador
    GOTO    FinInterrupcion
    COMF    Activador,F
    BTFSC   LED
    GOTO    APAGADO
    BSF	    LED
    GOTO    FinInterrupcion
APAGADO
    BCF	    LED
    GOTO    FinInterrupcion
;Hasta acá es nuestro código
    
; Rutina predeterminada por MICROCHIP	
FinInterrupcion
    swapf   Guarda_STATUS,W		; Restaura el STATUS.
    movwf   STATUS
    swapf   Guarda_W,F		; Restaura W como estaba antes de producirse
    swapf   Guarda_W,W		; interrupción.
    movf    Guarda_R_ContA,W	; Restaura los registros utilizados en esta 
    movwf   R_ContA			; subrutina y también en la principal.
    movf    Guarda_R_ContB,W
    movwf   R_ContB
    bcf	    INTCON,INTF
    retfie

; "Mensajes" ----------------------------------------------------------------------------
Mensajes
    ADDWF   PCL,F
Mensaje_SegundaLinea
    DT "  Wels Theory", 0x00
Mensaje_Secundario
    DT " Suscribete!! =D ", 0x00
Mensaje_Predeterminado
    DT " Tutorial 12 INT", 0x00
	
    INCLUDE  <E:\PIC16F84A\Librerias\RETARDOS.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\BIN_BCD.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD_Mensaje.INC>
    END
