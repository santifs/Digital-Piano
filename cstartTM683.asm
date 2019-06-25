; CSTART.ASM  -  C startup-code for SIM68K

;Constantes dependientes de hardware
SIMU            equ     %000    ;Simulador (E/S por ventana virtual)
TM683           equ     %100    ;TM-683 (E/S por puerto serie)
DTEINPUT        equ     %110    ;TM-683 más placa periféricos del DTE (E por teclado placa y S por puerto serie)
DTEOUTPUT       equ     %101    ;TM-683 más placa periféricos del DTE (E por puerto serie  y S por display 7 seg)
DTEINOUT        equ     %111    ;TM-683 más placa periféricos del DTE (E por teclado placa y S por display 7 seg)
 
HARDWARE        equ    DTEINOUT    ;Poner aquí para qué hardware se compilará el proyecto 
;SIMUTM683       equ     1       ;Descomentar esta línea si se va a usar el Emulador del TM683 en el simulador

lomem     equ     $02106A          ; Lowest user RAM location
himem     equ     $03F800          ; Highest memory + 1
stklen    equ     $040000          ; Default stacksize
NULL      equ     0


                ;Si estamos simulando la placa de periféricos del DTE, capturar los autovectores para redirigirlos a los pseudovetores, como hace el TM683
                ifdef    SIMUTM683
                org     25*4
                dc.l    RedirectorIRQ1
                dc.l    RedirectorIRQ2
                dc.l    RedirectorIRQ3
                dc.l    RedirectorIRQ4
                dc.l    RedirectorIRQ5
                dc.l    RedirectorIRQ6
                dc.l    RedirectorIRQ7
                endif

          org     lomem
program:
          move.w   #-1,__ungetbuf
          clr.l    __allocp
          move.l   #freemem,__heap
          jsr      _main
          bra      __exit
_exit:                             ; exit() function
          link    A6,#0
          move.w  8(A6),D0
          unlk    A6
          add.l   #10,A7           ; pop arg & r/a from stack
          bra     __exit


          IFEQ    HARDWARE-SIMU
;------------------------------ Servicios básicos de E/S redirigidos a los servicios del simulador
__exit:   trap     #15                  ; Salir: Llamada al sistema del Simulador
          dc.w     0
          bra     program               ; restart
__putch:  link    A6,#0                 ; Basic character output routine
          move.w  8(A6),D0
          trap    #15
          dc.w    1
          unlk    A6
          rts
__getch:  trap    #15                   ; Basic character input routine
          dc.w    3
          ext.w   D0
          rts
__kbhit:  trap    #15
          dc.w    4
          sne     D0
          rts
          ELSE
;------------------------------ Servicios básicos de E/S redirigidos a los servicios del microinstructor
__exit:   trap    #5                    ; Salir: Llamada al sistema del TM-683 

;------------------------------ Servcio de salida
          IFEQ    HARDWARE & %001
;------------------------------ por puerto serie
__putch:  move.w  4(sp),d0              ; Basic character output routine
          ext.l   d0
          move.l  d0, -(sp)
          move.l  #24, d0               ;putchar servicio 24 de TM683
          trap    #0
          add.l   #4, sp
          rts
          ELSE
;------------------------------ por display de 7 segmentos
__putch:  jmp     _dspPinta             ; Redirigir a dspPinta. Ojo, capacidad limitada de impresión
          ENDIF

;------------------------------ Servcio de entrada
          IFEQ    HARDWARE & %010
;------------------------------ por puerto serie
__getch:  move.l  #23, d0               ; Basic character input routine
          trap    #0                    ; Servicio 23 de TM683 (por puerto serie)
          rts
__kbhit:  clr.w   d0                    ;La entrada es por puerto serie. No usar kbhit. Siempre falso
          rts
          ELSE
;------------------------------ por teclado matricial
__getch:  pea   _BufferTeclado
          bsr   _colaExtrae
          add.l #4, sp
          tst.w d0
          bmi   __getch
          rts
__kbhit:  pea   _BufferTeclado
          bsr  _colaVacia
          add.l #4, sp
          tst.w d0
          seq   d0
          rts
          ENDIF

          ENDIF


        
__ungetbuf: 
          dc.w    0                ; ungetbuffer for stdio functions
__allocp:
          dc.l    0                ; start of allocation units
__heap:                             
          dc.l    0                ; pointers for malloc functions
__himem:
          dc.l    himem            ; highest memory location + 1
__stklen:
          dc.l    stklen           ; default stack size



                ifdef    SIMUTM683
Pseudovector1   equ     $20032  ;Dirección del Autovector 1 en la Pseudotabla de vectores del TM683
Pseudovector2   equ     Pseudovector1+6
Pseudovector3   equ     Pseudovector2+6
Pseudovector4   equ     Pseudovector3+6
Pseudovector5   equ     Pseudovector4+6
Pseudovector6   equ     Pseudovector5+6
Pseudovector7   equ     Pseudovector6+6


;------------------------------------------------------------------------------------------------------------------
; RedirectorIRQ                                                                                              v1.0
;
; Se engancha a los autovectores para simular la tabla de pseudovectores del TM683
;------------------------------------------------------------------------------------------------------------------
RedirectorIRQ1  tst.l   Pseudovector1
                beq     VectorNoIni
                move.l  Pseudovector1,-(sp)
                rts
RedirectorIRQ2  tst.l   Pseudovector2
                beq     VectorNoIni
                move.l  Pseudovector2,-(sp)
                rts
RedirectorIRQ3  tst.l   Pseudovector3
                beq     VectorNoIni
                move.l  Pseudovector3,-(sp)
                rts
RedirectorIRQ4  tst.l   Pseudovector4
                beq     VectorNoIni
                move.l  Pseudovector4,-(sp)
                rts
RedirectorIRQ5  tst.l   Pseudovector5
                beq     VectorNoIni
                move.l  Pseudovector5,-(sp)
                rts
RedirectorIRQ6  tst.l   Pseudovector6
                beq     VectorNoIni
                move.l  Pseudovector6,-(sp)
                rts
RedirectorIRQ7  tst.l   Pseudovector7
                beq     VectorNoIni
                move.l  Pseudovector7,-(sp)
                rts
VectorNoIni     lea     MsjVectorNoIni, a0
                trap    #15                     ;Imprimir mensaje
                dc.w    7
                trap    #15                     ;Salir del programa
                dc.w 0

MsjVectorNoIni  dc.b    'Pseudovector no inicializado', 0
                endif
