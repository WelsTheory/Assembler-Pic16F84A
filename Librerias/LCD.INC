;**************************** Librería "LCD_4BIT.INC" ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten realizar las tareas básicas de control de un módulo LCD de 2
; líneas por 16 caracteres, compatible con el modelo LM016L.
;
; El visualizador LCD está conectado al Puerto B del PIC mediante un bus de 4 bits. Las
; conexiones son:
;    -	Las 4 líneas superiores del módulo LCD, pines <DB7:DB4>  se conectan a las 4
;	líneas superiores del Puerto B del PIC, pines <RB7:RB4>.
;    -	Pin RS del LCD a la línea RA0 del PIC.
;    -	Pin R/W del LCD a la línea RA1 del PIC, o a masa.
;    -	Pin Enable del LCD a la línea RA2 del PIC.
;
; Se utilizan llamadas a subrutinas de retardo de tiempo localizadas en la librería RETARDOS.INC.
;
; ZONA DE DATOS *********************************************************************

	CBLOCK
	LCD_Dato
	LCD_GuardaDato
	LCD_GuardaTRISB
	LCD_Auxiliar1
	LCD_Auxiliar2
	ENDC

LCD_CaracteresPorLinea	EQU	.16	; Número de caracteres por línea de la pantalla.

#DEFINE  LCD_PinRS	PORTA,0
#DEFINE  LCD_PinRW	PORTA,1
#DEFINE  LCD_PinEnable	PORTA,2
#DEFINE  LCD_BusDatos	PORTB

; Subrutina "LCD_Inicializa" ------------------------------------------------------------
;
; Inicialización del módulo LCD: Configura funciones del LCD, produce reset por software,
; borra memoria y enciende pantalla. El fabricante especifica que para garantizar la
; configuración inicial hay que hacerla como sigue:
;
LCD_Inicializa
	bsf	STATUS,RP0		; Configura las líneas conectadas al pines RS,
	bcf	LCD_PinRS		; R/W y E.
	bcf	LCD_PinEnable
	bcf	LCD_PinRW
	bcf	STATUS,RP0
	bcf	LCD_PinRW		; En caso de que esté conectado le indica
					; que se va a escribir en el LCD.
	bcf	LCD_PinEnable		; Impide funcionamiento del LCD poniendo E=0.
	bcf 	LCD_PinRS		; Activa el Modo Comando poniendo RS=0.
	call	Retardo_20ms
	movlw	b'00110000'	
	call	LCD_EscribeLCD		; Escribe el dato en el LCD.
	call	Retardo_5ms	
	movlw	b'00110000'	
	call	LCD_EscribeLCD
	call	Retardo_200micros
	movlw	b'00110000'	
	call	LCD_EscribeLCD
	movlw	b'00100000'		; Interface de 4 bits.
	call	LCD_EscribeLCD

; Ahora configura el resto de los parámetros: 

	call	LCD_2Lineas4Bits5x7	; LCD de 2 líneas y caracteres de 5x7 puntos.
	call	LCD_Borra		; Pantalla encendida y limpia. Cursor al principio
	call	LCD_CursorOFF		; de la línea 1. Cursor apagado.
	call	LCD_CursorIncr		; Cursor en modo incrementar.
	return

; Subrutina "LCD_EscribeLCD" -----------------------------------------------------------
;
; Envía el dato del registro de trabajo W al bus de dato y produce un pequeño pulso en el pin
; Enable del LCD. Para no alterar el contenido de las líneas de la parte baja del Puerto B que
; no son utilizadas para el LCD (pines RB3:RB0), primero se lee estas líneas y después se
; vuelve a enviar este dato sin cambiarlo.

LCD_EscribeLCD
	andlw	b'11110000'		; Se queda con el nibble alto del dato que es el
	movwf	LCD_Dato		; que hay que enviar y lo guarda.
	movf	LCD_BusDatos,W		; Lee la información actual de la parte baja
	andlw	b'00001111'		; del Puerto B, que no se debe alterar.
	iorwf	LCD_Dato,F		; Enviará la parte alta del dato de entrada
					; y en la parte baja lo que había antes.
	bsf	STATUS,RP0		; Acceso al Banco 1.
	movf	TRISB,W		; Guarda la configuración que tenía antes TRISB.
	movwf	LCD_GuardaTRISB
	movlw	b'00001111'		; Las 4 líneas inferiores del Puerto B se dejan 
	andwf	PORTB,F			; como estaban y las 4 superiores como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
;
	movf	LCD_Dato,W		; Recupera el dato a enviar.
	movwf	LCD_BusDatos		; Envía el dato al módulo LCD.
	bsf	LCD_PinEnable		; Permite funcionamiento del LCD mediante un pequeño
	bcf	LCD_PinEnable		; pulso y termina impidiendo el funcionamiento del LCD.
	bsf	STATUS,RP0		; Acceso al Banco 1. Restaura el antiguo valor en
	movf	LCD_GuardaTRISB,W	; la configuración del Puerto B.
	movwf	PORTB			; Realmente es TRISB.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	return

