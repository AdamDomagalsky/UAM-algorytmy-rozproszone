load ./q3.dll

source symul_lib.tcl;

set obslugaBitow {
  proc bity x { # postac binarna liczby
    usun0 [binary scan [binary format I $x] B* x; set x]
  }
  proc usun0 x { # usuwa zera poczatkowe z repr bin liczby
    set x [string trimleft $x 0]
    if {$x==""} {set x 0}
    set x
  }
  proc porownanieC {cv cu} { # porownuje 2 kolory, zwraca indeks oraz 2 bity...
    set dlcu [string len $cu]
    set dlcv [string len $cv]
    if {$dlcu<$dlcv} {
      set cu "[string repeat 0 [expr {$dlcv-$dlcu}]]$cu"
    }
    if {$dlcu>$dlcv} {
      set cv "[string repeat 0 [expr {$dlcu-$dlcv}]]$cv"
    }
    set dl [string len $cu]
    iterate i $dl {
      set i1 [expr {$dl-$i-1}]
        # KONIECZNIE trzeba numerowac bity od prawej gdyz
        # dopisuje sie 0 z lewej i wtedy indeksy by sie zmienialy!
      set bu [string index $cu $i1]
      set bv [string index $cv $i1]
      if {$bu != $bv} {return "$i $bv $bu"}
    }
    return {-1 ? ?}
  }
  proc wyrownaj {L x} { # dodaje 0 z lewej do L-bitow
    set dl [string len $x]
    if {$dl>$L} {error "wyrownaj"}
    return "[string repeat "0" [expr {$L-$dl}]]$x"
  }
  proc bin2dec x { # do 32-bitow
    binary scan [binary form B* [wyrownaj 32 $x]] I y
    set y
  }
  proc iterate {zm liIter kod} { # wygodna petla
    upvar $zm i
    for {set i 0} {$i<$liIter} {incr i} {
      set e [catch {uplevel $kod} x]
      if {$e!=0} {return -code $e $x}
    }
  }
}

#fiber_iterate $obslugaBitow

set liczbaWierz 5
set sasiedzi(0) {4 1}
set sasiedzi(1) {0 2}
set sasiedzi(2) {1 3}
set sasiedzi(3) {2 4}
set sasiedzi(4) {3 0}

fiber create $liczbaWierz {
	
}

Inicjalizacja;

proc wizualizacja {} {
  fiber_iterate {_puts "$id: $lider, $kom0, $kom1"}
}

if 0 {
set_run 0; fiber yield; runda; set_run 1; fiber delete
  # usuwanie fiberow
set_run 0; fiber yield; runda; set_run 1; fiber restart
  # restart kodu fiberow
fiber error
  # wyswietla stan fiberow ({}, ended, error)
}
 
fiber yield; runda; wizualizacja