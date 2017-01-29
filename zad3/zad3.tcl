source symul_lib.tcl

set liczbaWierz 10
iterate i $liczbaWierz {
  let i1 $i-1; if {$i1==-1} {let i1 $liczbaWierz-1}
  let i2 $i+1; if {$i2==$liczbaWierz} {let i2 0}
  set sasiedzi($i) "$i1 $i2"
}

fiber create $liczbaWierz {
  set lider 1;
  set phase 0;
  set reqSent 0;

  proc K { x y } { set x }
  proc lremove { listvar string } {
    upvar $listvar in
    foreach item [K $in [set in [list]]] {
      if {[string equal $item $string]} { continue }
      lappend in $item
    }
  }

  while {$run} {
    set licznik [expr 2*pow($phase, 1)];
    if {$lider==1 && $reqSent==0} {
      if {$licznik>0} {
        wyslij 0 "req $phase $id_los $licznik";
        wyslij 1 "req $phase $id_los $licznik";
      } else {
        wyslij 0 "req $phase $id_los 1";
        wyslij 1 "req $phase $id_los 1";
      }
      set reqSent 1;
    }

    fiber yield;

    
}

Inicjalizacja

proc wizualizacja {} {
  fiber_iterate {_puts "$id, $id_los, $lider; $kom0, $kom1"}
}

wm withdraw .
wm geom .konsola 552x703+443+5
wm geom .output 309x703+116+5

fiber yield; runda; wizualizacja; set licznikKom
