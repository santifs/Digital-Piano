;-----------------------------------------------------------------------------------------------------
;Fernández Scagliusi, Santiago
;Grupo: L4
;Trabajo: Piano
;
;
;Timer.asm
;
;Gestión de la temporización
;-----------------------------------------------------------------------------------------------------

                IFEQ    HARDWARE-SIMU
SystemTimer     equ     $E040           ;Frecuencia en Windows XP
                ELSE
SystemTimer     dc.l    0
                ENDIF

FST             equ     200
T1N             equ     FVIA/FST - 2


_Time           move.l  SystemTimer,d0  
                rts


_IniTime        move.l  #_IntVIA2,PV_AUTOV3     ;Captura vector interrupción
                and     #$F8FF,SR               ;Poner a 0 la máscara de interrupción
                bclr    #7,VIA2_ACR             ;Desactiva la salida hardware
                bset    #6,VIA2_ACR             ;Modo aestable
                move.b  #T1N,VIA2_T1LL
                move.b  #T1N>>8,VIA2_T1CH
                move.b  #$C0,VIA2_IER           ;Habilita interrupción del T1
                rts

_IntVIA2        add.l   #1,SystemTimer
                move.b  #$40,VIA2_IFR           ;Limpia todas las peticiones de interrupción
                jsr     _dspRefresca
                rte