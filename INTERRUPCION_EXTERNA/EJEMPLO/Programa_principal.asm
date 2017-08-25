;**************** THE WELS THEORY ******************
;Descripción: Cada vez que presiona el pulsador conectado al pin RB0/INT 
;se incrementa un contador que es visualizado en el módulo LCD. 
;La lectura del pulsador se hará mediante interrupciones.
;
;Para más información visita: www.thewelstheory.com
;Y sigueme en www.facebook.com/WelsTheory

LIST	   P=16F84A		;Procesador PIC16f84A
INCLUDE  <P16F84A.INC>		;Incluye las librerias 

; CONFIGURACION DEL PIC16F84A
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF
 
;Definimos donde se conectará el pulsador
#DEFINE  Pulsador 	PORTB,0
	
CBLOCK  0x0C
Contador				; El contador a visualizar.
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
    BCF	    OPTION_REG,NOT_RBPU		;Activamos las resistencias Pull-Up
    BCF	    OPTION_REG,INTEDG		;Interrupción INT con flanco descendente
    BCF	    STATUS,RP0			;Accedemos al Banco 0
    CLRF    Contador			;Inicia el contador y lo visualiza
    CALL    VisualizaContador
    MOVLW   B'10010000'			;Habilita la interrupción INT y GIE
    MOVWF   INTCON
START	
    SLEEP				;El micro se pone en bajo consumo esperando
    GOTO    START			;las interrupciones

; Subrutina "ServicioInterrupcion" ---------------------------------------------
;
ServicioInterrupcion
    CALL    Retardo_20ms		;Espera 20ms
    BTFSC   Pulsador			;¿Se pulsó el interruptor?
    GOTO    FinInterrupcion		;No, era un rebote. Va a Fin
    INCF    Contador,F			;Si, incrementa el contador     
VisualizaContador
    CALL    LCD_Linea1			;Y se visualiza
    MOVF    Contador,W
    CALL    BIN_a_BCD
    CALL    LCD_Byte
FinInterrupcion
    BCF	    INTCON,INTF			;Limpia Flag de reconocimiento (INTF)
    RETFIE				;Retora y habilita GIE = 1
	

    INCLUDE  <E:\PIC16F84A\Librerias\RETARDOS.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\LCD.INC>
    INCLUDE  <E:\PIC16F84A\Librerias\BIN_BCD.INC>
    END

