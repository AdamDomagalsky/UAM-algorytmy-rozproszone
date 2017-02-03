source symul_lib.tcl;

set liczbaWierz 5
set sasiedzi(0) {4 1}
set sasiedzi(1) {0 2}
set sasiedzi(2) {1 3}
set sasiedzi(3) {2 4}
set sasiedzi(4) {3 0}

fiber create $liczbaWierz {

  if {$id==0} {wyslij 1 0}
  fiber yield;

  while {$run} {
    if {$kom0!=""} {
      set x $kom0
      incr x
      kom1_wyslij $x
    }
    fiber yield;
  }
}

Inicjalizacja;

proc wizualizacja {} {
  fiber_iterate {_puts "$id: $kom0, $kom1"}
}

if 0 {
  set_run 0; fiber yield; runda; set_run 1; fiber delete
  set_run 0; fiber yield; runda; set_run 1; fiber restart
  fiber error
  fiber_eval 0 {set id}
}

fiber yield; runda; wizualizacja
