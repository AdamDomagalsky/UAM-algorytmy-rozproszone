#
# tcl-owy sumulator alg rozpr (uzywa rozszerzenia fiber)
#

# ---
load ./q3[info sharedlibextension]

## model synchroniczny -----------------------------------------
#

# koniec rundy zaznaczamy przez "fiber yield"

# wierz stopnia np 3 ma incydentne kraw oznaczone przez:
#   kom0, kom1, kom2

# kazda incydentna kraw nr X ma 2 zmienne:
#   komX - zawiera komunikat wyslany przez sasiada w poprzedniej rundzie
#   komX_pisz - tu jest umieszczany komunikat wyslany przez sasiada w biezacej rundzie
#   Uwaga:
#     komX to lista komunikatow, a nie pojedynczy komunikat!!!
#     (jesli komunikat nie ma spacji to lista sie nie rozni
#     od pojedynczego komunikatu!!! to moze byc przyczyna bledow...)

# proc komX_wyslij komunikat
#   sluzy do wysylania komunikatu przez kraw nr X
#   np
#      kom${i}_wyslij "A ku ku"
#      kom1_wyslij $x

# proc komX_dostarcz komunikat (16.11.2009)
#   wysyla i dostarcza komunikat...

# proc wyslij {doKogo co args}
#   wysyla komunikat przez polaczenie nr doKogo
#     np: wyslij $i "A ku ku"
#   podobnie dziala dostarcz (16.11.2009)

# proc czytaj {odKogo args}
#   odbiera komunikat z polaczenia nr odKogo
#   w args moze byc opcja -podgraf {lista nr polaczen}
#   komendy wyslij/czytaj to interf. "wyzszego poziomu"
#     umozliwia pewne uogolnienia, np dzialania na podgrafie:
#       wyslij 0 "123" -podgraf {2 3}; # wysyla przez pol. nr 2
#       czytaj 1 -podgraf {3 4}; # odczytuje z pol. nr 4
#         !!! jeszcze nie zaimplementowane !!!
#   16.11.2009 - zmiana dzialania:
#     czytaj pobiera komunikat z komX, jako kolejki komunikatow

# proc. pomocnicze w konsoli:
#   DodajKraw
#   Inicjalizacja
#   runda
#   set_run
#   fiber_iterate
#   fiber_eval

# proc. pomocnicze w fiberze:
#   iterate zm liIter kod
#   iterate1 zm liIter kod; # robi liIter-1 iteracji od 1 !!!
#   let
#   comment

# BLAD iterate!!! (16.11.2009)
#   problem gdy w ciele iterate jest break/continue/return/error
#   ...chyba usunalem ten blad???

# ---

# proc pomocnicze w zmiennej
# (zeby mozna bylo je latwo przeslac do fiberow)
set iterate_kod {
  proc iterate {zm liIter kod} {
    # catch: 0 ok, 1 error, 2 return, 3 break, 4 continue
    upvar $zm i
    for {set i 0} {$i<$liIter} {incr i} {
      set e [catch {uplevel $kod} x]
      if {$e==3} {return $x}
      if {$e==1 || $e==2} {return -code $e $x}
    }
  }
  proc iterate1 {zm liIter kod} { # ta wersja robi liIter-1 iteracji !!!
    upvar $zm i
    for {set i 1} {$i<$liIter} {incr i} {
      set e [catch {uplevel $kod} x]
      if {$e==3} {return $x}
      if {$e==1 || $e==2} {return -code $e $x}
    }
  }
  proc let {zm wart} {
    uplevel set $zm [expr $wart]
  }
  proc comment x {
  }
  proc unset2 args { # bezpieczne unset; dla zm. globalnych!
    foreach v $args {if {[info exists $v]} {unset $v}}
  }
}
eval $iterate_kod

proc fiber_iterate kod {
  global liczbaWierz
  iterate i $liczbaWierz {
    fiber$i eval "uplevel #0 {$kod}"
  }
}
proc fiber_eval {procesor kod} {
  fiber$procesor eval "uplevel #0 {$kod}"
}

# budowanie grafu - proc pomocnicze
proc DodajKraw {v1 v2} {
  global sasiedzi
  if {[lsearch -exact $sasiedzi($v1) $v2]==-1} {
    lappend sasiedzi($v1) $v2
  }
  if {[lsearch -exact $sasiedzi($v2) $v1]==-1} {
    lappend sasiedzi($v2) $v1
  }
}

