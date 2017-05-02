/*  --------------------------------------
    rozbin Tcl pod tcc
    --------------------------------------

--> spis komend: patrz koniec pliku

--> kompilacja na win/tcc: e; tcl_cc q3.c

--> przenioslem rozbin fiber do j. C !
* uzywala ona elementow j. C++ wiec byly problemy przy przenoszeniu...
* kompiluje sie na win/tcc ORAZ lin/gcc

*/

//#include <stdio.h>
#include <stdlib.h>
#include <tcl.h>

#ifdef __WIN32__
#define DLL_EXPORT __declspec(dllexport)
#else
#define DLL_EXPORT /**/
#endif

// zwraca wersje Tcl-a
int WersjaCmd(
  ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]
) {
  int i, major, minor;
  Tcl_GetVersion(&major, &minor, NULL, NULL);

  char c[20];
  sprintf(c, "%i.%i", major, minor);
  Tcl_AppendElement(interp, c);
    // prymitywna metoda zwracania wyniku!

  return TCL_OK;
}

int SumaLiczbCmd(
  ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]
) {
  if (objc != 3) {
    Tcl_SetResult(interp, "musza byc 2 parametry typu int!!!", TCL_STATIC);
    return TCL_ERROR;
  }

  // Tcl -> C; przekszta³camy dane Tcl na dane C
  int arg1, arg2;
  if( Tcl_GetIntFromObj(interp, objv[1], &arg1)==TCL_ERROR ) return TCL_ERROR;
  if( Tcl_GetIntFromObj(interp, objv[2], &arg2)==TCL_ERROR ) return TCL_ERROR;

  int wynik; wynik= arg1+arg2; // wykonujemy operacjê w jêzyku C

  // C -> Tcl
  Tcl_Obj *w= Tcl_NewIntObj(wynik);

  Tcl_SetObjResult(interp, w);
  return TCL_OK;
}

// typ wewn. obiektu Tcl
int TypeCmd(
  ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]
) {
  int i;
  for( i=0; i<objc; i++ ) {
    if( objv[i]->typePtr!=NULL ) {
      Tcl_AppendElement(interp, objv[i]->typePtr->name);
    } else {
      Tcl_AppendElement(interp, "?");
    }
    char c[10]; sprintf(c,"%d",objv[i]->refCount);
    Tcl_AppendElement(interp, c);
  }
  return TCL_OK;
}

// --- fiber --------------------------------------------------------

#include <string.h>
#include <stdio.h>
#include <malloc.h>

#ifdef __WIN32__
#include <windows.h>
#else
#include <ucontext.h>
#endif

#pragma hdrstop

#define BLAD_WLOKNA \
  { printf("Blad ! cos nie tak z wloknami\n"); exit(1); }
#define BLAD_TCL \
  { printf("Blad ! cos nie tak z tcl-em\n"); exit(1); }

#ifdef __WIN32__
#define DLUGOSC_STOSU (1024*20)
#else
#define DLUGOSC_STOSU (1024*500)
  // lin: stos musi byc dosc duzy...
#endif

struct TFiber {
#ifdef __WIN32__
  LPVOID fib;
#else
  ucontext_t fib;
#endif
  Tcl_Interp* interp;
  int zakonczony;
  //TFiber();
  Tcl_Obj* opisBledu;
};
/* // przechodzimy od C++ do C
TFiber::TFiber() {
  zakonczony=0;
  opisBledu=NULL;
}
*/
static int biezacyFiber=0;
static int liczbaFiberow=0;
//static std::string kodFiberow="";
static Tcl_Obj* kodFiberow=NULL;
static struct TFiber* fiber;

