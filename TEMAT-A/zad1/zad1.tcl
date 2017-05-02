load ./q3.dll

source symul_lib.tcl;

set liczbaWierz 5
set sasiedzi(0) {4 1}
set sasiedzi(1) {0 2}
set sasiedzi(2) {1 3}
set sasiedzi(3) {2 4}
set sasiedzi(4) {3 0}

fiber create $liczbaWierz {
	set lider ?;
	kom0_wyslij $id;
	fiber yield;
	while {$run} {
		if {$kom1!=""} {
			set x $kom1;
			if {$lider==1} {
				
			} elseif {$x==0} {
				kom0_wyslij $x;
				set lider 0;
			} elseif {$x>$id} {
				kom0_wyslij $x;
			} elseif {$x==$id} {
				set lider 1;
				kom0_wyslij 0;
			} elseif {$x < $id} {
			
			}
		}
		fiber yield;
	}
}

Inicjalizacja;

proc wizualizacja {} {
  fiber_iterate {_puts "$id: $lider, $kom1"}
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