wm geom .konsola 667x664+321+12; wm geom .output 309x348+265+64; wm withdraw .; kons_font 15
kons_font 16
load ./q3.so

proc wypelnijListe li {
  set w {}
  for {set i 0} {$i<$li} {incr i} {lappend w 0}
  set w
}

fiber create 1 start

proc Inicjalizacja nr {
  fiber$nr alias _puts _puts
  fiber$nr alias maineval eval
  fiber$nr alias wypelnijListe wypelnijListe
  fiber$nr eval "set nr $nr; set run 1"
  fiber$nr eval {
    set liElem 3

    proc start {} {
      set ::bity [wypelnijListe $::liElem]
      set ::wynik [wypelnijListe $::liElem]
      permutacja 0
    }
    proc permutacja li {
      if {$li>=$::liElem} {
        maineval "set zm {$::wynik}"
        fiber switchto main
        set ::run;
        return
      }
      for {set i 0} {$i<$::liElem} {incr i} {
        if {[lindex $::bity $i]==0} {
          lset ::wynik $i $li
          lset ::bity $i 1
          permutacja [expr {$li+1}]
          lset ::bity $i 0
        }
      }
    }
  }
}
Inicjalizacja 0

fiber error

proc Restart nr {
  if { [lindex [fiber error] $nr]!="" } {
    fiber restart $nr
  } else {
    fiber$nr eval {unset ::run}; fiber switchto $nr
    fiber$nr eval {set ::run 1}; fiber restart $nr
  }
}
Restart 0

fiber0 eval {set ::liElem 4}

fiber switchto 0; set zm

exit
