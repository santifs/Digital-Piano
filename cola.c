#include "cola.h"

cola BufferTeclado;

/*---------------------------------------------------------------------------------------------------------
 * colaExtrae
 *
 * Extrae un elemento de la cola cuyo puntero se pasa como par�metro. En caso de error (cola vac�a), devuelve
 * -1. En caso contrario devuelve el elemento extra�do.
 *--------------------------------------------------------------------------------------------------------*/
int colaExtrae (cola *pc)
{
  int temp;

  if (colaVacia (pc))
    return -1;
  temp = pc->cola[pc->inicio++];
  if (pc->inicio >= TAMCOLA)
    pc->inicio = 0;
  return temp;
}


/*---------------------------------------------------------------------------------------------------------
 * colaLlena
 *
 * Devuelve un n�mero no nulo si la cola cuyo puntero se pasa como par�metro est� llena. 0 en caso contario.
 *--------------------------------------------------------------------------------------------------------*/
int colaLlena (cola *pc)
{
  int fin;
  
  fin = pc->fin+1;
  if (fin >= TAMCOLA)
    fin = 0;
  return (fin == pc->inicio);
}


/*---------------------------------------------------------------------------------------------------------
 * colaInserta
 *
 * Inserta un elemento en la cola cuyo puntero se pasa como par�metro. En caso de error (cola llena), devuelve
 * -1. En caso contrario devuelve 0.
 *--------------------------------------------------------------------------------------------------------*/
int colaInserta (cola *pc, char c)
{
  int fin;
  
  fin = pc->fin+1;
  if (fin >= TAMCOLA)
    fin = 0;
  if (fin == pc->inicio)
    return -1;                  // Cola llena
  pc->cola[pc->fin] = c;
  pc->fin = fin;
  return 0;
}


/*---------------------------------------------------------------------------------------------------------
 * colaVacia
 *
 * Devuelve un n�mero no nulo si la cola cuyo puntero se pasa como par�metro est� vac�a. 0 en caso contario.
 *--------------------------------------------------------------------------------------------------------*/
int colaVacia (cola *pc)
{
  int temp;

  return (pc->fin == pc->inicio);
}
