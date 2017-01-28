load ./q3.dll

source symul_lib.tcl;

#fiber_iterate $obslugaBitow

set liczbaWierz 10
set sasiedzi(0) {1 2 3}
set sasiedzi(1) {0 4 5}
set sasiedzi(2) {0 6 7}
set sasiedzi(3) {0}
set sasiedzi(4) {1}
set sasiedzi(5) {1}
set sasiedzi(6) {2 8 9}
set sasiedzi(7) {2}
set sasiedzi(8) {6}
set sasiedzi(9) {6}

fiber create $liczbaWierz {
	set kolor $id_los;
	if {$id!=0} {
		wyslij 0 $kolor;
	} else {

	}
	fiber yield;
	for {set i 1} {i <= stopien} {incr i} {
		set kolor2 $kom{$i};
	}
	fiber yield;
}

Inicjalizacja;

proc wizualizacja {} {
  fiber_iterate {_puts "$id, $id_los, [array get kom]"}
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