static void PrzelaczFiber()
{
  int staryBF=biezacyFiber;
  do {
    biezacyFiber++;
    if( biezacyFiber==liczbaFiberow ) biezacyFiber=0;
  } while ( fiber[biezacyFiber].zakonczony );
#ifdef __WIN32__
  SwitchToFiber(fiber[biezacyFiber].fib);
#else
  swapcontext(&(fiber[staryBF].fib), &(fiber[biezacyFiber].fib));
#endif
}
#ifdef __WIN32__
static void WINAPI funkcjaFiberowa(LPVOID par)
#else
static void funkcjaFiberowa(void)
#endif
{
  while(1) {
    Tcl_Interp* interp= fiber[biezacyFiber].interp;
    //Tcl_Eval(interp, (char*)kodFiberow.c_str());
    int i= Tcl_EvalObjEx(interp, kodFiberow, 0);
      // po zakonczeniu dzialania kodu przelaczamy sie
      // na pierwszy z brzegu, niezakonczony fiber ...
    fiber[biezacyFiber].zakonczony=1;
    if( i==TCL_ERROR ) {
        // zapamietujemy opis bledu o ile blad wystapil
      Tcl_Obj* w1= Tcl_GetObjResult(interp);
      Tcl_Obj* w2= fiber[biezacyFiber].opisBledu;
      if( w2!=NULL ) Tcl_DecrRefCount(w2);
      Tcl_IncrRefCount(w1);
      fiber[biezacyFiber].opisBledu= w1;
    } else {
      Tcl_Obj* w1= Tcl_NewStringObj("ended",-1);
      Tcl_Obj* w2= fiber[biezacyFiber].opisBledu;
      if( w2!=NULL ) Tcl_DecrRefCount(w2);
      Tcl_IncrRefCount(w1);
      fiber[biezacyFiber].opisBledu= w1;
    }
    PrzelaczFiber();
  }
}
static int liczbaNiezakFib() {
  int i= liczbaFiberow-1, j;
  for( j=1; j<liczbaFiberow; j++) if( fiber[j].zakonczony ) i--;
  return i;
}
static int usunFibery() {
  if( liczbaFiberow>0 && liczbaNiezakFib()==0 ) {
    int i;
    for( i=1; i<liczbaFiberow; i++ ) {
      //printf("1. Tcl_InterpDeleted(interp)=%i\n", Tcl_InterpDeleted(fiber[i].interp));
      Tcl_DeleteInterp(fiber[i].interp);
      //printf("2. Tcl_InterpDeleted(interp)=%i\n", Tcl_InterpDeleted(fiber[i].interp));
#ifdef __WIN32__
      DeleteFiber(fiber[i].fib);
#else
      free(fiber[i].fib.uc_stack.ss_sp);
        // pod linuxem trzeba tylko usunac stosy fiberow
#endif
      if(fiber[i].opisBledu!=NULL) Tcl_DecrRefCount(fiber[i].opisBledu);
    }
    //delete [] fiber;
    free(fiber);
    liczbaFiberow=0;
    biezacyFiber=0;

    if( kodFiberow!=NULL ) Tcl_DecrRefCount(kodFiberow);
    kodFiberow=NULL;
      // kodFiberow tez usuwamy ...

    return 1;
  }
  return 0;
}
static void restartFibery() {
  int i;
  for( i=1; i<liczbaFiberow; i++) {
    fiber[i].zakonczony=0;
    if(fiber[i].opisBledu!=NULL) Tcl_DecrRefCount(fiber[i].opisBledu);
    fiber[i].opisBledu=NULL;
  }
}

