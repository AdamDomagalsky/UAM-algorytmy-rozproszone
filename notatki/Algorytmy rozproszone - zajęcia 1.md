# Ćwiczenia

## Zadania z symulatora ALR31S

Wierzchołki sieci są od siebie **odizolowane**. Są interpreterami logicznymi i fiberami.  
Wierzchołek (np. "V") posiada następujące zmienne, które są zmiennymi globalnymi języka Tcl:
* _id_
* _id_los_ - duża liczba wybrana losowo (czyli liczby mogą się powtórzyć między wierzchołkami)
* _liczbaWierz_
* _stopień_ - stopniem wierzchołka jest liczba jego sąsiadów
* _kom_ (_kom(0)_, _kom(1)_, ...) - tablica asocjacyjna języka Tcl; zmienna _kom(X)_ zawiera listę komunikatów otrzymanych w poprzedniej rundzie od sąsiada, poprzez połączenie nr X (z punktu widzenia wierzchołka "V")

Zmienne _kom0_, _kom1_, ... są przestarzałe, zastąpiły je _kom(0)_, _kom(1)_, ...

Komunikaty wysyłamy połączeniem X przy pomocy:
```tcl
wyslij X $msg
np. wyslij 0 "ABC"
np. wyślij $i $msg
```

Pierwszy komunikat z _kom(X)_ zdejmujemy przy pomocy:
```
czytaj X
np. set msg [czytaj $i]
```

Symulacja **modelu synchronicznego**.  
Na początek tworzymy tyle fiberów ile jest wierzchołków sieci, oraz definiujemy program główny:
```
fiber create $liczbaWierz {
    program główny
}
```
Koniec rundy jest oznaczany w programie _wierzchołka/fibera_ przez:
```
fiber yield
```
Pojedyncze rundy uruchamiamy przy pomocy:
```
fiber yield; runda
```
Jeżeli chcemy stworzyć procedurę, która ma być dostępna dla wszystkich fiberów, powinniśmy użyć:
```
fiber_iterate {definicja procedury}
```

Symulacja modelu **asynchronicznego**.
Na początek tworzymy tyle fiberów ile jest wierzchołków sieci, oraz definiujemy program główny (patrz wyżej).  
Następnie generujemy _zdarzenie obliczeniowe_ przy pomocy:
```
fiber switchto $id
```
Zdarzenie to kończy się _w kodzie algorytmu_ przy pomocy:
```
fiber switchto main
```
W kolejnym kroku generujemy _"zdarzenia dostarczenia komunikatu"_ przy pomocy:
```
dostarczKom $id $i
```
gdzie _$i_ to numer połączenia.  
Warto zauważyć, że _istnieje procedura "dostarcz"_ (działająca tak jak procedura "wyślij"), dzięki której nie ma potrzeby generowania zdarzenia dostarczenia poprzez "dostarczKom".

Aby spowodować koniec działania fibera należy **sprowokować błąd** (np. usunąć zmienną - warunek pętli while).

Zapętlenie się jednego fibera powoduje **zapętlenie całego symulatora**!

Komenda _fiber_eval_ wykonuje kod w danym fiberze na poziomie globalnym, np.:
```
wzór: fiber_eval $id $kod

wejście: fiber_eval 0 {set x 123}
```
Fiber o numerze id równym 0 będzie miał zmienną globalną x.

Program główny **można zmienić bez usuwania fiberów** przy pomocy:
```
fiber code {nowy program główny}
```
Jednak nowy program główny zacznie obowiązywać dopiero, gdy wszystkie fibery zakończą stary program główny.

### Pierwszy przykład - model synchroniczny
W tym przykładzie po sieci krąży token zawierający zmienną typu INT, której wartość zwiększa się o 1 po każdym skoku.

Kod:
```tcl
source symul_lib.tcl;   # ładowanie symulatora

# domyślam się, że definicja 'wyslij', oraz 'Inicjalizacja' znajduje się
# w pliku symul_lib.tcl
 
# tworzymy graf komunikacyjny (w tym wypadku cykl)
set liczbaWierz 5
set sasiedzi(0) {4 1}
set sasiedzi(1) {0 2}
set sasiedzi(2) {1 3}
set sasiedzi(3) {2 4}
set sasiedzi(4) {3 0}

# tworzymy tyle fiberów ile jest wierzchołków
# definiujemy program główny
fiber create $liczbaWierz {
  if {$id==0} {
    wyslij 1 0;     # wysyła połączeniem nr 1 komunikat "0"
  }
  fiber yield;      # oznacza koniec rundy
 
  #zmienna run pozwala zakończyć działanie symulacji
  while {$run} {
    if {$kom0!=""} {
      set x $kom0;
      incr x;
      wyslij 1 $x;
      # alternatywnie: kom1_wyslij $x
    }
    fiber yield;    # oznacza koniec rundy
  }
}
 
Inicjalizacja;      # koniecznie trzeba to wywolac!

# tę procedurę wywołujemy z konsoli po każdej rundzie
proc wizualizacja {} {
  fiber_iterate {_puts "$id: $kom0, $kom1"}
    # pętla fiber_iterate iteruje po wszystkich fiberach
}

if 0 {
set_run 0; fiber yield; runda; set_run 1; fiber delete
  # usuwanie fiberow
set_run 0; fiber yield; runda; set_run 1; fiber restart
  # restart kodu fiberow
fiber error
  # wyswietla stan fiberow ({}, ended, error)
fiber_eval 0 {set id}
  # wykonanie kodu w fiberze 0
  # UWAGA: fiber_eval wykonuje kod na poziomie globalnym
  # "fiber0 eval {set id}" wykonuje kod tam gdzie fiber został zamrożony
}
 
fiber yield; runda; wizualizacja
  # wykonuje kolejna runde...
  # procedura runda obsługuje komunikaty
```