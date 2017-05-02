source symul_lib.tcl

set liczbaWierz 20
iterate i $liczbaWierz {
  let i1 $i-1; if {$i1==-1} {let i1 $liczbaWierz-1}
  let i2 $i+1; if {$i2==$liczbaWierz} {let i2 0}
  set sasiedzi($i) "$i1 $i2"
}

fiber create $liczbaWierz {
    while {$run} {
      set iAmSafe 0;

      # wysyłanie komunikatu z ID do wszystkich sąsiadów
  		for {set i 0} {$i < $stopien} {incr i} {
  			dostarcz $i $id;
  		}

      fiber switchto main;

      # ponieważ używam komendy 'dostarcz' w poprzednim kroku zakładam,
      # że otrzymałem potwierdzenie odebrania komunikatu
      for {set i 0} {$i < $stopien} {incr i} {
  			czytaj $i;
  		}

      # ponieważ 'odebrałem' potwierdzenie dostarczenia komunikatu
      # wysyłam komunikat 'SAFE'
      for {set j 0} {$j < $stopien} {incr j} {
  			dostarcz $j "SAFE";
  		}

      fiber switchto main;

      while {$iAmSafe == 0} {
        set licznik 0;

        for {set i 0} {$i < $stopien} {incr i} {

          # jeśli pierwszym elementem listy kom($i) jest komunikat "SAFE"
          if {[lindex $kom($i) 0]=="SAFE"} {
            # zwiększ licznik
            incr licznik;
          }

          # jeśli licznik jest równy stopniowi wierzchołka
          # czyli jeśli otrzymałem "SAFE" od każdego sąsiada
          if {$licznik == $stopien} {
            # jestem bezpieczny, mogę przejść do kolejnego pulsu
            set iAmSafe 1;

            # usuwam komunikaty "SAFE" z list
            for {set j 0} {$j < $stopien} {incr j} {
              czytaj $j;
            }
          } else {
            set iAmSafe 0;
          }
    		}
        fiber switchto main;
      }
    }
}

InicjalizacjaAsynch

fiber error

pokazKom

fiber switchto 0; pokazKom
fiber switchto 1; pokazKom
fiber switchto 2; pokazKom
fiber switchto 3; pokazKom
fiber switchto 4; pokazKom
fiber switchto 5; pokazKom
fiber switchto 6; pokazKom
fiber switchto 7; pokazKom
