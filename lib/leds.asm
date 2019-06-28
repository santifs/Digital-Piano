;*******************************************************
;
;          SANTIAGO FERNÁNDEZ SCAGLIUSI
;
;Programa con las funciones de los Leds.
;Lee y escribe en los Leds.
;
;*******************************************************

;Parámetros dependientes del hardware
LEDS    equ   VIA1_ORB

_IniLeds        move.b    #$FF,VIA1_DDRB
                rts

_GetLeds        move.b  (Leds),d0
                rts

_SetLeds        move.w  4(sp),d0
                move.b  d0,Leds
                rts