int FiberCmd(
  ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]
) {
  if( objc==4 && strcmp(Tcl_GetString(objv[1]),"create")==0 ) {
    //
    // fiber create 100 { ... fiber yield; ... }
    //
    if( liczbaFiberow>0 ) {
      interp->result = "delete fibers first!"; return TCL_ERROR;
    }
    // odczytujemy parametry komendy:
    int i;
    if( Tcl_GetIntFromObj(interp, objv[2], &i)==TCL_ERROR ) return TCL_ERROR;
    liczbaFiberow= i+1;
    //kodFiberow= Tcl_GetString(objv[3]);
    if( kodFiberow!=NULL ) Tcl_DecrRefCount(kodFiberow);
    kodFiberow= objv[3];
    Tcl_IncrRefCount(kodFiberow);

    //fiber= new TFiber[liczbaFiberow];
    fiber= calloc(sizeof(struct TFiber), liczbaFiberow);
    // glowne wlokno
#ifdef __WIN32__
    fiber[0].fib= ConvertThreadToFiber(NULL);
#endif

    for( i=1; i<liczbaFiberow; i++ ) {
      // tworzymy wlokno
#ifdef __WIN32__
      LPVOID f= CreateFiber(DLUGOSC_STOSU, funkcjaFiberowa, NULL);
      if( f==NULL ) BLAD_WLOKNA
      fiber[i].fib= f;
#else
      ucontext_t* wfib= &(fiber[i].fib);
      getcontext( wfib );
      wfib->uc_link = 0;
      wfib->uc_stack.ss_sp = malloc( DLUGOSC_STOSU );
      wfib->uc_stack.ss_size = DLUGOSC_STOSU;
      wfib->uc_stack.ss_flags = 0;
      if ( wfib->uc_stack.ss_sp == 0 ) BLAD_WLOKNA
      makecontext( wfib, &funkcjaFiberowa, 0 );
#endif
      // tworzmy interp Tcl-u
      char c[20]; sprintf(c, "fiber%i", i-1);
      Tcl_Interp *i2= Tcl_CreateSlave(interp, c, 0);
      if( i2==NULL ) BLAD_TCL
      fiber[i].interp= i2;
      Tcl_CreateObjCommand(i2,"fiber",FiberCmd,NULL,NULL);
    }
    return TCL_OK;
  } else if( objc==2 && strcmp(Tcl_GetString(objv[1]),"yield")==0 ) {
    //
    // fiber yield
    //
    if( liczbaFiberow==0 ) {
      interp->result = "create fibers first!"; return TCL_ERROR;
    }
    PrzelaczFiber();
    return TCL_OK;
  /*} else if( objc==2 && strcmp(Tcl_GetString(objv[1]),"current")==0 ) {
    //
    // fiber current
    //
    Tcl_SetObjResult(interp, Tcl_NewIntObj(biezacyFiber-1));
      // czy tu sie prawidlowo zarzadza pamiecia ???
    return TCL_OK;
  */
  } else if( objc==2 && strcmp(Tcl_GetString(objv[1]),"number")==0 ) {
    //
    // fiber number
    //
    Tcl_SetObjResult(interp, Tcl_NewIntObj(liczbaNiezakFib()));
    return TCL_OK;
  } else if( objc==2 && strcmp(Tcl_GetString(objv[1]),"delete")==0 ) {
    //
    // fiber delete
    //
    if( usunFibery() )
      return TCL_OK;
    else {
      interp->result = "impossible to delete fibers!"; return TCL_ERROR;
    }
  } else if( objc==3 && strcmp(Tcl_GetString(objv[1]),"code")==0 ) {
    //
    // fiber code { ... }
    //
    if( kodFiberow!=NULL ) Tcl_DecrRefCount(kodFiberow);
    kodFiberow= objv[2];
    Tcl_IncrRefCount(kodFiberow);
    restartFibery();
    return TCL_OK;
  } else if( objc==2 && strcmp(Tcl_GetString(objv[1]),"restart")==0 ) {
    //
    // fiber restart
    //
    restartFibery();
    return TCL_OK;
  } else if( objc==2 && strcmp(Tcl_GetString(objv[1]),"error")==0 ) {
    //
    // fiber error
    //
    //Tcl_Obj** tab= new Tcl_Obj* [liczbaFiberow];
    Tcl_Obj** tab= calloc(sizeof(Tcl_Obj*), liczbaFiberow);
    int i;
    for( i=1; i<liczbaFiberow; i++ ) {
      if( fiber[i].opisBledu!=NULL ) tab[i]=fiber[i].opisBledu;
      else tab[i]=Tcl_NewStringObj("",-1);
        // nie musimy zwiekszac refcount, robi to Tcl_NewListObj() !
    }
    Tcl_Obj *lista= Tcl_NewListObj(liczbaFiberow-1, &tab[1]);
    Tcl_SetObjResult(interp,lista);
    //delete tab;
    free(tab);
    return TCL_OK;
  } else if( objc==3 && strcmp(Tcl_GetString(objv[1]),"restart")==0 ) {
    //
    // fiber restart <nr fibera>
    //
    int i;
    if( Tcl_GetIntFromObj(interp, objv[2], &i)==TCL_ERROR ) return TCL_ERROR;
    if(! (0<=i && i<=liczbaFiberow-2)) {
      interp->result = "wrong fiber number !"; return TCL_ERROR;
    }
    struct TFiber *f= &fiber[i+1];
    f->zakonczony=0;
    if( f->opisBledu!=NULL ) Tcl_DecrRefCount(f->opisBledu);
    f->opisBledu= Tcl_NewStringObj("",-1);
    Tcl_IncrRefCount(f->opisBledu);
    return TCL_OK;
  } else if( objc==3 && strcmp(Tcl_GetString(objv[1]),"stop")==0 ) {
    //
    // fiber stop <nr fibera>
    //
    int i;
    if( Tcl_GetIntFromObj(interp, objv[2], &i)==TCL_ERROR ) return TCL_ERROR;
    if(! (0<=i && i<=liczbaFiberow-2)) {
      interp->result = "wrong fiber number !"; return TCL_ERROR;
    } // identyczny kod jak w fiber restart; moze zrobic funkcje?
    struct TFiber *f= &fiber[i+1];
    f->zakonczony=1;
    if( f->opisBledu!=NULL ) Tcl_DecrRefCount(f->opisBledu);
    f->opisBledu= Tcl_NewStringObj("stopped",-1);
    Tcl_IncrRefCount(f->opisBledu);
    return TCL_OK;
  } else if( objc==3 && strcmp(Tcl_GetString(objv[1]),"switchto")==0 ) {
    //
    // fiber switchto main | <nr fibera>
    //
    int i;
    if( strcmp(Tcl_GetString(objv[2]),"main")==0 ) i=0; else {
      if( Tcl_GetIntFromObj(interp, objv[2], &i)==TCL_ERROR ) return TCL_ERROR;
      i++;
      if(! (1<=i && i<=liczbaFiberow-1)) {
        interp->result = "wrong fiber number !"; return TCL_ERROR;
      }
    } // "i" zawiera nr fibera na ktory sie mamy przelaczyc
    if( fiber[i].zakonczony ) {
      interp->result = "fiber ended !"; return TCL_ERROR;
    }
    int staryBF=biezacyFiber; biezacyFiber=i;
#ifdef __WIN32__
    SwitchToFiber(fiber[biezacyFiber].fib);
#else
    swapcontext(&(fiber[staryBF].fib), &(fiber[biezacyFiber].fib));
#endif
    return TCL_OK;
  } else {
    interp->result = "wrong subcommand or # of parameters !";
    return TCL_ERROR;
  }
}

// --- fiber (koniec) -----------------------------------------------

DLL_EXPORT int Q_Init(Tcl_Interp *interp) {
  //Tcl_InitStubs(interp, "8.4", 0);
  if( Tcl_InitStubs(interp, "8.4", 0)==0 ) return TCL_ERROR;
  Tcl_CreateObjCommand(interp,"wersja",WersjaCmd,NULL,NULL);
  Tcl_CreateObjCommand(interp,"sumaLiczb",SumaLiczbCmd,NULL,NULL);
  Tcl_CreateObjCommand(interp,"type",TypeCmd,NULL,NULL);
  Tcl_CreateObjCommand(interp,"fiber",FiberCmd,NULL,NULL);
  return TCL_OK;
}


