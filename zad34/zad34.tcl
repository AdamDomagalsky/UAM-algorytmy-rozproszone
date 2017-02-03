source symul_lib.tcl

set liczbaWierz 10
set sasiedzi(0) {1 2 3 4 5 6 7 8 9}
set sasiedzi(1) {2 3 4 5 6 7 8 9 0}
set sasiedzi(2) {3 4 5 6 7 8 9 0 1}
set sasiedzi(3) {4 5 6 7 8 9 0 1 2}
set sasiedzi(4) {5 6 7 8 9 0 1 2 3}
set sasiedzi(5) {6 7 8 9 0 1 2 3 4}
set sasiedzi(6) {7 8 9 0 1 2 3 4 5}
set sasiedzi(7) {8 9 0 1 2 3 4 5 6}
set sasiedzi(8) {9 0 1 2 3 4 5 6 7}
set sasiedzi(9) {0 1 2 3 4 5 6 7 8}

fiber create $liczbaWierz {
  _puts "$id reporting in!"
  set f 9
  set xi $id_los
  set yi -1
  set Vi [list $xi]
  for {set k 0} {$k<$f} {incr k} {
    for {set i 0} {$i<$stopien} {incr i} {
      blad $k $i
      wyslij $i $Vi
    }
    fiber yield
    for {set i 0} {$i<$stopien} {incr i} {
      set Vi [myunion $Vi $kom($i)]
    }
  }
  set Vi [lsort -unique $Vi]
  set yi [lindex $Vi 0]
}

Inicjalizacja

fiber_iterate {
  lappend auto_path ./tcllib/struct
  package re struct::set
  proc blad {k i} {}
  proc min_set s { # dodatkowa proc obliczajaca min zbioru
    set min [lindex $s 0]
    foreach x $s {if {$x<$min} {set min $x}}
    return $min
  }
  proc myunion {list1 list2} {
    set result $list1
    foreach element $list2 {
      append result " " $element;
    }
    return [lsort -unique $result];
  }
}

fiber restart

proc wizualizacja {} {
  fiber_iterate {
    if {$id_los<10} {
      _puts "$id: $id_los     | yi=$yi | $Vi"
    } elseif {$id_los<100} {
      _puts "$id: $id_los   | yi=$yi | $Vi"
    } else {
      _puts "$id: $id_los | yi=$yi | $Vi"
    }
  }
  _puts "---------------------------------"
}

proc ma_byc_blad {id k i} {
  fiber_eval $id [string map "@k $k @i $i" {
    proc blad {k i} {
      if {$k==@k && $i==@i} {error "crash"}
    }
  }]
}

ma_byc_blad 0 0 1
ma_byc_blad 1 1 1
ma_byc_blad 2 2 1
ma_byc_blad 3 3 1
ma_byc_blad 4 4 1
ma_byc_blad 5 5 1
ma_byc_blad 6 6 1
ma_byc_blad 7 7 1
ma_byc_blad 8 8 1

fiber error

fiber yield; runda; wizualizacja; fiber error

fiber_eval 6 {set id_los 1887}

fiber delete
set_run 0; fiber yield; runda; set_run 1; fiber delete

fiber_iterate {unset run}; fiber yield
