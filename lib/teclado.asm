;-----------------------------------------------------------------------------------------------------
;Fernández Scagliusi, Santiago
;Grupo: L4
;Trabajo: Piano
;
;
;Teclado.asm
;
;Contiene las rutinas de gestión del teclado
;-----------------------------------------------------------------------------------------------------

                include TM683.inc

FVIA            equ     800000                  ;en Hz
FTECLA          equ     20                      ;en Hz (Ttecla = tiempo de rebote = 50ms)
NTECLA          equ     FVIA/FTECLA-2
ETX             equ     3                       ;ASCII fin de texto

;-----------------------------------------------------------------------------------------------------
;IniTeclado
;
;Inicialización del teclado
;-----------------------------------------------------------------------------------------------------

_IniTeclado     move.b  #$0F, VIA1_DDRA         ;Puerto A de VIA1: 4LSBs = salidas; 4MSBs = entradas         
                move.l  #IntVIA1, PV_AUTOV2     ;Engancha autovector 2
                and     #$F8FF, SR              ;Baja máscara de interrupcion
                or.b    #1, VIA1_PCR            ;CA1 de VIA1 sensible a flanco de subida
                bclr    #5, VIA1_ACR            ;T2 de VIA1 modo monoestable
                bset	#6, VIA1_ACR            ;T1 de VIA1 modo aestable
                move.b  #$82, VIA1_IER    ;Habilita interrupción de CA1
                move.b  #$20, VIA1_IER    ;Deshabilita interrupción de T2
                or.b    #$0F, VIA1_ORA          ;Activa columnas
                rts

;----------------------------------------------------------------------------------------------------
;IntVIA1
;
;Determina la fuente de la interrupción inspeccionando el IFR    
;----------------------------------------------------------------------------------------------------

IntVIA1         btst    #1, VIA1_IFR            ;Interrupción causada por CA1?
                beq     NoCA1                   ;...No. Comprobar si es por T2
                bsr     _TeclaPulsada           ;...Sí. Llamar a TeclaPulsada
NoCA1           btst    #5, VIA1_IFR            ;Interrupción causada por T2?
                beq     IntVIA1Fin              ;...No. Finalizar
                bsr     _IdTecla                ;...Sí. Llamar a IdTecla               
IntVIA1Fin      rte

;----------------------------------------------------------------------------------------------------
;TeclaPulsada
;
;Programa el T2 de la VIA1 para que genere una interrupción
;después del tiempo de rebote (50 ms)    
;----------------------------------------------------------------------------------------------------

_TeclaPulsada   bchg    #0, VIA1_PCR            ;Cambia sensibilidad de flanco de CA1
                move.b  #$02, VIA1_IFR          ;Limpia IRQ CA1
                move.b  #$02, VIA1_IER          ;Desactiva IRQ CA1
                move.b  #NTECLA, VIA1_T2LL        
                move.b  #NTECLA>>8, VIA1_T2CH   ;Inicia cuenta
                move.b  #$A0, VIA1_IER          ;Habilita IRQ T2
                rts

;-----------------------------------------------------------------------------------------------------
;IdTecla
;
;Identifica la tecla pulsada con el primer método explicado en la documentación del TM683.
;Es decir, inicialmente se activa una columna y se lee la información de filas (nibble alto del puerto)
;para saber si alguna de las teclas de la primera columna se encuentra pulsada.
;Después el proceso se repite para el resto de las columnas. En el momento en el que el valor del nibble
;alto sea distinto de cero se puede asegurar que la tecla correspondiente a la columna que se ha activado
;y a la fila cuyo bit es distinto de cero está pulsada.                                                                                                                               
;-----------------------------------------------------------------------------------------------------

_IdTecla        movem.l d0-d4/a0,-(sp)          ;Apila registros a usar

                move.b  #$20,VIA1_IER           ;Deshabilita IRQ 
                clr.w   d0                      ;Limpia registros a usar
                clr.w   d1                  
                clr.w   d2
                clr.w   d3
                clr.w   d4 

                btst    #0,VIA1_PCR             ;CA1 = Flanco de bajada? (Recordar que se cambió la sensibilidad de flanco)
                bne     TeclaSoltada            ;...Sí. Salta a TeclaSoltada                     
                
                ;Barre columnas y detecta fila
                move.b  #3,d3                   ;d3=bit de la columna a comprobar
IdBucle         clr.l   d2                      ;Limpia fila leída
                lea     TabFila,a0              ;Indexa TabFila       
                and.b   #$F0,VIA1_ORA           ;Desactiva columnas
                bset    d3,VIA1_ORA             ;Activa columna a revisar
                move.b  VIA1_IRA,d2             ;d2 = Fila leída
                and.b   #$F0,d2                 ;Se queda solo con las filas
                lsr.b   #4,d2                   ;Pasa valor a nibble bajo
                bne     IdFila                  ;d2 = 0? ...No. Entonces hay tecla pulsada. Identificarla

                ;Pasa a siguiente columna mediante d3
