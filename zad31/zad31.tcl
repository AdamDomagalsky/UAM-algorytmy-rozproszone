source symul_lib.tcl

set sasiedzi(0) {1 2 3}
set sasiedzi(1) {0 4 5}
set sasiedzi(2) {0 6}
set sasiedzi(3) {0 7 8}
set sasiedzi(4) {1}
set sasiedzi(5) {1}
set sasiedzi(6) {2}
set sasiedzi(7) {3}
set sasiedzi(8) {3}

set liczbaWierz 9;

fiber create $liczbaWierz {
  set root 0;
  set safe 0;
  set safeSent 0;

  while {$run} {
    if {$root==0 && $stopien==1 && $safe==0} {
      set safe 1;
      dostarcz 0 "SAFE";
    }

    fiber switchto main;

    while {$safe==0} {
      set licznik 0;
      for {set i 0} {$i < $stopien} {incr i} {
        if {[lindex $kom($i) 0]=="SAFE"} {
          incr licznik;
        }
        if {$licznik == [expr $stopien - 1]} {
          set safe 1;

          for {set j 0} {$j < $stopien} {incr j} {
            czytaj $j;
          }
        }
      }
      fiber switchto main;
    }

    if {$root==0 && $safe==1 && $safeSent==0 && $stopien>1} {
      dostarcz 0 "SAFE";
      set safeSent 1;
    } elseif {$root==1 && $safe==1} {
      for {set i 0} {$i < $stopien} {incr i} {
  			dostarcz $i "PULSE";
        set safe 0;
  		}
    }

    fiber switchto main;

    if {[lindex $kom(0) 0]=="PULSE"} {
      if {$root==0 && $stopien>1} {
        czytaj 0;
        for {set j 1} {$j < $stopien} {incr j} {
    			dostarcz $j "PULSE";
          set safe 0;
          set safeSent 0;
    		}
      } else {
        czytaj 0;
        set safe 0;
        set safeSent 0;
      }
    }

    fiber switchto main;
  }
}

InicjalizacjaAsynch

proc wizualizacja {} {
  fiber_iterate {_puts "Wierzchołek $id, safe: $safe, root: $root"}
}

fiber error
pokazKom
wizualizacja

# ustawić roota dopiero po pierwszej egzekucji
fiber_eval 0 {set root 1}

fiber switchto 0;
fiber switchto 1;
fiber switchto 2;
fiber switchto 3;
fiber switchto 4;
fiber switchto 5;
fiber switchto 6;
fiber switchto 7;
fiber switchto 8;
pokazKom;
