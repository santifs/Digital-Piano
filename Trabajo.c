/*-----------------------------------------------------------------------------------------------------
 * Fernández Scagliusi, Santiago
 * Grupo L4
 * Trabajo: Piano
 *
 * Reproduce las notas de 3 octavas completas por altavoz piezoeléctrico
 * Reproduce melodía memorizada (Intro de Los Simpsons). Hay otra melodía pero está deshabilitada
 * Gestiona interrupciones de pulsadores y los asocia a la tecla correspondiente
 *-----------------------------------------------------------------------------------------------------*/

/* Librerías */

#include <stdio.h>
#include "teclado.h"
#include "timer.h"
#include "display.h"
#include "snd.h"
#include "cola.h"

/* Constantes */

#define T 1600
#define Intro  10
#define Escape 27
#define ETX    3   

/* Funciones */

void Play (void);
void atoNota (char);
void PianoOFF(void);

/* Variables */

int Octava=4, ModoPlay=0;
char *partitura, c=0, Letra=0, Num=0;
static unsigned long ProxEjec=0xFFFFFFFF;

/*-----------------------------------------------------------------------------------------------------
 * main
 *
 * Gestiona los modos de reproducción del Piano (Melodía o Piano normal)
 *-----------------------------------------------------------------------------------------------------*/
 
void main(void)
{

  IniTeclado();
  IniTime();
  dspInicializa();
  dspBorraTodo();    
  
  while(c!=Escape)                   //Escape es la tecla de salida
  {
    if(ModoPlay==0)                  //Modo=Piano, mientras ModoPlay esté desactivado
    {
      c=getch();                     //Obtiene tecla pulsada       
      switch(c)                      //Cuál es la tecla?
      {
       case ETX:                     //Tecla soltada
         sndNota(0,0);               //Silencia
         dspBorraTodo();
         break;
       case Intro:                   //Intro activa Modo Play
         ModoPlay=1;
         dspBorraTodo();
         partitura="o5f4f6a4b4o6d5c4c5o5a4f4d5o4b5s8b5s8b5o5c4s4o4b5s8b5s8b5o5c5D4s5f5s9f5s9f5s9f5";    //Intro Simpsons
         //partitura="o5D4F4o6C4C6s5C5s6o5b5o6C5s6D5o5A4A4s6o5D4F4o6C4C6s5C5s6o5b5o6C5s6D5o5A4A4s6o5D4F4o6C4C6s5C5s6o5b5o6C5s6D5o5A4A4s6o5D4F4o6C4C6s5C5s6o5b5o6C5s6D5o5A4A4s6";  //Timbre atascado Simpsons
         ProxEjec=Time();
         break;
         
      default: atoNota(c);           //Cualquier otra = es una nota
      }
        
    }
    else
    {
      Play();                        //Si ModoPlay=1, reproduce melodía.
     
      if(kbhit())                    //Se evalúa SÓLO cuando se pulsa una tecla
      {
        c=getch();                   //Obtiene tecla
        if(c==Intro)                 //Tecla = Intro?...Sí, sale del Modo Play
        {
          PianoOFF();
        }
      }                              //...No, seguir reproduciendo melodía
    }
  }
   
  PianoOFF();                        //Si se pulsa Escape, se silencia y se termina el programa
             
}

/*-----------------------------------------------------------------------------------------------------
 * Play
 *
 * Reproduce melodía almacenada en la variable *partitura
 * Decodifica dicha partitura en Letras (Notas) y Números (Duración)
 *-----------------------------------------------------------------------------------------------------*/

void Play (void)
{
  char Duracion, TiempoNota;

  if (Time()>=ProxEjec)
  {
    ProxEjec=Time();
    Letra = *partitura++;
    Num = *partitura++;
    if ((Letra>'A' && Letra<'Z') || (Letra>'a' && Letra<'z') || (Num>'0' && Num<'9')||(Letra!=NULL || Num!=NULL))
    {
      if (Letra=='o')                //Cambiar octava?... Sí
      {
        if(Num>='4' && Num<='6')     //Octava correcta?...Sí, cambiar
        {
          Octava = Num-'0';
        }
        else
        {
          PianoOFF();                //...No, terminar programa
        }
      }
      else                           //Reproduce nota
      {
        Duracion = Num-'0';
        TiempoNota = T>>Duracion;    //Divide T entre duración
        ProxEjec += TiempoNota;      //Incrementa ProxEjec el tiempo correspondiente
        atoNota(Letra);              //Obtiene Nota a reproducir
      }
    }
     
    else
    {
      PianoOFF();                    //Nota/Octava/Tiempo incorrecto, termina programa
    }

  }

}

/*-----------------------------------------------------------------------------------------------------
 * PianoOFF
 *
 * Reinicializa las variables del programa
 *-----------------------------------------------------------------------------------------------------*/

void PianoOFF(void)                 //Limpia todas las variables y termina el programa
{
  sndNota(0,0);                     //Silencia
  ProxEjec=0xFFFFFFFF;         
  dspBorraTodo();                   //Limpia Display  
  ModoPlay=0;                       //Desactiva Modo Play
  Octava=4;                         //Pone Octava por defecto                                   
  Letra=0;                          //Limpia Letra y Num
  Num=0; 
}

/*-----------------------------------------------------------------------------------------------------
 * atoNota
 *
 * Convierte caracteres ASCII en notas musicales. Envía su frecuencia con sndNota
 *-----------------------------------------------------------------------------------------------------*/

void atoNota(char a)
{
  switch(a)
  {
    case '+':                        //Aumenta octava...
                    
       if (Octava==4)                //...mientras no sea la 6ª o mayor
       {
         Octava++;
         puts("Oc 5"); 
       }
       else if (Octava==5)          //Si no, indica que es la máxima octava
       {
         Octava++;
         puts("Oc 6");
       }
       else if (Octava==6)                        
       {
         puts("Oc 6");
       }
       break;
           
    case '-':                        //Disminuye octava...
       if (Octava==4)                //...mientras no sea la 6ª o mayor
       {
         puts("Oc 4"); 
       }
       else if (Octava==5)          //Si no, indica que es la máxima octava
       {
         Octava--;
         puts("Oc 4");
       }
       else if (Octava==6)                        
       {
         Octava--;
         puts("Oc 5");
       }
       break;
            
    case 's':                      //Silencia piano
      sndNota(0,0);
      dspBorraTodo();
      break;
 
    case 'c':                      //Do
      sndNota(Octava,0);
      puts("do  ");
      break;

     case 'C':                     //Do#
      sndNota(Octava,1);
      puts("do# ");
      break;

     case 'd':                     //Re
      sndNota(Octava,2);
      puts("re  ");
      break;

     case 'D':                     //Re#
      sndNota(Octava,3);
      puts("re# ");
      break;

     case 'e':                     //Mi
      sndNota(Octava,4);
      puts("mi  ");
      break;

     case 'f':                     //Fa
      sndNota(Octava,5);
      puts("fa  ");
      break;

     case 'F':                     //Fa#
      sndNota(Octava,6);
      puts("fa# ");
      break;

     case 'g':                     //Sol
      sndNota(Octava,7);
      puts("sol ");
      break;

     case 'G':                     //Sol#
      sndNota(Octava,8);
      puts("sol#");
      break;

     case 'a':                     //La
      sndNota(Octava,9);
      puts("la  ");
      break;

     case 'A':                     //La#
      sndNota(Octava,10);
      puts("la# ");
      break;
 
    case 'b':                      //Si
      sndNota(Octava,11);
      puts("si  ");
      break;
  }
}