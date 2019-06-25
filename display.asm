;-----------------------------------------------------------------------------------------------------
;Fernández Scagliusi, Santiago
;Grupo: L4
;Trabajo: Piano
;
;
;Display.asm
;
;Contiene las rutinas de gestión del display:
;
;-----------------------------------------------------------------------------------------------------

ERROR           equ     $FFFF
FlagRef         dc.w    0

                IFEQ    HARDWARE-SIMU                           ;Si estamos en simulador...
Display         equ     $E010
Blanco          equ     $00 
Tab7Seg         dc.b    %00111111       ;0
                dc.b    %00000110       ;1
                dc.b    %01011011       ;2
                dc.b    %01001111       ;3
                dc.b    %01100110       ;4
                dc.b    %01101101       ;5
                dc.b    %01111101       ;6
                dc.b    %00000111       ;7
                dc.b    %01111111       ;8
                dc.b    %01101111       ;9
                dc.b    %01110111       ;A
                dc.b    %01111100       ;b
                dc.b    %01011000       ;c
                dc.b    %01011110       ;d
                dc.b    %01111001       ;E
                dc.b    %01110001       ;F
                dc.b    %01101111       ;g
                dc.b    %01110110       ;H
                dc.b    %00000110       ;I
                dc.b    %00011110       ;J
                dc.b    %01000000       ;k (pendiente)
                dc.b    %00111000       ;L
                dc.b    %00110111       ;M
                dc.b    %01010100       ;n
                dc.b    %01011100       ;o
                dc.b    %01110011       ;P
                dc.b    %01100111       ;q
                dc.b    %01010000       ;r
                dc.b    %01101101       ;S
                dc.b    %01111000       ;t
                dc.b    %00011100       ;u
                dc.b    %01000000       ;v (pendiente)
                dc.b    %01000000       ;w (pendiente)
                dc.b    %01000000       ;x (pendiente)
                dc.b    %01101110       ;y
                dc.b    %01011011       ;Z

                ELSE                                           ;Si no...
Display         ds.w    4
Blanco          equ     $FF
Tab7Seg         dc.b    %00000011       ;0
                dc.b    %10011111       ;1
                dc.b    %00100101       ;2
                dc.b    %00001101       ;3
                dc.b    %10011001       ;4
                dc.b    %01001001       ;5
                dc.b    %01000001       ;6
                dc.b    %00011111       ;7
                dc.b    %00000001       ;8
                dc.b    %00001001       ;9
                dc.b    %00010001       ;A       
                dc.b    %11000001       ;b
                dc.b    %01100011       ;C
                dc.b    %10000101       ;d
                dc.b    %01100001       ;E
                dc.b    %01110001       ;F
                dc.b    %01000011       ;G
                dc.b    %10010001       ;H
                dc.b    %10011111       ;I
                dc.b    %10001111       ;J
                dc.b    %11111101       ;k (pendiente)
                dc.b    %11100011       ;L
                dc.b    %00010011       ;m 
                dc.b    %11010101       ;n
                dc.b    %11000101       ;o
                dc.b    %00110001       ;P
                dc.b    %11111101       ;q (pendiente)
                dc.b    %11110101       ;r
                dc.b    %01001001       ;S
                dc.b    %11100001       ;t
                dc.b    %10000011       ;U
                dc.b    %11111101       ;v (pendiente)
                dc.b    %11111101       ;w (pendiente)
                dc.b    %11111101       ;x (pendiente)    
                dc.b    %10001001       ;y
                dc.b    %11111101       ;z (pendiente)
                dc.b    %11111111       ;[ ]
                dc.b    %11111101       ;# 
                ENDIF


;-------------------------------------------------------------------------------------------
;dspInicializa
;
;Inicializa el Display
;-------------------------------------------------------------------------------------------

_dspInicializa  move.b  #$FF,VIA2_DDRA          ;Puerto A de la VIA2 en modo salida
                or.b    #$0F,VIA2_DDRB          ;4 bits menos significativos del puerto B de la VIA2 en modo salida
                rts

;-------------------------------------------------------------------------------------------
;dspRefresca
;
;Implementa Display para el microinstructor
;-------------------------------------------------------------------------------------------

