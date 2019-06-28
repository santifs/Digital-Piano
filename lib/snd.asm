;-----------------------------------------------------------------------------------------------------
;Fernández Scagliusi, Santiago
;Grupo: L4
;Trabajo: Piano
;
;
;SND.asm
;
;Gestión de Notas y Sonido
;-----------------------------------------------------------------------------------------------------

FDO             equ     1047    ;DO
FDOs            equ     1109    ;D0#
FRE             equ     1175    ;RE
FREs            equ     1244    ;RE#
FMI             equ     1318    ;MI
FFA             equ     1397    ;FA
FFAs            equ     1480    ;FA#
FSOL            equ     1568    ;SOL    
FSOLs           equ     1661    ;SOL#
FLA             equ     1760    ;LA
FLAs            equ     1865    ;LA#
FSI             equ     1975    ;SI 

TabNotas        dc.w    FVIA/(2*FDO)
                dc.w    FVIA/(2*FDOs)
                dc.w    FVIA/(2*FRE)
                dc.w    FVIA/(2*FREs)
                dc.w    FVIA/(2*FMI)
                dc.w    FVIA/(2*FFA)
                dc.w    FVIA/(2*FFAs)
                dc.w    FVIA/(2*FSOL)
                dc.w    FVIA/(2*FSOLs)
                dc.w    FVIA/(2*FLA)   
                dc.w    FVIA/(2*FLAs)
                dc.w    FVIA/(2*FSI)            

;---------------------------------------------------------------------------------------
;sndNota
;
;Identifica Nota y Octava y calcula su frecuencia
;---------------------------------------------------------------------------------------

_sndNota        move.w  4(sp),d0        ;Recupera octava         
                move.w  6(sp),d1        ;Recupera nota

                ;Descarta errores de octava y nota
                tst.w   d0              ;Octava=0?
                beq     Silencia        ;...Sí. Hay que desactivar salida Hardware de T1 para silenciar
                cmp.b   #4,d0           ;...No. Y Octava<4?
                blt     sndError        ;...Sí. Devolver Error
                cmp.b   #6,d0           ;...No. Y Octava>6?
                bgt     sndError        ;...Sí. Devolver Error
                cmp.b   #0,d1           ;...No. Y Nota<0?
                blt     sndError        ;...Sí. Devolver Error
                cmp.b   #11,d1          ;...No. Y Nota>11?
                bgt     sndError        ;...Sí. Devolver Error
                
                ;No hay error. Obtiene frecuencia y activa salida
                lea     TabNotas,a0     ;Indexa TabNotas
                lsl.w   #1,d1           ;Evita error de acceso impar
                move.w  0(a0,d1.w),d1   ;d1 = Frecuencia de nota (En la 6ª octava!!)
                bset    #6,VIA1_ACR     ;T1 modo aestable
                bset    #7,VIA1_ACR     ;T1 salida hardware
                
                ;Cambia frecuencia de la nota a octava correspondiente
                cmp.b   #5,d0           ;Octava=5?
                beq     Octava5         ;...Sí. Cambiar frecuencia de nota (dividir entre 2)
                cmp.b   #4,d0           ;...No. Y Octava=4?
                beq     Octava4         ;...Sí. Cambiar frecuencia de nota (dividir entre 4)
                
                ;Hace sonar mediante T1
Sonar           subi.b  #2,d1           ;Resta 2 a la frecuencia
                move.b  d1,VIA1_T1LL    
                asr.w   #8,d1           
                move.b  d1,VIA1_T1CH    ;Inicia cuenta
                clr.w   d0              ;Devuelve 0 = Todo correcto
                bra     sndFin

Octava5         lsl.w   #1,d1           ;divido entre 2 la frecuencia 
                bra     Sonar
Octava4         lsl.w   #2,d1           ;Divide entre 4 la frecuencia
                bra     Sonar

sndError        move.b  #-1,d0          ;Devuelve -1 = Error        
                bra     sndFin

Silencia        bclr    #7,VIA1_ACR    ;Desactiva salida hardware para silenciar

sndFin          rts     