SigColumna      sub.b   #1,d3                   ;...Sí. NO hay tecla pulsada. Pasar a siguiente columna
                bmi     IdTeclaFin              ;d2 < 0?...Sí. Revisadas todas las columnas. No hay tecla pulsada.
                bra     IdBucle                 ;...No. Barre siguiente columna

                ;Identifica fila con tecla pulsada
IdFila          tst.b   d1                      ;Ninguna tecla leída todavía?
                bne     IdError                 ;...No. Ya hay tecla guardada, salta a IdTeclaError
                move.b  #1,d1                   ;...Sí. Seguimos, d4 = 1
                add.l   d2,a0                   ;Identifica en qué fila está la tecla pulsada              
                move.b  (a0),d4                 ;Obtiene fila de la tecla pulsada desde TabFila                       ;
                bmi     IdError                 ;d3 = -1?...Sí. Hay varias teclas pulsadas, salta a IdTeclaError
                cmp.b   #4,d4                   ;Fila = 4? (Es decir, ninguna tecla pulsada)
                beq     SigColumna              ;...Sí. Revisar siguiente columna

                ;Identifica tecla pulsada
                lsl.b   #2,d4                   ;Desplaza filas a nibble alto 
                or.b    d3,d4                   ;Mete las columnas en nibble bajo
                lea     TabTeclas,a0            ;Indexa TabTeclas
                add.l   d4,a0                   ;Obtiene el código ASCII de la tecla pulsada
                move.b  (a0),d0                 ;Mueve dicho código a d1
                bra     SigColumna              ;Revisa las columnas restantes por si hay también hay pulsada una tecla de otra columna

IdError         move.b  #0,d0                   ;0 = Error

                ;Envía tecla identificada al buffer de teclado
IdTeclaFin      move.w  d0,-(sp)                
                pea     _BufferTeclado           
                bsr     _colaInserta            
                add.l   #6,sp                   ;Reestablece la pila
                move.b  #$20, VIA1_IER          ;Desactiva interrupción T2
                move.b  #$02, VIA1_IFR          ;Limpia interrupción de CA1
                move.b  #$20, VIA1_IFR          ;Limpia interrupción T2
                or.b    #$0F, VIA1_ORA          ;Activa columnas teclado		
                move.b  #$82, VIA1_IER          ;Activa interrupción de CA1
                movem.l (sp)+,d0-d4/a0                 
                rts

TeclaSoltada    move    #ETX,d0                   ;Se ha soltado la tecla, pasar ETX = Fin de texto
                bra     IdTeclaFin

;------------------------------------------------------------------------------------------------
;TabTeclas                                                            
;                                                                     
;Asigna código ASCII a cada tecla                                                                                       
;------------------------------------------------------------------------------------------------

TabTeclas       dc.b    '+'                     ;Tecla 0
                dc.b    'D'                     ;Tecla 1
                dc.b    'C'             	      ;Tecla 2
                dc.b     27             	      ;Tecla 3
                dc.b    '-'             	      ;Tecla 4
                dc.b    'e'             	      ;Tecla 5
                dc.b    'd'                     ;Tecla 6
                dc.b    'c'         	      ;Tecla 7
                dc.b    'A'                     ;Tecla 8
                dc.b    'G'            	      ;Tecla 9
                dc.b    'F'            	      ;Tecla 10
                dc.b     10            	      ;Tecla 11
                dc.b    'b'            	      ;Tecla 12
                dc.b    'a'             	      ;Tecla 13
                dc.b    'g'                     ;Tecla 14
                dc.b    'f'             	      ;Tecla 15

;------------------------------------------------------------------------------------------------
;TabFila                                                               
;                                                                    
;Identifica tecla pulsada según código asociado.
;4  = Ninguna tecla pulsada.
;-1 = Error. Más de una tecla pulsada.                                                                    
;------------------------------------------------------------------------------------------------

TabFila         dc.b     4                      ;0000
                dc.b     0                      ;0001
                dc.b     1                      ;0010   
                dc.b    -1                      ;0011
                dc.b     2                      ;0100
                dc.b    -1                      ;0101
                dc.b    -1                      ;0110
                dc.b    -1                      ;0111
                dc.b     3                      ;1000
                dc.b    -1                      ;1001
                dc.b    -1                      ;1010
                dc.b    -1                      ;1011
                dc.b    -1                      ;1100
                dc.b    -1                      ;1101
                dc.b    -1                      ;1110
                dc.b    -1                      ;1111

