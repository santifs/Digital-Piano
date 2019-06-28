; C:\SBM\GARCIAMARTINEZRUBEN\TRABAJO\COLA.C - Compiled by CC68K  Version 4.11 (c) 1991-2001  P.J.Fondse
; #include "cola.h"
; cola BufferTeclado;
_BufferTeclado:
       ds.b      18
; /*---------------------------------------------------------------------------------------------------------
; * colaExtrae
; *
; * Extrae un elemento de la cola cuyo puntero se pasa como parámetro. En caso de error (cola vacía), devuelve
; * -1. En caso contrario devuelve el elemento extraído.
; *--------------------------------------------------------------------------------------------------------*/
; int colaExtrae (cola *pc)
; {
 
_colaExtrae:
       link      A6,#-2
       move.l    A2,-(A7)
       move.l    8(A6),A2
; int temp;
; if (colaVacia (pc))
       move.l    A2,-(A7)
       jsr       _colaVacia
       addq.w    #4,A7
       tst.w     D0
       beq       colaExtrae_1
; return -1;
       moveq     #-1,D0
       bra       colaExtrae_0
colaExtrae_1:
; temp = pc->cola[pc->inicio++];
       move.l    A2,A0
       add.l     #2,A0
       move.l    A2,A1
       add.w     #0,A1
       move.b    (A1),D0
       addq.b    #1,(A1)
       and.w     #255,D0
       add.w     D0,A0
       move.b    (A0),D0
       and.w     #255,D0
       move.w    D0,-2(A6)
; if (pc->inicio >= TAMCOLA)
       move.l    A2,A0
       add.w     #0,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #16,D0
       blt       colaExtrae_3
; pc->inicio = 0;
       move.l    A2,A0
       add.w     #0,A0
       clr.b     (A0)
colaExtrae_3:
; return temp;
       move.w    -2(A6),D0
colaExtrae_0:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; /*---------------------------------------------------------------------------------------------------------
; * colaLlena
; *
; * Devuelve un número no nulo si la cola cuyo puntero se pasa como parámetro está llena. 0 en caso contario.
; *--------------------------------------------------------------------------------------------------------*/
; int colaLlena (cola *pc)
; {
_colaLlena:
       link      A6,#-2
       move.l    D2,-(A7)
; int fin;
; fin = pc->fin+1;
       move.l    8(A6),A0
       add.w     #1,A0
       move.b    (A0),D0
       and.w     #255,D0
       addq.w    #1,D0
       move.w    D0,D2
; if (fin >= TAMCOLA)
       cmp.w     #16,D2
       blt       colaLlena_1
; fin = 0;
       moveq     #0,D2
colaLlena_1:
; return (fin == pc->inicio);
       move.l    8(A6),A0
       add.w     #0,A0
       move.b    (A0),D0
       and.w     #255,D0
       move.w    D2,D1
       cmp.w     D0,D1
       bne       colaLlena_3
       moveq     #1,D0
       bra.s     colaLlena_4
colaLlena_3:
       moveq     #0,D0
colaLlena_4:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; /*---------------------------------------------------------------------------------------------------------
; * colaInserta
; *
; * Inserta un elemento en la cola cuyo puntero se pasa como parámetro. En caso de error (cola llena), devuelve
; * -1. En caso contrario devuelve 0.
; *--------------------------------------------------------------------------------------------------------*/
; int colaInserta (cola *pc, char c)
; {
_colaInserta:
       link      A6,#-2
       movem.l   D2/A2,-(A7)
       move.l    8(A6),A2
; int fin;
; fin = pc->fin+1;
       move.l    A2,A0
       add.w     #1,A0
       move.b    (A0),D0
       and.w     #255,D0
       addq.w    #1,D0
       move.w    D0,D2
; if (fin >= TAMCOLA)
       cmp.w     #16,D2
       blt       colaInserta_1
; fin = 0;
       moveq     #0,D2
colaInserta_1:
; if (fin == pc->inicio)
       move.l    A2,A0
       add.w     #0,A0
       move.b    (A0),D0
       and.w     #255,D0
       move.w    D2,D1
       cmp.w     D0,D1
       bne       colaInserta_3
; return -1;                  // Cola llena
       moveq     #-1,D0
       bra       colaInserta_0
colaInserta_3:
; pc->cola[pc->fin] = c;
       move.w    12(A6),D0
       move.l    A2,A0
       add.l     #2,A0
       move.l    A2,A1
       add.w     #1,A1
       move.b    (A1),D1
       and.w     #255,D1
       add.w     D1,A0
       move.b    D0,(A0)
; pc->fin = fin;
       move.w    D2,D0
       move.l    A2,A0
       add.w     #1,A0
       move.b    D0,(A0)
; return 0;
       moveq     #0,D0
colaInserta_0:
       movem.l   (A7)+,D2/A2
       unlk      A6
       rts
; }
; /*---------------------------------------------------------------------------------------------------------
; * colaVacia
; *
; * Devuelve un número no nulo si la cola cuyo puntero se pasa como parámetro está vacía. 0 en caso contario.
; *--------------------------------------------------------------------------------------------------------*/
; int colaVacia (cola *pc)
; {
_colaVacia:
       link      A6,#-2
; int temp;
; return (pc->fin == pc->inicio);
       move.l    8(A6),A0
       add.w     #1,A0
       move.l    8(A6),A1
       add.w     #0,A1
       move.b    (A0),D0
       cmp.b     (A1),D0
       bne       colaVacia_1
       moveq     #1,D0
       bra.s     colaVacia_2
colaVacia_1:
       moveq     #0,D0
colaVacia_2:
       and.w     #255,D0
       unlk      A6
       rts