# inicjalizacja fiberow
proc Inicjalizacja {} {
  global liczbaWierz sasiedzi iterate_kod licznikKom
  set licznikKom 0
  iterate i $liczbaWierz {
    interp alias fiber$i _puts "" _puts
    interp alias fiber$i incrLicznikKom "" incr ::licznikKom

    # tworzymy komendy komunikacyjne (aliasy) ...
    set stopien [llength $sasiedzi($i)]
    iterate j $stopien {
      set x [lindex $sasiedzi($i) $j]
      set k [lsearch -exact $sasiedzi($x) $i]
      interp alias fiber$i kom${j}_wyslij fiber$x __wyslij $k
      interp alias fiber$i kom${j}_dostarcz fiber$x __dostarcz $k
    }

    # zmienne dostepne w kazdym fiberze ...
    set id [expr round(rand()*1000)]
    fiber$i eval "
      $iterate_kod
      set run 1
      set id $i
      set id_los $id
      set stopien $stopien
      iterate __i $stopien {
        set kom\$__i {}
        set kom\${__i}_pisz {}
      }
      unset __i
      set liczbaWierz $liczbaWierz
    "

    # Uwaga: proc kom?_wyslij GWARANTUJE
    #   ze zmodyfikuje zmienne globalne kom?_pisz
    #   a nie przypadkowe zmienne lokalne ...
    fiber$i eval {
      proc __wyslij {nrKom args} {
        global kom${nrKom}_pisz
        eval lappend kom${nrKom}_pisz $args
        incrLicznikKom
      }
      proc __dostarcz {nrKom args} { # "wyslij i dostarcz"
        global kom${nrKom}
        eval lappend kom${nrKom} $args
        incrLicznikKom
      }
    }

    # proc wyslij/czytaj (dodane 25.09.2009)
    fiber$i eval {
      proc wyslij {doKogo co args} {
        kom${doKogo}_wyslij $co
      }
      proc dostarcz {doKogo co args} {
        kom${doKogo}_dostarcz $co
      }
      proc czytaj {odKogo args} {
        upvar #0 kom$odKogo kom
        set x [lindex $kom 0]
        set kom [lrange $kom 1 end]
        return $x
      }
    }
  }
}

# obsluga zmiennych komunikacyjnych
# te procedure uruchamiac z glownego fibera
proc runda {} {
  fiber_iterate {
    iterate __i $stopien {
      set kom$__i [set kom${__i}_pisz]
      set kom${__i}_pisz ""
    }
    unset __i
  }
}

# konczenie fiberow
proc set_run p {
  fiber_iterate "set run $p"
}


## model Asynchroniczny ---------------------------------------------
#

## model asynch z osobnymi zdarzeniami obl. i dostarczania (19.10.2009)
# * wysylanie komunikatu przy pomocy:
#     komX_wyslij msg
# * dostarczone komunikaty sa dostepne w zmiennych komX;
#   oczekiwanie na dostarczenie komunikatu okreslnego typu:
#     czytajKomTypu {typ nrPolaczenia}
#     zaklada sie ze komunikat to lista >=2 elementowa, pierwsze slowo to typ
#     jesli brak potrzebnego komunikatu to proc wykonuje "fiber switchto main"
# * generowanie zdarzenia obliczeniowego:
#     fiber switchto procesor
# * generowanie zdarzenia dostarczenia komunikatu:
#     dostarczKom procesor nrPolaczenia
#     przemieszcza komunikaty z komX_pisz do komX
# * podglad dostepnych komunikatow:
#     pokazKom
# * proc pomocnicze:
#     zakonczFibery
#     zaproponuj
#       proponuje zdarzenia ktore cos zmienia...

# proc czytajKomTypu {typ nrPolaczenia {varNrPol ""}}
#   zaklada sie ze w kazdym komunikacie pierwsze slowo to typ...
#   mozna podac "*" jako nrPolaczenia i/lub typ !!!
#   rzeczywisty nr jest zwracany przez (opcjonalny) varNrPol
#   (17.11.2009)
#   !!! NIEPRZETESTOWANE i NIEDOKONCZONE !!!
#     niepewne dzialanie zaproponuj...

# ---

