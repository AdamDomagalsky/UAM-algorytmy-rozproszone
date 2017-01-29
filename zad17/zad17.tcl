# algorytm LE, O(n^2), model asynchroniczny

# liderem jest wierzchołek o najmniejszym ID
# każdy wierzchołek ma pamiętać najmniejsze 'zobaczone' przez niego ID
# bez użycia komendy czytajKomTypu

source symul_lib.tcl

set liczbaWierz 5
iterate i $liczbaWierz {
  let i1 $i-1; if {$i1==-1} {let i1 $liczbaWierz-1}
  let i2 $i+1; if {$i2==$liczbaWierz} {let i2 0}
  set sasiedzi($i) "$i1 $i2"
}

fiber create $liczbaWierz {
    set lider {};
    set minID {};

    # przechodzę do następnego wierzchołka
    # chodzi tylko o to, żeby przed losowaniem wierzchołków w egzekucji
    # były zadeklarowane zmienne 'lider' i 'minID' potrzebne
    # w procedurze 'wizualizacja'
    fiber yield;

    # ponieważ cykl jest zorientowany, wysyłam tylko jednym połączeniem
    # zakładam, że komunikaty wysyłam połączeniem 0, a odbieram połączeniem 1
    dostarcz 0 "LE $id";

    while {$run} {
      set msg [lindex [czytaj 1] 1];

      if {$msg!=""} {
        if {$msg<$id} {
          dostarcz 0 "LE $msg";
          set minID $msg;
        } elseif {$msg==$id} {
          set lider 1;
          set minID $msg;
          dostarcz 0 "LE false";
        } elseif {$msg=="false" && $lider=={}} {
          set lider 0;
          dostarcz 0 "LE false";
        }
      }
      fiber switchto main;
    }
}
InicjalizacjaAsynch

proc wizualizacja {} {
  fiber_iterate {_puts "$id, $lider, $minID, $kom0, $kom1"}
}

# globalny licznik potrzebny do poprawnej wizualizacji
global licznik;
set licznik 0;

proc egzekucja {liczbaWierz licznik args} {
  set random [expr {int(rand()*[expr $liczbaWierz+1])}];
  for {set i 0} {$i < $liczbaWierz} {incr i} {
    if {$i!=$random && $licznik!=0} {
      _puts "Wierzchołek $i działa"
      fiber switchto $i;
    } elseif {$licznik==0} {
      _puts "Wierzchołek $i działa"
      fiber switchto $i;
      set licznik [expr $licznik + 1];
    }
  }
}

egzekucja $liczbaWierz $licznik; wizualizacja;

fiber error
pokazKom
