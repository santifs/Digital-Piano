;**************************************************************************
;************************** FICHERO CABECERA CON LAS DEFINICIONES *********
;************************** Versión v1.1                          *********
;**************************************************************************
; v1.0 14/10/04
; v1.1 03/12/15 Añadido código para prevenir la inclusión múltiple


;************** Tabla de pseudovectores TM-683 *****************
            ifndef   TM683_INC
TM683_INC   equ     1

PV_ILLEGAL  EQU     $20002
PV_DIV0     EQU     $20008
PV_CHK      EQU     $2000E
PV_TRAPV    EQU     $20014
PV_PRIVIO   EQU     $2001A
PV_TRAZA    EQU     $20020
PV_EMU1010  EQU     $20026
PV_EMU1111  EQU     $2002C
PV_AUTOV1   EQU     $20032
PV_AUTOV2   EQU     $20038
PV_AUTOV3   EQU     $2003E
PV_AUTOV4   EQU     $20044
PV_AUTOV5   EQU     $2004A
PV_AUTOV6   EQU     $20050
PV_AUTOV7   EQU     $20056
PV_TRAP6    EQU     $2005C
PV_TRAP7    EQU     $20062
PV_TRAP8    EQU     $20068
PV_TRAP9    EQU     $2006E
PV_TRAPA    EQU     $20074
PV_TRAPB    EQU     $2007A
PV_TRAPC    EQU     $20080
PV_TRAPD    EQU     $20086
PV_TRAPE    EQU     $2008C
PV_TRAPF    EQU     $20092
PV_US1      EQU     $20098
PV_US2      EQU     $2009E
PV_US3      EQU     $200A4
PV_US4      EQU     $200AA
PV_US5      EQU     $200B0
PV_US6      EQU     $200B6
PV_US7      EQU     $200BC
PV_US8      EQU     $200C2
PV_US9      EQU     $200C8
PV_US10     EQU     $200CE
PV_US11     EQU     $200D4
PV_US12     EQU     $200DA
PV_US13     EQU     $200E0
PV_US14     EQU     $200E6
PV_US15     EQU     $200EC
PV_US16     EQU     $200F2

;************** Dirección de inicio en el microinstructor ******* 
DIR_INICIAL  EQU   $021100


;***************  VIA1 ************************************
;Direcciones que ocupan los diferentes registros de la VIA1 
 
VIA1_ORB  EQU $60001
VIA1_IRB  EQU $60001
VIA1_ORA  EQU $60003
VIA1_IRA EQU $60003
VIA1_DDRB EQU $60005
VIA1_DDRA EQU $60007
VIA1_T1CL EQU $60009
VIA1_T1CH EQU $6000B
VIA1_T1LL EQU $6000D
VIA1_T1LH EQU $6000F
VIA1_T2LL EQU $60011
VIA1_T2CL EQU $60011
VIA1_T2CH EQU $60013
VIA1_SR   EQU $60015
VIA1_ACR  EQU $60017
VIA1_PCR  EQU $60019
VIA1_IFR  EQU $6001B
VIA1_IER  EQU $6001D
       

;***************  VIA2 ************************************
;Direcciones que ocupan los diferentes registros de la VIA2 
 
VIA2_ORB  EQU $60021
VIA2_IRB  EQU $60021
VIA2_ORA  EQU $60023
VIA2_IRA  EQU $60023
VIA2_DDRB EQU $60025
VIA2_DDRA EQU $60027
VIA2_T1CL EQU $60029
VIA2_T1CH EQU $6002B
VIA2_T1LL EQU $6002D
VIA2_T1LH EQU $6002F
VIA2_T2LL EQU $60031
VIA2_T2CL EQU $60031
VIA2_T2CH EQU $60033
VIA2_SR   EQU $60035
VIA2_ACR  EQU $60037
VIA2_PCR  EQU $60039
VIA2_IFR  EQU $6003B
VIA2_IER  EQU $6003D

;*************** DUART  *************************************
;Direcciones que ocupan los diferentes registros de la DUART
;en la placa TM-683

DUART_MRxA      EQU $60041
;DUART_MR1A      EQU $60041
;DUART_MR2A      EQU $60041
DUART_SRA       EQU $60043
DUART_CSRA      EQU $60043
DUART_BRGT      EQU $60045
DUART_CRA       EQU $60045
DUART_RHRA      EQU $60047
DUART_THRA      EQU $60047
DUART_IPCR      EQU $60049
DUART_ACR       EQU $60049
DUART_ISR       EQU $6004B
DUART_IMR       EQU $6004B
DUART_CTU       EQU $6004D
DUART_CRUR      EQU $6004D
DUART_CTL       EQU $6004F
DUART_CTLR      EQU $6004F
DUART_MR1B      EQU $60051
DUART_MR2B      EQU $60051
DUART_SRB       EQU $60053
DUART_CSRB      EQU $60053
DUART_1X16X     EQU $60055
DUART_CRB       EQU $60055
DUART_RHRB      EQU $60057
DUART_THRB      EQU $60057
DUART_IVR       EQU $60059
DUART_IP        EQU $6005B
DUART_OPCR      EQU $6005B
DUART_STARTCC   EQU $6005D
DUART_SOPBC     EQU $6005D
DUART_STOPCC    EQU $6005F
DUART_ROPBC     EQU $6005F 


                endif