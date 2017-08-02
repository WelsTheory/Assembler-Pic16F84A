;**************************** Librería "DISPLAY_7S.INC **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Subrutinas para convertir un código ASCII en su valor equivalente en 7 segmentos y así
; poder activar displays.
;
; Si el código ASCII es menor que el signo más '+' o mayor  que la letra zeta 'Z' obtiene
; el código erróneo b'10000000' para encender sólo el punto decimal del display.
;
; Si se trata de un número hay que ejecutar la subrutina "Numero_a_7Segmentos" que convierte
; un numero (de 0 a 9) en su equivalente en código de 7 segmentos.
;
; Entrada: En registro W, el dato en código ASCII a convertir.
; Salida : En registro W, el código 7 segmentos.

	CBLOCK
	Display7s_Dato			; Aquí se reservará el valor del dato de entrada.
	ENDC
	
Numero_a_7Segmentos
	andlw	b'00001111'		; Se queda con el nibble bajo.
	addlw	'0'			; Se pasa a ASCII sumándole el valor ASCII
					; del "0" y ejecuta "ASCII_7_Segmentos".
ASCII_a_7Segmentos
	movwf	Display7s_Dato		; Guarda el valor del carácter.
	sublw	' ' 			; Comprueba si es " " (espacio).
	btfsc	STATUS,Z		; ¿Es distinta de " " (espacio)?, ¿Z=0?
	retlw	00h			; Es " ". Devuelve el código 7-Segmentos del " ".
	movf	Display7s_Dato,W		; Recupera el valor del dato de entrada.
	sublw	'Ñ' 			; Comprueba si es "Ñ".
	btfsc	STATUS,Z		; ¿Es distinta de "Ñ"?, ¿Z=0?
	retlw	55h			; Es "Ñ". Devuelve el código 7-Segmentos de "Ñ".
	movf	Display7s_Dato,W		; Recupera el valor del dato de entrada.
	sublw	'º' 			; Comprueba si es "º".
	btfsc	STATUS,Z		; ¿Es distinta de "º"?, ¿Z=0?
	retlw	63h			; Es "º". Devuelve el código 7-Segmentos de "º".
;
	movf	Display7s_Dato,W		; Comprueba si el código ASCII es mayor que la "Z".
	sublw	'Z'			; (W)='Z'-(Display7s_Dato)
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿'Z'>=(Display7s_Dato)?
	retlw	b'10000000'		; Si el código ASCII es mayor que 'Z' es un error.
	movlw	'+' 			; Averigua en qué orden está el carácter leído
	subwf	Display7s_Dato,W		; dentro de la tabla de conversión, respecto del
	btfss	STATUS,C		; primero que es '+'.
	retlw	b'10000000'		; Si el código ASCII es menor que '+' es un error.
;
	addwf	PCL,F			; Obtiene el código 7 segmentos.
InicioTablaASCII
	DT	46h, 04h, 40h, 80h, 00h, 3Fh, 06h, 5Bh, 4Fh, 66h, 6Dh	; Signos y
	DT	7Dh, 07h, 7Fh, 67h, 41h, 88h, 00h, 48h, 00h, 00h, 00h	; números.
	DT	77h, 7Ch, 39h, 5Eh, 79h, 71h, 6Fh, 76h, 19h, 1Eh, 7Ah, 38h, 37h ; Letras.
	DT	54h, 3Fh, 73h, 67h, 50h, 6Dh, 78h, 1Ch, 3Eh, 1Dh, 70h, 6Eh, 49h
FinTablaASCII
;
; Esta es la tabla para la visualización en display de siete segmentos (Ver figura 11-3).

;IF (FinTablaASCII > 0xFF)
 ;   ERROR	"¡CUIDADO!: La tabla ha superado el tamaño de la página de los"
  ;  MESSG	"primeros 256 bytes de memoria ROM. NO funcionará correctamente."
;ENDIF

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================