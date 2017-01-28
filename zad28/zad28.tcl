source symul_lib.tcl

set liczbaWierz 10
iterate i $liczbaWierz {
  let i1 $i-1; if {$i1==-1} {let i1 $liczbaWierz-1}
  let i2 $i+1; if {$i2==$liczbaWierz} {let i2 0}
  set sasiedzi($i) "$i1 $i2"
}

fiber create $liczbaWierz {
  set root 0;
  set myFather -1;
  set komToMyFather -1;
  set distanceToRoot -1;
  set myChildren "";

  if {$id==0} {
    set root 1;
  }

  while {$run} {
    if {$root==1} {
      for {set i 0} {$i < $stopien} {incr i} {
        wyslij $i "youAreMyChild $id 1";
      }
    }

    fiber yield;

    if {$root==0} {
      for {set i 0} {$i < $stopien} {incr i} {
        _puts "Wchodzi"
        set komunikat [czytaj $i];

        if {$komunikat!="" && [lindex $komunikat 0]=="youAreMyChild"} {
          if {[lindex $komunikat 2] > $distanceToRoot} {
            set myFather [lindex $komunikat 1];
            set distanceToRoot [lindex $komunikat 2];
            set komToMyFather $i;
          }
        } elseif {$komunikat!="" && [lindex $komunikat 0]=="youAreMyFather"} {
          lappend myChildren [lindex $komunikat 1];
        }
      }

      for {set i 0} {$i < $stopien} {incr i} {
        wyslij $i "youAreMyChild $id [expr $distanceToRoot+1]";
      }
    }
  }
}

Inicjalizacja;

proc wizualizacja {} {
  fiber_iterate {_puts "Wierzchołek $id, myFather: $myFather, distanceToRoot: $distanceToRoot"}
}

fiber error
pokazKom
wizualizacja

fiber yield; runda; wizualizacja
