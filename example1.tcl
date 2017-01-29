# przyklad symulacji modelu asynchronicznego
# w tym przykładzie wierzchołki wysyłąją i przekazują komunikaty postaci "Q $id_los"

# ------ początek programu ------

source symul_lib.tcl

# ustawienie zmiennej globalnej liczbaWierz
set liczbaWierz 20

# tworzenie grafu (na podstawie liczbaWierz)
# np. pętla "iterate i 10" iteruje od 0 do 9
iterate i $liczbaWierz {
  let i1 $i-1; if {$i1==-1} {let i1 $liczbaWierz-1}
  let i2 $i+1; if {$i2==$liczbaWierz} {let i2 0}
  set sasiedzi($i) "$i1 $i2"
}

# program główny, instalowany na wszystkich wierzchołkach
fiber create $liczbaWierz {
    wyslij 1 "Q $id_los"
    # kom1_wyslij "Q $id_los"
    fiber switchto main
    # aby zakończyć działanie fibera trzeba spowodować błąd
    # po usunięciu zmiennej "run" wystąpi błąd i fiber przestanie działać
    while {$run} {
      if {$kom0!=""} {
        # komenda "czytaj X" zdejmuje pierwszy komunikat z kom(X)
        set x [czytaj 0]
        wyslij 1 $x
        # kom1_wyslij $x
      }
      fiber switchto main
    }
}
InicjalizacjaAsynch

proc wizualizacja {} {
  fiber_iterate {_puts "$id, $id_los, $lider; $kom0, $kom1"}
}

# ------ koniec programu ------

# ------ menu ------
fiber error
pokazKom
# ------------------

# ------ egzekucja ------
# egzekucja to ciąg zdarzeń "obliczeniowych" i "dostarczenia komunikatu"
# zdarzenie obliczeniowe ma postać "fiber switchto nr_wierzchołka"
# zdarzenie dostarczenia komunikatu ma postać "dostarczKom nr_wierz nr_połączenia"
fiber switchto 8; pokazKom
# wysłanie "Q id_los" połączeniem nr 1 do wierzchołka nr 9
dostarczKom 9 0; pokazKom
# dostarczenie "Q id_los" w wierzchołku nr 9
fiber switchto 9; pokazKom
# wysłanie "Q id_los_2" połączeniem nr 1 do wierzchołka nr 10
fiber switchto 10; pokazKom
# wysłanie "Q id_los_3" połączeniem nr 1 do wierzchołka nr 11
dostarczKom 10 0; pokazKom
# dostarczenie "Q id_los_2" w wierzchołku nr 10
fiber switchto 9; pokazKom
# wysłanie "Q id_los" połączeniem nr 1 do wierzchołka nr 10
# wierzchołek nr 9 przekazuje komunikat, który otrzymał z wierzchołka nr 8 do wierzchołka nr 10
dostarczKom 10 0; pokazKom
# dostarczenie "Q id_los" w wierzchołku nr 10
fiber switchto 10; pokazKom
# wysłanie "Q id_los_2" połączeniem nr 1 do wierzchołka nr 11
fiber switchto 10; pokazKom
# wysłanie "Q id_los" połączeniem nr 1 do wierzchołka nr 11
dostarczKom 11 0; pokazKom
# dostarczenie "Q id_los_3" w wierzchołku nr 11
dostarczKom 11 0; pokazKom
# dostarczenie "Q id_los_2" w wierzchołku nr 11
dostarczKom 11 0; pokazKom
# dostarczenie "Q id_los" w wierzchołku nr 11
# ------ koniec egzekucji ------
