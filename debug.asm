;------------------------------------------------------------------------------------------------------------------------
; void IniDebug (void)												v1.1
;
; Configura los puertos de las VIAS para que quede encendido el primer LED y se visualice un guión en el primer dígito
; del display de 7 segmentos.
;------------------------------------------------------------------------------------------------------------------------
_IniDebug       move.b  #$FF, VIA1_DDRB         ;Puerto de LEDS como salida
                move.b  #1, VIA1_ORB            ;Activar el primer LED
                move.b  #$FF, VIA2_DDRA         ;Puerto de datos del display de 7 segmentos como salida
                move.b  #$FF, VIA2_DDRB         ;4LSB del puerto de control del display de 7 segmentos como salida
                move.b  #$FD, VIA2_ORA          ;Pintar un guión en el display de 7 segmentos
                move.b  #$EE, VIA2_ORB          ;Encender dígito de la derecha
                rts

;------------------------------------------------------------------------------------------------------------------------
; void DebugLeds (void)
;
; Desplaza los leds. OJO: Conserva todos los registros
;------------------------------------------------------------------------------------------------------------------------
_DebugLeds      move.l  d0, -(sp)
                move.b  VIA1_IRB, d0
                rol.b   #1, d0
                move.b  d0, VIA1_ORB
                move.l  (sp)+, d0
                rts

;------------------------------------------------------------------------------------------------------------------------
; void DebugDisplay (void)
;
; Desplaza el digito encendido. OJO: Conserva todos los registros
;------------------------------------------------------------------------------------------------------------------------
_DebugDisplay   move.l  d0, -(sp)
                move.b  VIA2_IRB, d0
                rol.b   #1, d0
                move.b  d0, VIA2_ORB
                move.l  (sp)+, d0
                rts

