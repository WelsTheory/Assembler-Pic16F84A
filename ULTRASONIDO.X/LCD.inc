;**************************** Librer?a "LCD_4BIT.INC" ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L?pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten realizar las tareas b?sicas de control de un m?dulo LCD de 2
; l?neas por 16 caracteres, compatible con el modelo LM016L.
;
; El visualizador LCD est? conectado al Puerto B del PIC mediante un bus de 4 bits. Las
; conexiones son:
;    -	Las 4 l?neas superiores del m?dulo LCD, pines <DB7:DB4>  se conectan a las 4
;	l?neas superiores del Puerto B del PIC, pines <RB7:RB4>.
;    -	Pin RS del LCD a la l?nea RA0 del PIC.
;    -	Pin R/W del LCD a la l?nea RA1 del PIC, o a masa.
;    -	Pin Enable del LCD a la l?nea RA2 del PIC.
;
; Se utilizan llamadas a subrutinas de retardo de tiempo localizadas en la librer?a RETARDOS.INC.
;
; ZONA DE DATOS *********************************************************************

	CBLOCK
	LCD_Dato
	LCD_GuardaDato
	LCD_GuardaTRISB
	LCD_Auxiliar1
	LCD_Auxiliar2
	ENDC

LCD_CaracteresPorLinea	EQU	.16	; N?mero de caracteres por l?nea de la pantalla.

#DEFINE  LCD_PinRS	PORTA,0
#DEFINE  LCD_PinRW	PORTA,1
#DEFINE  LCD_PinEnable	PORTA,2
#DEFINE  LCD_BusDatos	PORTB

; Subrutina "LCD_Inicializa" ------------------------------------------------------------
;
; Inicializaci?n del m?dulo LCD: Configura funciones del LCD, produce reset por software,
; borra memoria y enciende pantalla. El fabricante especifica que para garantizar la
; configuraci?n inicial hay que hacerla como sigue:
;
LCD_Inicializa
	bsf	STATUS,RP0		; Configura las l?neas conectadas al pines RS,
	bcf	LCD_PinRS		; R/W y E.
	bcf	LCD_PinEnable
	bcf	LCD_PinRW
	bcf	STATUS,RP0
	bcf	LCD_PinRW		; En caso de que est? conectado le indica
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

; Ahora configura el resto de los par?metros: 

	call	LCD_2Lineas4Bits5x7	; LCD de 2 l?neas y caracteres de 5x7 puntos.
	call	LCD_Borra		; Pantalla encendida y limpia. Cursor al principio
	call	LCD_CursorOFF		; de la l?nea 1. Cursor apagado.
	call	LCD_CursorIncr		; Cursor en modo incrementar.
	return

; Subrutina "LCD_EscribeLCD" -----------------------------------------------------------
;
; Env?a el dato del registro de trabajo W al bus de dato y produce un peque?o pulso en el pin
; Enable del LCD. Para no alterar el contenido de las l?neas de la parte baja del Puerto B que
; no son utilizadas para el LCD (pines RB3:RB0), primero se lee estas l?neas y despu?s se
; vuelve a enviar este dato sin cambiarlo.

LCD_EscribeLCD
	andlw	b'11110000'		; Se queda con el nibble alto del dato que es el
	movwf	LCD_Dato		; que hay que enviar y lo guarda.
	movf	LCD_BusDatos,W		; Lee la informaci?n actual de la parte baja
	andlw	b'00001111'		; del Puerto B, que no se debe alterar.
	iorwf	LCD_Dato,F		; Enviar? la parte alta del dato de entrada
					; y en la parte baja lo que hab?a antes.
	bsf	STATUS,RP0		; Acceso al Banco 1.
	movf	TRISB,W		; Guarda la configuraci?n que ten?a antes TRISB.
	movwf	LCD_GuardaTRISB
	movlw	b'00001111'		; Las 4 l?neas inferiores del Puerto B se dejan 
	andwf	PORTB,F			; como estaban y las 4 superiores como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
;
	movf	LCD_Dato,W		; Recupera el dato a enviar.
	movwf	LCD_BusDatos		; Env?a el dato al m?dulo LCD.
	bsf	LCD_PinEnable		; Permite funcionamiento del LCD mediante un peque?o
	bcf	LCD_PinEnable		; pulso y termina impidiendo el funcionamiento del LCD.
	bsf	STATUS,RP0		; Acceso al Banco 1. Restaura el antiguo valor en
	movf	LCD_GuardaTRISB,W	; la configuraci?n del Puerto B.
	movwf	PORTB			; Realmente es TRISB.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	return

; Subrutinas variadas para el control del m?dulo LCD -----------------------------------------
;
;Los comandos que pueden ser ejecutados son:
;
LCD_CursorIncr				; Cursor en modo incrementar.
	movlw	b'00000110'
	goto	LCD_EnviaComando
LCD_Linea1				; Cursor al principio de la L?nea 1.
	movlw	b'10000000'		; Direcci?n 00h de la DDRAM
	goto	LCD_EnviaComando
LCD_Linea2				; Cursor al principio de la L?nea 2.
	movlw	b'11000000'		; Direcci?n 40h de la DDRAM
	goto	LCD_EnviaComando
LCD_PosicionLinea1			; Cursor a posici?n de la L?nea 1, a partir de la
	iorlw	b'10000000'		; direcci?n 00h de la DDRAM m?s el valor del
	goto	LCD_EnviaComando	; registro W.
