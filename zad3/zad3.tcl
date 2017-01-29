# kompletnie nie działa!

source symul_lib.tcl

set liczbaWierz 10

iterate i $liczbaWierz {
  let i1 $i-1; if {$i1==-1} {let i1 $liczbaWierz-1}
  let i2 $i+1; if {$i2==$liczbaWierz} {let i2 0}
  set sasiedzi($i) "$i1 $i2"
}

fiber create $liczbaWierz {
  set lider 1;
  set halfLider 0;
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
    if {$lider==1} {
      if {$licznik>0} {
        wyslij 0 "req $phase $id_los $licznik";
        wyslij 1 "req $phase $id_los $licznik";
      } else {
        wyslij 0 "req $phase $id_los 1";
        wyslij 1 "req $phase $id_los 1";
      }
    }

    fiber yield;

    while {$kom(0)!="" || $kom(1)!=""} {
      set x $kom(0);

      if {[lindex $x 0]=="req" && [lindex $x 2] == $id_los} {
        set wierz0 [czytaj 0];
        set halfLider [expr $halfLider + 1];
        if {$halfLider == 2} {
          _puts "Lider wybrany!";
          unset run;
          break;
        }
      } elseif {[lindex $x 0]=="req" && [lindex $x 3]==1} {
        set wierz0 [czytaj 0];
        # jeśli ID_losowe w komunikacie jest większe od mojego ID_los
        if {[lindex $wierz0 2] > $id_los} {
          # jeśli numer fazy jest większy od >= 1
          # warunek po to, aby w wyrażeniu expr nie pojawiał się wynik 0.0
          if {[lindex $wierz0 1] > 0} {
            # w komunikacie odsyłam numer fazy wierzchołka od którego dostałem komunikat
            # komunikat dostałem z połączenia 0, więc odsyłam tym samym połączeniem
            # nie wiem czy to jest poprawne rozumowanie?
            wyslij 0 "res [lindex $wierz0 1] [lindex $wierz0 2] youAreLider [expr 2*pow([lindex $wierz0 1], 1)]";
          } else {
            # jeśli komunikat pochodzi z fazy nr 0
            wyslij 0 "res 0 [lindex $wierz0 2] youAreLider 1";
          }
          # skoro trafiłem w to miejsce to nie jestem liderem
          set lider 0;
        } else {
          # jeśli to ja mam większe ID_los od ID_los z odebranego komunikatu
          # UWAGA! zakładam, że wierzchołki mają różne ID_los
          if {[lindex $wierz0 1] > 0} {
            wyslij 0 "res [lindex $wierz0 1] [lindex $wierz0 2] youAreNotLider [expr 2*pow([lindex $wierz0 1], 1)]";
          } else {
            wyslij 0 "res 0 [lindex $wierz0 2] youAreNotLider 1";
          }
        }
      } elseif {[lindex $x 0]=="req" && [lindex $x 3] > 1} {
        # _puts "To nie moja faza! Wierzchołek nr $id, id_los: $id_los";
        # jeśli otrzymałem request, ale NIE JEST skierowany do mnie
        set wierz0 [czytaj 0];
        # zmniejsz licznik o -1
        lset wierz0 3 [expr [lindex $wierz0 3] - 1];
        # otrzymałem z połączenia nr 0 więc przekazuje połączeniem przeciwnym
        wyslij 1 $wierz0;
      } elseif {[lindex $x 0]=="res" && [lindex $x 4] > 1} {
        set wierz0 [czytaj 0];
        lset wierz0 4 [expr [lindex $wierz0 4] - 1];
        wyslij 1 $wierz0;
      }

      set y $kom(1);

      if {[lindex $y 0]=="req" && [lindex $y 2] == $id_los} {
        set wierz1 [czytaj 1];
        set halfLider [expr $halfLider + 1];
        if {$halfLider == 2} {
          _puts "Lider wybrany!";
          unset run;
          break;
        }
      } elseif {[lindex $y 0]=="req" && [lindex $y 3]==1} {
        # _puts "Wierzchołek nr $id, id_los: $id_los, wykonuje request. Nr fazy: $phase";
        # zapisz komunikat i usuń z listy komunikatów
        set wierz1 [czytaj 1];
        # jeśli ID_losowe w komunikacie jest większe od mojego ID_los
        if {[lindex $wierz1 2] > $id_los} {
          # jeśli numer fazy jest większy od >= 1
          # warunek po to, aby w wyrażeniu expr nie pojawiał się wynik 0.0
          if {[lindex $wierz1 1] > 0} {
            # w komunikacie odsyłam numer fazy wierzchołka od którego dostałem komunikat
            # komunikat dostałem z połączenia 1, więc odsyłam tym samym połączeniem
            # nie wiem czy to jest poprawne rozumowanie?
            wyslij 1 "res [lindex $wierz1 1] [lindex $wierz1 2] youAreLider [expr 2*pow([lindex $wierz1 1], 1)]";
          } else {
            # jeśli komunikat pochodzi z fazy nr 0
            wyslij 1 "res 0 [lindex $wierz1 2] youAreLider 1";
          }
          # skoro trafiłem w to miejsce to nie jestem liderem
          set lider 0;
        } else {
          # jeśli to ja mam większe ID_los od ID_los z odebranego komunikatu
          # UWAGA! zakładam, że wierzchołki mają różne ID_los
          if {[lindex $wierz1 1] > 0} {
            wyslij 1 "res [lindex $wierz1 1] [lindex $wierz1 2] youAreNotLider [expr 2*pow([lindex $wierz1 1], 1)]";
          } else {
            wyslij 1 "res 0 [lindex $wierz1 2] youAreNotLider 1";
          }
        }
      } elseif {[lindex $y 0]=="req" && [lindex $y 3] > 1} {
        # jeśli otrzymałem request, ale NIE JEST skierowany do mnie
        set wierz1 [czytaj 1];
        # zmniejsz licznik o -1
        lset wierz1 3 [expr [lindex $wierz1 3] - 1];
        # otrzymałem z połączenia nr 1 więc przekazuje połączeniem przeciwnym
        wyslij 0 $wierz1;
      } elseif {[lindex $y 0]=="res" && [lindex $y 4] > 1} {
        # _puts "Upss, to nie dla mnie. Przekażę to dalej..."
        set wierz1 [czytaj 1];
        lset wierz1 4 [expr [lindex $wierz1 4] - 1];
        # przekaż dalej
        wyslij 0 $wierz1;
      }

      if {[lindex $x 0]=="req" && [lindex $y 0]=="req" && [lindex $x 2]==[lindex $y 2] && [lindex $x 2] == $id_los} {
        _puts "Znaleziono lidera!"
        set wierz0 [czytaj 0];
        set wierz1 [czytaj 1];
      } elseif {[lindex $x 0]=="res" && [lindex $x 1]==[lindex $y 1] && [lindex $x 1]==$phase && [lindex $y 2] == $id_los} {
        # _puts "Wierzchołek nr $id, id_los: $id_los, wykonuje response. Nr fazy: $phase";
        # zapisz komunikaty i usuń z list komunikatów
        set wierz0 [czytaj 0];
        set wierz1 [czytaj 1];
        if {[lindex $wierz0 3]=="youAreNotLider" || [lindex $wierz1 3]=="youAreNotLider"} {
          set lider 0;
        }
        # skoro tu trafiłem to mogę zwiększyć mój numer fazy
        set phase [expr $phase + 1];
        set reqSent 0;
      }

      fiber yield;
    }
  }
}

Inicjalizacja

proc wizualizacja {} {
  fiber_iterate {_puts "Wierzchołek nr $id, id_los: $id_los, lider: $lider, reqSent: $reqSent nr fazy: $phase, kom0: $kom0, kom1: $kom1"}
}

fiber_eval 0 {set id_los 800}
fiber_eval 1 {set id_los 600}
fiber_eval 2 {set id_los 400}
fiber_eval 3 {set id_los 200}
fiber_eval 4 {set id_los 100}
fiber_eval 5 {set id_los 300}
fiber_eval 6 {set id_los 500}
fiber_eval 7 {set id_los 700}

wm withdraw .
wm geom .konsola 309x703+116+5
wm geom .output 552x703+443+5

fiber yield; runda; wizualizacja

fiber error
pokazKom
wizualizacja
