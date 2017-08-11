;******************************** Librería "BIN_BCD.INC" ********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Un número binario natural de 8 bits es convertido a BCD. El resultado se guarda en tres
; posiciones de memorias llamadas: BCD_Centenas, BCD_Decenas y BCD_Unidades.
;
; El procedimiento utilizado es mediante restas de 10, tal como se explicó en el capítulo 9.
;
; Entrada:	En el registro W el número binario natural a convertir.
; Salidas:	En (BCD_Centenas), (BCD_Decenas) y (BCD_Unidades).
;		En el registro W también las decenas (nibble alto) y unidades (nibble bajo).

; Subrutina "BIN_a_BCD" -----------------------------------------------------------------

	CBLOCK				; En las subrutinas no se debe fijar la dirección
	BCD_Centenas			; de la RAM de usuario. Se toma a continuación de
	BCD_Decenas			; la última asignada.
	BCD_Unidades	
	ENDC
;
BIN_a_BCD
	clrf	BCD_Centenas		; Carga los registros con el resultado inicial.
	clrf	BCD_Decenas		; En principio las centenas y decenas a cero.
	movwf	BCD_Unidades		; Se carga el número binario a convertir.
BCD_Resta10
	movlw	.10			; A las unidades se les va restando 10 en cada
	subwf	BCD_Unidades,W		; pasada. (W)=(BCD_Unidades) -10.
	btfss	STATUS,C		; ¿C = 1?, ¿(W) positivo?, ¿(BCD_Unidades)>=10?
	goto 	BIN_BCD_Fin		; No, es menor de 10. Se acabó.
BCD_IncrementaDecenas
	movwf	BCD_Unidades		; Recupera lo que queda por restar.
	incf	BCD_Decenas,F		; Incrementa las decenas y comprueba si ha llegado
	movlw	.10			; a 10. Lo hace mediante una resta.
	subwf	BCD_Decenas,W		; (W)=(BCD_Decenas)-10).
	btfss	STATUS,C		; ¿C = 1?, ¿(W) positivo?, ¿(BCD_Decenas)>=10?
	goto	BCD_Resta10		; No. Vuelve a dar otra pasada, restándole 10 a
BCD_IncrementaCentenas			; las unidades.
	clrf	BCD_Decenas		; Pone a cero las decenas 
	incf	BCD_Centenas,F		; e incrementa las centenas.
	goto	BCD_Resta10		; Otra pasada: Resta 10 al número a convertir.
BIN_BCD_Fin
	swapf	BCD_Decenas,W		; En el nibble alto de (W) también las decenas.
	addwf	BCD_Unidades,W		; En el nibble bajo de (W) las unidades.
	return				; Vuelve al programa principal.
	
; La directiva "END" se debe poner en el programa principal no aquí.

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================