# komunikaty zamieniają się miejscami
# coś jest mocno nie tak...
# czy res sprawdzać po numerze fazy czy po liczniku? chyba liczniku...
# zamiast czytajKomTypu można chyba zapisać $x i usunąć przez lremove

source symul_lib.tcl;

set liczbaWierz 8
set sasiedzi(7) {3 0}
set sasiedzi(0) {7 4}
set sasiedzi(4) {0 2}
set sasiedzi(2) {4 6}
set sasiedzi(6) {2 1}
set sasiedzi(1) {6 5}
set sasiedzi(5) {1 3}
set sasiedzi(3) {5 7}

fiber create $liczbaWierz {
  set lider 1;
  set phase 0;

  while {$run} {
    set licznik [expr 2*pow($phase, 1)];
    if {$lider==1} {
      if {$licznik>0} {
        dostarcz 0 "req $phase $id_los $licznik";
        dostarcz 1 "req $phase $id_los $licznik";
      } else {
        dostarcz 0 "req $phase $id_los 1";
        dostarcz 1 "req $phase $id_los 1";
      }
    }

    fiber switchto main;

    while {$kom(0)!="" || $kom(1)!=""} {
      foreach x $kom(0) {
        # jeśli otrzymałem request z lewej (?) strony i jest skierowany do mnie
        if {[lindex $x 0]=="req" && [lindex $x 3]==1} {
          _puts "Wierzchołek nr $id, id_los: $id_los, wykonuje request. Nr fazy: $phase";
          # zapisz komunikat i usuń z listy komunikatów
          set wierz0 [czytajKomTypu [lindex $x 0] 0];
          # jeśli ID_losowe w komunikacie jest większe od mojego ID_los
          if {[lindex $wierz0 2] > $id_los} {
            # jeśli numer fazy jest większy od >= 1
            # warunek po to, aby w wyrażeniu expr nie pojawiał się wynik 0.0
            if {[lindex $wierz0 1] > 0} {
              # w komunikacie odsyłam numer fazy wierzchołka od którego dostałem komunikat
              # komunikat dostałem z połączenia 0, więc odsyłam tym samym połączeniem
              # nie wiem czy to jest poprawne rozumowanie?
              dostarcz 0 "res [lindex $wierz0 1] $id_los youAreLider [expr 2*pow([lindex $wierz0 1], 1)]";
              # dostarcz 0 "res [lindex $wierz0 1] $id_los youAreLider 2";
            } else {
              # jeśli komunikat pochodzi z fazy nr 0
              dostarcz 0 "res 0 $id_los youAreLider 1";
            }
            # skoro trafiłem w to miejsce to nie jestem liderem
            set lider 0;
          } else {
            # jeśli to ja mam większe ID_los od ID_los z odebranego komunikatu
            # UWAGA! zakładam, że wierzchołki mają różne ID_los
            if {[lindex $wierz0 1] > 0} {
              dostarcz 0 "res [lindex $wierz0 1] $id_los youAreNotLider [expr 2*pow([lindex $wierz0 1], 1)]";
            } else {
              dostarcz 0 "res 0 $id_los youAreNotLider 1";
            }
          }
        } elseif {[lindex $x 0]=="req" && [lindex $x 3] > 1} {
          _puts "To nie moja faza! Wierzchołek nr $id, id_los: $id_los";
          # jeśli otrzymałem request, ale NIE JEST skierowany do mnie
          set wierz0 [czytajKomTypu [lindex $x 0] 0];
          # zmniejsz licznik o -1
          lset wierz0 3 [expr [lindex $wierz0 3] - 1];
          # otrzymałem z połączenia nr 0 więc przekazuje połączeniem przeciwnym
          dostarcz 1 $wierz0;
        } elseif {[lindex $x 0]=="res" && [lindex $x 4] > 1} {
          set wierz0 [czytajKomTypu [lindex $x 0] 0];
          lset wierz0 4 [expr [lindex $wierz0 4] - 1];
          dostarcz 1 $wierz0;
        }
      }

      foreach y $kom(1) {
        # jeśli otrzymałem request z prawej (?) strony i jest skierowany do mnie
        if {[lindex $y 0]=="req" && [lindex $y 3]==1} {
          _puts "Wierzchołek nr $id, id_los: $id_los, wykonuje request. Nr fazy: $phase";
          # zapisz komunikat i usuń z listy komunikatów
          set wierz1 [czytajKomTypu [lindex $y 0] 1];
          # jeśli ID_losowe w komunikacie jest większe od mojego ID_los
          if {[lindex $wierz1 2] > $id_los} {
            # jeśli numer fazy jest większy od >= 1
            # warunek po to, aby w wyrażeniu expr nie pojawiał się wynik 0.0
            if {[lindex $wierz1 1] > 0} {
              # w komunikacie odsyłam numer fazy wierzchołka od którego dostałem komunikat
              # komunikat dostałem z połączenia 1, więc odsyłam tym samym połączeniem
              # nie wiem czy to jest poprawne rozumowanie?
              dostarcz 1 "res [lindex $wierz1 1] $id_los youAreLider [expr 2*pow([lindex $wierz1 1], 1)]";
            } else {
              # jeśli komunikat pochodzi z fazy nr 0
              dostarcz 1 "res 0 $id_los youAreLider 1";
            }
            # skoro trafiłem w to miejsce to nie jestem liderem
            set lider 0;
          } else {
            # jeśli to ja mam większe ID_los od ID_los z odebranego komunikatu
            # UWAGA! zakładam, że wierzchołki mają różne ID_los
            if {[lindex $wierz1 1] > 0} {
              dostarcz 1 "res [lindex $wierz1 1] $id_los youAreNotLider [expr 2*pow([lindex $wierz1 1], 1)]";
            } else {
              dostarcz 1 "res 0 $id_los youAreNotLider 1";
            }
          }
        } elseif {[lindex $y 0]=="req" && [lindex $y 3] > 1} {
          # jeśli otrzymałem request, ale NIE JEST skierowany do mnie
          set wierz1 [czytajKomTypu [lindex $y 0] 1];
          # zmniejsz licznik o -1
          lset wierz1 3 [expr [lindex $wierz1 3] - 1];
          # otrzymałem z połączenia nr 1 więc przekazuje połączeniem przeciwnym
          dostarcz 0 $wierz1;
        } elseif {[lindex $y 0]=="res" && [lindex $y 4] > 1} {
          _puts "Upss, to nie dla mnie. Przekażę to dalej..."
          set wierz1 [czytajKomTypu [lindex $y 0] 1];
          lset wierz1 4 [expr [lindex $wierz1 4] - 1];
          # przekaż dalej
          dostarcz 0 $wierz1;
        }
      }

      foreach x $kom(0) {
        foreach y $kom(1) {
          # jeśli w obu listach komunikatów mam komunikaty typu 'res', numery faz komunikatów są takiego same
          # i numery faz zgadzają się z moim numerem fazy
          if {[lindex $x 0]=="res" && [lindex $x 1]==[lindex $y 1] && [lindex $x 1]==$phase} {
            _puts "Wierzchołek nr $id, id_los: $id_los, wykonuje response. Nr fazy: $phase";
            # zapisz komunikaty i usuń z list komunikatów
            set wierz0 [czytajKomTypu [lindex $x 0] 0];
            set wierz1 [czytajKomTypu [lindex $x 0] 1];
            # poprawić po wprowadzeniu licznika
            if {[lindex $wierz0 4]=="youAreNotLider" || [lindex $wierz1 4]=="youAreNotLider"} {
              set lider 0;
            }
            # skoro tu trafiłem to mogę zwiększyć mój numer fazy
            set phase [expr $phase + 1];
          } elseif {[lindex $x 1]>$phase} {

          }
        }
      }
      fiber switchto main;
    }
  }
}

InicjalizacjaAsynch

proc wizualizacja {} {
  fiber_iterate {_puts "Wierzchołek nr $id, id_los: $id_los, lider: $lider, nr fazy: $phase, kom0: $kom0, kom1: $kom1"}
}

# ------ menu ------
fiber error
pokazKom
wizualizacja

fiber_eval 0 {set id_los 800}
fiber_eval 1 {set id_los 600}
fiber_eval 2 {set id_los 400}
fiber_eval 3 {set id_los 200}
fiber_eval 4 {set id_los 100}
fiber_eval 5 {set id_los 300}
fiber_eval 6 {set id_los 500}
fiber_eval 7 {set id_los 700}

fiber switchto 0; pokazKom
fiber switchto 1; pokazKom
fiber switchto 2; pokazKom
fiber switchto 3; pokazKom
fiber switchto 4; pokazKom
fiber switchto 5; pokazKom
fiber switchto 6; pokazKom
fiber switchto 7; pokazKom
