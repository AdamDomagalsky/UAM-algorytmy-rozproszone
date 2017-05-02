source symul_lib.tcl;
set liczbaWierz 6
set sasiedzi(0) {5 1}
set sasiedzi(1) {0 2}
set sasiedzi(2) {1 3}
set sasiedzi(3) {2 4}
set sasiedzi(4) {3 5}
set sasiedzi(5) {4 0}

fiber create $liczbaWierz {
  set suma $id_los
  set licz [expr $liczbaWierz - 1]
  set wynik ""
  kom1_wyslij $suma
  fiber yield;
  while {$run} {
    if {$kom0!="" && $wynik!="end"} {
      if {$licz>0} {
	    set k $kom0
        set suma [expr $id_los + $k]
		set licz [expr $licz - 1]
		kom1_wyslij $suma
      } else {
		set wynik "end"
	  }
    }
    fiber yield;
  }
}

Inicjalizacja;

proc wizualizacja {} {
  fiber_iterate {_puts "$id: $id_los, suma: $suma, $licz, $wynik"}
}

fiber yield; runda; wizualizacja