; Subrutinas variadas para el control del módulo LCD -----------------------------------------
;
;Los comandos que pueden ser ejecutados son:
;
LCD_CursorIncr				; Cursor en modo incrementar.
	movlw	b'00000110'
	goto	LCD_EnviaComando
LCD_Linea1				; Cursor al principio de la Línea 1.
	movlw	b'10000000'		; Dirección 00h de la DDRAM
	goto	LCD_EnviaComando
LCD_Linea2				; Cursor al principio de la Línea 2.
	movlw	b'11000000'		; Dirección 40h de la DDRAM
	goto	LCD_EnviaComando
LCD_PosicionLinea1			; Cursor a posición de la Línea 1, a partir de la
	iorlw	b'10000000'		; dirección 00h de la DDRAM más el valor del
	goto	LCD_EnviaComando	; registro W.
LCD_PosicionLinea2			; Cursor a posición de la Línea 2, a partir de la
	iorlw	b'11000000'		; dirección 40h de la DDRAM más el valor del
	goto	LCD_EnviaComando	; registro W.
LCD_OFF				; Pantalla apagada.
	movlw	b'00001000'
	goto	LCD_EnviaComando
LCD_CursorON				; Pantalla encendida y cursor encendido.
	movlw	b'00001110'
	goto	LCD_EnviaComando
LCD_CursorOFF				; Pantalla encendida y cursor apagado.
	movlw	b'00001100'
	goto	LCD_EnviaComando
LCD_Borra				; Borra toda la pantalla, memoria DDRAM y pone el 
	movlw	b'00000001'		; cursor a principio de la línea 1.
	goto	LCD_EnviaComando
LCD_2Lineas4Bits5x7			; Define la pantalla de 2 líneas, con caracteres
	movlw	b'00101000'		; de 5x7 puntos y conexión al PIC mediante bus de
;	goto	LCD_EnviaComando	; 4 bits. 

; Subrutinas "LCD_EnviaComando" y "LCD_Caracter" ------------------------------------
;
; "LCD_EnviaComando". Escribe un comando en el registro del módulo LCD. La palabra de
; comando ha sido entregada a través del registro W.  Trabaja en Modo Comando.
; "LCD_Caracter". Escribe en la memoria DDRAM del LCD el carácter ASCII introducido a
; a través del registro W. Trabaja en Modo Dato.
;
LCD_EnviaComando
	bcf	LCD_PinRS		; Activa el Modo Comando, poniendo RS=0.
	goto	LCD_Envia
LCD_Caracter
	bsf	LCD_PinRS		; Activa el "Modo Dato", poniendo RS=1.
	call	LCD_CodigoCGROM	; Obtiene el código para correcta visualización.
LCD_Envia
	movwf	LCD_GuardaDato		; Guarda el dato a enviar.
	call	LCD_EscribeLCD		; Primero envía el nibble alto.
	swapf	LCD_GuardaDato,W	; Ahora envía el nibble bajo. Para ello pasa el
					; nibble bajo del dato a enviar a parte alta del byte.
	call	LCD_EscribeLCD		; Se envía al visualizador LCD.
	btfss	LCD_PinRS		; Debe garantizar una correcta escritura manteniendo 
	call	Retardo_2ms		; 2 ms en modo comando y 50 µs en modo cáracter.
	call	Retardo_50micros
	return	

; Subrutina "LCD_CodigoCGROM" -----------------------------------------------------------
;
; A partir del carácter ASCII número 127 los códigos de los caracteres definidos en la
; tabla CGROM del LM016L no coinciden con los códigos ASCII. Así por ejemplo, el código
; ASCII de la "Ñ" en la tabla CGRAM del LM016L es EEh.
;
; Esta subrutina convierte los códigos ASCII de la "Ñ", "º" y otros, a códigos CGROM para que
; que puedan ser visualizado en el módulo LM016L.
; 
; Entrada:	En (W) el código ASCII del carácter que se desea visualizar.
; Salida:	En (W) el código definido en la tabla CGROM.

LCD_CodigoCGROM
	movwf	LCD_Dato		; Guarda el valor del carácter y comprueba si es
LCD_EnheMinuscula			; un carácter especial.
	sublw	'ñ' 			; ¿Es la "ñ"?
	btfss	STATUS,Z
	goto	LCD_EnheMayuscula	; No es "ñ".
	movlw	b'11101110'		; Código CGROM de la "ñ".
	movwf	LCD_Dato
	goto	LCD_FinCGROM