proc InicjalizacjaAsynch {} {
  Inicjalizacja
  fiber_iterate {
    if 0 {
    proc czytajKomTypu {typ nrPolaczenia} {
      global stopien id run
      upvar #0 kom$nrPolaczenia kom
      while 1 {
        set i [lsearch $kom "$typ *"]
        if {$i==-1} {
          set ::czytajKomTypu,typ $typ; # wiadomo na co czeka ten fiber
          set ::czytajKomTypu,nrPolaczenia $nrPolaczenia
          fiber switchto main
          set run; # umozliwia zakonczenie pracy
        } else {
          set k [lindex $kom $i]
          set kom [lreplace $kom $i $i]
          return $k
        }
      }
    }}
    if 1 {
    proc czytajKomTypu {typ nrPolaczenia {varNrPol ""}} {
      global stopien id run
      while 1 {
        if {$nrPolaczenia!="*"} {
          upvar #0 kom$nrPolaczenia kom; set i [lsearch $kom "$typ *"]
        } else {
          # przeszukujemy wszystkie polaczenia...
          set i -1
          iterate j $stopien {
            upvar #0 kom$j kom; set i [lsearch $kom "$typ *"]
            if {$i!=-1} {
              if {$varNrPol!=""} {upvar $varNrPol varNrPol_; set varNrPol_ $j}
              break; # tu byl blad, gdy iterate zle dzialalo...
            }
          }
        }
        if {$i==-1} {
          set ::czytajKomTypu,typ $typ; # wiadomo na co czeka ten fiber!
          set ::czytajKomTypu,nrPolaczenia $nrPolaczenia
	    # obecnie to moze byc "*" !!
          fiber switchto main
          set run; # umozliwia zakonczenie pracy
        } else {
          set k [lindex $kom $i]
          set kom [lreplace $kom $i $i]
          return $k
        }
      }
    }}
  }
}

proc dostarczKom {procesor nrPolaczenia} {
  fiber$procesor eval "uplevel #0 {
    set __nr $nrPolaczenia
  }"
  fiber$procesor eval {uplevel #0 {
    set __k1 [set kom${__nr}_pisz]
    if {[llength $__k1]>0} {
      set __msg [lindex $__k1 0]
      set __k1 [lreplace $__k1 0 0]
      lappend  kom$__nr $__msg
      set kom${__nr}_pisz $__k1
    }
    catch {unset __nr __k1 __msg}
  }}
    # mozna tu uzyc fiber_eval...
}

proc pokazKom args {
  fiber_iterate {
    set __wydruk "$id, [format %3d $id_los]: "
    iterate __i $stopien {
      append __wydruk "$__i/ [set kom${__i}_pisz], "
    }
    iterate __i $stopien {
      append __wydruk "$__i// [set kom${__i}], "
    }
    _puts $__wydruk
    unset __wydruk __i
  }
}

# zaklada sie ze kazdy fiber ma "set run" za "fiber switchto main"
# dodatkowo proc czysci komunikaty!
proc zakonczFibery {} {
  global liczbaWierz
  set err [fiber error]
  for {set i 0} {$i<$liczbaWierz} {incr i} {
    catch {fiber_eval $i {unset run}}
    catch {fiber switchto $i}
    catch {fiber_eval $i {set run 1}}
  }
  fiber_iterate {
    iterate __i $stopien {
      set kom$__i {}
      set kom${__i}_pisz {}
    }
    unset __i
  }
  set ::licznikKom 0
}

proc zaproponuj {} {
  fiber_iterate {
    proc __zaproponuj {} {
      upvar ::czytajKomTypu,typ typ
      upvar ::czytajKomTypu,nrPolaczenia nr
      global id stopien
      if {! ([info exists typ] && [info exists nr])} {return ""}
      if {$nr=="*"} {
        iterate i $stopien {
          upvar ::kom${i}_pisz kom_pisz
  	  if {[lindex $kom_pisz 0 0]==$typ || ($typ=="*" && $kom_pisz!={}) } {
	    return "dostarczKom $id $i; fiber switchto $id"
	  }
	}
      } else {
        upvar ::kom${nr}_pisz kom_pisz
	if {[lindex $kom_pisz 0 0]==$typ || ($typ=="*" && $kom_pisz!={}) } {
	  return "dostarczKom $id $nr; fiber switchto $id"
	}
      }
      return ""
    }
  }
  global liczbaWierz
  set xx "\n"
  iterate i $liczbaWierz {
    set y [fiber_eval $i __zaproponuj]
    if {$y!=""} {append xx "$y\n"}
  }
  return [string range $xx 0 end-1]
}

