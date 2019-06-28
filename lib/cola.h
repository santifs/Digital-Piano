//...................................................
// cola.h
//...................................................

#ifndef _COLA_H_
#define _COLA_H_

/*
Colas. El objeto cola se compone de TAMCOLA+2 bytes. El primero guarda el índice al Inicio
de la cola y el segundo el índice al Final. Los TAMCOLA restantes son la cola en sí.
Puesto que los índice son de tamaño byte, las colas pueden ser de hasta 256 bytes.
*/

#define TAMCOLA (16)

typedef struct
{
  unsigned char inicio;
  unsigned char fin;
  unsigned char cola[TAMCOLA];
} cola;
  
int colaExtrae  (cola *pc);
int colaLlena   (cola *pc);
int colaInserta (cola *pc, char c);
int colaVacia   (cola *pc);

#endif