LCD_PosicionLinea2			; Cursor a posici?n de la L?nea 2, a partir de la
	iorlw	b'11000000'		; direcci?n 40h de la DDRAM m?s el valor del
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
	movlw	b'00000001'		; cursor a principio de la l?nea 1.
	goto	LCD_EnviaComando
LCD_2Lineas4Bits5x7			; Define la pantalla de 2 l?neas, con caracteres
	movlw	b'00101000'		; de 5x7 puntos y conexi?n al PIC mediante bus de
;	goto	LCD_EnviaComando	; 4 bits. 

; Subrutinas "LCD_EnviaComando" y "LCD_Caracter" ------------------------------------
;
; "LCD_EnviaComando". Escribe un comando en el registro del m?dulo LCD. La palabra de
; comando ha sido entregada a trav?s del registro W.  Trabaja en Modo Comando.
; "LCD_Caracter". Escribe en la memoria DDRAM del LCD el car?cter ASCII introducido a
; a trav?s del registro W. Trabaja en Modo Dato.
;
LCD_EnviaComando
	bcf	LCD_PinRS		; Activa el Modo Comando, poniendo RS=0.
	goto	LCD_Envia
LCD_Caracter
	bsf	LCD_PinRS		; Activa el "Modo Dato", poniendo RS=1.
	call	LCD_CodigoCGROM	; Obtiene el c?digo para correcta visualizaci?n.
LCD_Envia
	movwf	LCD_GuardaDato		; Guarda el dato a enviar.
	call	LCD_EscribeLCD		; Primero env?a el nibble alto.
	swapf	LCD_GuardaDato,W	; Ahora env?a el nibble bajo. Para ello pasa el
					; nibble bajo del dato a enviar a parte alta del byte.
	call	LCD_EscribeLCD		; Se env?a al visualizador LCD.
	btfss	LCD_PinRS		; Debe garantizar una correcta escritura manteniendo 
	call	Retardo_2ms		; 2 ms en modo comando y 50 ?s en modo c?racter.
	call	Retardo_50micros
	return	

; Subrutina "LCD_CodigoCGROM" -----------------------------------------------------------
;
; A partir del car?cter ASCII n?mero 127 los c?digos de los caracteres definidos en la
; tabla CGROM del LM016L no coinciden con los c?digos ASCII. As? por ejemplo, el c?digo
; ASCII de la "?" en la tabla CGRAM del LM016L es EEh.
;
; Esta subrutina convierte los c?digos ASCII de la "?", "?" y otros, a c?digos CGROM para que
; que puedan ser visualizado en el m?dulo LM016L.
; 
; Entrada:	En (W) el c?digo ASCII del car?cter que se desea visualizar.
; Salida:	En (W) el c?digo definido en la tabla CGROM.

LCD_CodigoCGROM
	movwf	LCD_Dato		; Guarda el valor del car?cter y comprueba si es
LCD_EnheMinuscula			; un car?cter especial.
	sublw	'?' 			; ?Es la "?"?
	btfss	STATUS,Z
	goto	LCD_EnheMayuscula	; No es "?".
	movlw	b'11101110'		; C?digo CGROM de la "?".
	movwf	LCD_Dato
	goto	LCD_FinCGROM
LCD_EnheMayuscula
	movf	LCD_Dato,W		; Recupera el c?digo ASCII de entrada.
	sublw	'?' 			; ?Es la "?"?
	btfss	STATUS,Z
	goto	LCD_Grado		; No es "?".
	movlw	b'11101110'		; C?digo CGROM de la "?". (No hay s?mbolo para
	movwf	LCD_Dato		; la "?" may?scula en la CGROM).
	goto	LCD_FinCGROM	
LCD_Grado
	movf	LCD_Dato,W		; Recupera el c?digo ASCII de entrada.
	sublw	'?' 			; ?Es el s?mbolo "?"?
	btfss	STATUS,Z
	goto	LCD_FinCGROM		; No es "?".
	movlw	b'11011111'		; C?digo CGROM del s?mbolo "?".
	movwf	LCD_Dato
LCD_FinCGROM
	movf	LCD_Dato,W		; En (W) el c?digo buscado.
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
; Utilizan la subrutina "LCD_Nibble" que se analiza m?s adelante.
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
; - Si (W)=b'01010110', se visualizar? "6". 
; - Si (W)=b'10101110', se visualizar? "E". 
;
LCD_Nibble
	andlw	b'00001111'		; Se queda con la parte baja.
	movwf	LCD_Auxiliar1		; Lo guarda.
	sublw	0x09			; Comprueba si hay que representarlo con letra.
	btfss	STATUS,C	
	goto	LCD_EnviaByteLetra
	movf	LCD_Auxiliar1,W
	addlw	'0'			; El n?mero se pasa a car?cter ASCII sum?ndole
	goto 	LCD_FinVisualizaDigito	; el ASCII del cero y lo visualiza.
LCD_EnviaByteLetra
	movf	LCD_Auxiliar1,W
	addlw	'A'-0x0A			; S?, por tanto, se le suma el ASCII de la 'A'.
LCD_FinVisualizaDigito
	goto	LCD_Caracter		; Y visualiza el car?cter. Se hace con un "goto"
					; para no sobrecargar la pila.
					
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L?pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================