_dspRefresca    movem.l	d0-d1/a0, -(sp)         ;Apila d0, d1 y a0
	          move.l	#Display, a0            ;a0 = Display
                move.b	FlagRef, d0             ;d0 = FlagRef
                move.b	d0, d1                  ;d1 = FlagRef
   	          or.b	#$0F, VIA2_ORB          ;Apaga display

                ;Algoritmo del profesor para obtener display a encender	
	          asl.b	#1, d0                  ;d0 = 2*FlagRef
                neg.b	d0                      ;d0 = -2*FlagRef        
                ext.w   d0		            ;Extiende signo para evitar desbordamiento
                move.b  7(a0,d0.w), VIA2_ORA    ;VIA2_ORA = Display+7 - 2*FlagRef
	          bclr	d1, VIA2_ORB            ;Habilita bit correspondiente
                add.b   #1, d1                  ;Incrementa variable
                and.b   #%11, d1                ;d1>4? Empezar desde 0
                move.b  d1, FlagRef
	          movem.l	(sp)+, d1-d0/a0         ;Desapila d0, d1 y a0
 	          rts     
                
;-------------------------------------------------------------------------------------------
;dspPinta
;
;Desplaza dígitos y pinta en el Display de la derecha
;-------------------------------------------------------------------------------------------

_dspPinta       move.w  4(sp),d0
                move.w  d0,-(sp)
                bsr	_ato7seg                ;Obtiene dígito en 7 segmentos
                add.l	#2,sp
                cmp.l   #ERROR, d0
                beq     dspPintaFin
                move.b  Display+3, Display+1    ;Desplaza dígitos del Display a la izquierda
                move.b  Display+5, Display+3    
                move.b  Display+7, Display+5
                move.b  d0, Display+7           ;Escribe dígito introducido a la derecha
dspPintaFin     rts


;-------------------------------------------------------------------------------------------
;dspBorra
;
;Borra sólo un Display
;-------------------------------------------------------------------------------------------

_dspBorra	    move.b	Display+5, Display+7    ;Desplaza dígitos del Display a la derecha
		    move.b	Display+3, Display+5
		    move.b	Display+1, Display+3
		    move.b	#Blanco, Display+1      ;Borra último dígito
                rts

;-------------------------------------------------------------------------------------------
;dspBorraTodo
;
;Borra todo el Display
;-------------------------------------------------------------------------------------------

_dspBorraTodo   move.b	#Blanco, Display+1      ;Borra todo el Display
	          move.b	#Blanco, Display+3
	          move.b	#Blanco, Display+5
		    move.b	#Blanco, Display+7
                rts

;-------------------------------------------------------------------------------------------
;ato7seg
;
;Convierte caracter ASCII en código 7 segmentos. (Sólo Números, Letras, Espacio y #)
;-------------------------------------------------------------------------------------------


_ato7seg        move.w  4(sp),d0                ;Obtiene caracter ASCII

                ;Descarta errores de caracteres distintos a los buscados
                cmp.b   #' ',d0                 ;Caracter = Espacio?
                beq     atoEspacio              ;...Sí. Saltar
                cmp.b   #'#',d0                 ;...No. Y Caracter = Almohadilla?
                beq     atoAlmohadilla          ;...Sí. Saltar
                cmp.b   #'0',d0                 ;...No. Y Caracter < '0'?
                blt     atoError                ;...Sí. Entonces no es ningún otro caracter que interese.
                cmp.b   #'9',d0                 ;...No. Y Caracter > '9'?

                ;Es un número por descarte
                bgt     atoMayus                ;...Sí. Puede ser mayúscula o minúscula
                sub.w   #'0',d0                 ;...No. Entonces es un número

                ;Obtiene caracter mediante Tab7Seg
atoFin          lea     Tab7Seg,a0              ;Indexa Tab7Seg
                add.w   d0,a0                   ;Pasa posición dentro de la tabla
                move.b  (a0),d0                 ;Obtiene caracter correspondiente
                 
atoVolver       rts

atoError        move.l  #ERROR,d0               ;Devuelve $FFFF como Error            
                bra atoVolver

atoEspacio      move.b  #36,d0                  ;Incremento correspondiente en Tab7Seg
                bra     atoFin

atoAlmohadilla  move.b  #37, d0                 ;Incremento correspondiente en Tab7Seg
                bra     atoFin


atoMayus        cmp.b   #'A', d0                ;Caracter < 'A'?
                blt     atoError                ;...Sí. Entonces no es un caracter buscado
                cmp.b   #'Z', d0                ;...No. Y Caracter > 'Z'
                bgt     atoMinus                ;...Sí. Puede ser minúscula. Comprobar
                sub.b   #'A', d0                ;...No. Entonces es mayúscula, calcula letra exacta
                add.b   #10, d0                 ;Desplazamiento necesario para Tab7Seg (Los 10 primeros son números)
                bra     atoFin


atoMinus        cmp.b   #'a', d0                ;Caracter < 'a'?
                blt     atoError                ;...Sí. Entonces no es un caracter buscado
                cmp.b   #'z', d0                ;...No. Y Caracter > 'z'?
                bgt     atoError                ;...Sí. Entonces no es un caracter buscado
                sub.b   #'a', d0                
                add.b   #10, d0
                bra     atoFin