LCD_EnheMayuscula
	movf	LCD_Dato,W		; Recupera el código ASCII de entrada.
	sublw	'Ñ' 			; ¿Es la "Ñ"?
	btfss	STATUS,Z
	goto	LCD_Grado		; No es "Ñ".
	movlw	b'11101110'		; Código CGROM de la "ñ". (No hay símbolo para
	movwf	LCD_Dato		; la "Ñ" mayúscula en la CGROM).
	goto	LCD_FinCGROM	
LCD_Grado
	movf	LCD_Dato,W		; Recupera el código ASCII de entrada.
	sublw	'º' 			; ¿Es el símbolo "º"?
	btfss	STATUS,Z
	goto	LCD_FinCGROM		; No es "º".
	movlw	b'11011111'		; Código CGROM del símbolo "º".
	movwf	LCD_Dato
LCD_FinCGROM
	movf	LCD_Dato,W		; En (W) el código buscado.
	return

; Subrutina "LCD_DosEspaciosBlancos" y "LCD_LineaBlanco" --------------------------------
;
; Visualiza espacios en blanco.

LCD_LineaEnBlanco
	movlw	LCD_CaracteresPorLinea
	goto	LCD_EnviaBlancos
LCD_UnEspacioBlanco
	movlw	.1
	goto	LCD_EnviaBlancos
LCD_DosEspaciosBlancos
	movlw	.2
	goto	LCD_EnviaBlancos
LCD_TresEspaciosBlancos
	movlw	.3
LCD_EnviaBlancos
	movwf	LCD_Auxiliar1		; (LCD_Auxiliar1) se utiliza como contador.
LCD_EnviaOtroBlanco	
	movlw	' '			; Esto es un espacio en blanco.
	call	LCD_Caracter		; Visualiza tanto espacios en blanco como se
	decfsz	LCD_Auxiliar1,F		; haya cargado en (LCD_Auxiliar1).
	goto	LCD_EnviaOtroBlanco
	return

; Subrutinas "LCD_ByteCompleto" y "LCD_Byte" --------------------------------------------
;
; Subrutina "LCD_ByteCompleto", visualiza el byte que almacena el registro W en el
; lugar actual de la pantalla. Por ejemplo, si (W)=b'10101110' visualiza "AE".
;
; Subrutina "LCD_Byte" igual que la anterior, pero en caso de que el nibble alto sea cero 
; visualiza en su lugar un espacio en blanco. Por ejemplo si (W)=b'10101110' visualiza "AE"
; y si (W)=b'00001110', visualiza " E" (un espacio blanco delante).
;
; Utilizan la subrutina "LCD_Nibble" que se analiza más adelante.
;
LCD_Byte
	movwf	LCD_Auxiliar2		; Guarda el valor de entrada.
	andlw	b'11110000'		; Analiza si el nibble alto es cero.
	btfss	STATUS,Z		; Si es cero lo apaga.
	goto	LCD_VisualizaAlto		; No es cero y lo visualiza.
	movlw	' '			; Visualiza un espacio en blanco.
	call	LCD_Caracter
	goto	LCD_VisualizaBajo

LCD_ByteCompleto
	movwf	LCD_Auxiliar2		; Guarda el valor de entrada.
LCD_VisualizaAlto
	swapf	LCD_Auxiliar2,W		; Pone el nibble alto en la parte baja.
	call	LCD_Nibble		; Lo visualiza.
LCD_VisualizaBajo
	movf	LCD_Auxiliar2,W		; Repite el proceso con el nibble bajo.
;	call	LCD_Nibble		; Lo visualiza.
;	return

; Subrutina "LCD_Nibble" ----------------------------------------------------------------
;
; Visualiza en el lugar actual de la pantalla, el valor hexadecimal que almacena en el nibble
; bajo del registro W. El nibble alto de W no es tenido en cuenta. Ejemplos:
; - Si (W)=b'01010110', se visualizará "6". 
; - Si (W)=b'10101110', se visualizará "E". 
;
LCD_Nibble
	andlw	b'00001111'		; Se queda con la parte baja.
	movwf	LCD_Auxiliar1		; Lo guarda.
	sublw	0x09			; Comprueba si hay que representarlo con letra.
	btfss	STATUS,C	
	goto	LCD_EnviaByteLetra
	movf	LCD_Auxiliar1,W
	addlw	'0'			; El número se pasa a carácter ASCII sumándole
	goto 	LCD_FinVisualizaDigito	; el ASCII del cero y lo visualiza.
LCD_EnviaByteLetra
	movf	LCD_Auxiliar1,W
	addlw	'A'-0x0A			; Sí, por tanto, se le suma el ASCII de la 'A'.
LCD_FinVisualizaDigito
	goto	LCD_Caracter		; Y visualiza el carácter. Se hace con un "goto"
					; para no sobrecargar la pila.
					
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================