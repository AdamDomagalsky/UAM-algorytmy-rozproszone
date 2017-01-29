# przyklad symulacji modelu asynchronicznego
# algorytm wyboru lidera, używający O(n^2) komunikatów

# ------ UWAGA! ------
# w symulatorze asynchronicznym wierzchołki powinny pracować "w nieskończoność"
# symulację wyłączamy "ręcznie" gdy stwierdzimy, że nie wysyła się już żadnych komunikatów
# --------------------

# ------ początek programu ------

source symul_lib.tcl

set liczbaWierz 20
iterate i $liczbaWierz {
  let i1 $i-1; if {$i1==-1} {let i1 $liczbaWierz-1}
  let i2 $i+1; if {$i2==$liczbaWierz} {let i2 0}
  set sasiedzi($i) "$i1 $i2"
}

fiber create $liczbaWierz {
    set lider {}
    wyslij 1 "LE $id_los"
    # kom1_wyslij "LE $id_los"
    while {$run} {
      # procedura czytajKomTypu {typ nr_połączenia} czeka na komunikat typu $typ z połączenia $nr_połączenia
      # podanie jako parametru * (gwiazdki/znaku mnożenia) oznacza dowolny typ lub dowolny numer połączenia
      # zwraca cały komunikat, łącznie z typem
      # komunikat jest usuwany ze zmiennej kom($nr_połączenia)
      # jako trzeci parametr można podać zmienną, w której otrzymamy numer połączenia (ale który?)
      # lindex {lista} nr_indeksu zwraca element listy; nr_indeksu jest numerowany od 0
      _puts "Tutaj jestem 3"
      set id0 [lindex [czytajKomTypu * *] 1]
      _puts "Tutaj jestem 4"
      if {$id0>$id_los} {
        kom1_wyslij "LE $id0"
      } elseif {$id0==$id_los} {
        set lider 1; kom1_wyslij "LE -1"
      } elseif {$id0==-1 && $lider=={}} {
        set lider 0; kom1_wyslij "LE -1"
      }
    }
}
InicjalizacjaAsynch

proc wizualizacja {} {
  fiber_iterate {_puts "$id, $id_los, $lider, $kom0, $kom1"}
}

# ------ koniec programu ------

# ------ menu ------
fiber error
pokazKom
# ------------------

# ------ egzekucja ------
fiber switchto 8; pokazKom
dostarczKom 9 0; pokazKom
