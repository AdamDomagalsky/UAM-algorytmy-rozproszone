Zadania z ćwiczeń z przedmiotu 'Algorytmy rozproszone'. Prowadzącym przedmiot był dr hab. Michała Hanćkowiaka.

# Treści zadań

## Temat A

**Zadanie -1 (inż.) "polecenie fiber"**

Zbadaj w konsola2c, jak działa polecenie fiber,
będące podstawą "symulatora algorytmów rozproszonych" używanego na tych zajęciach...
użyj przykładów: events03.tcl, events03a.tcl

**Zadanie 0 (impl.) "pierwszy test symulatora"**

Spróbuj uruchomic w konsoli (konsola2c.tcl)
pierwszy z brzegu przykład z tutoriala symulatora...

**Zadanie 1 (impl.) "leader election O(n^2)"**

Zaimplementuj w symulatorze algorytm asynchroniczny wyboru lidera,
uzywający O(n^2) komunikatów, dla ringu zorientowanego.
Uwaga: uzyj symulatora algorytmow synchronicznych, mimo że
algorytm jest asynchroniczny! (początkowo tak będziemy postępować stale).

**Zadanie 1a (impl.) "leader election O(n^2)"**

Zaimplementuj w symulatorze algorytm asynchroniczny wyboru lidera
uzywający O(n^2) komunikatów, dla ringu NIEzorientowanego.

**Zadanie 2 (impl.) "C&V (8 kolorów)"**

Zaimplementuj w symulatorze algorytm synchroniczny C&V
znajdujący 8-kolorowanie wierzchołkowe drzewa ukorzenionego

**Zadanie 3 (impl.) (dla chętnych) "leader election O(n logn)"**

Zaimplementuj w symulatorze algorytm asynchroniczny wyboru lidera,
uzywający O(n logn) komunikatów, dla ringu zorientowanego.
Podobnie jak poprzednio użyj symulatora synchronicznego!

**Zadanie 8 (impl.) "suma ID"**

Zaimplementuj algorytmy synchroniczne obliczające sumę ID w ringu (ma być znana na wszystkich wierz!),
   alg 1: wysyłający O(n) komunikatów,
   alg 2: działający w O(n) rundach.
Nie zakłada się niczego szczególnego o ID;
oba algorytmy powinny się konczyć "równocześnie" na wszystkich wierzchołkach;
zakłada się, że ring jest zorientowany, a wierzchołki znają "n".

## Temat B

**Zadanie 17 (impl.) "LE, O(n^2)-komunikatów, model asynch"**

Zaimplementuj prosty algorytm wyboru lidera w cyklu zorientowanym,
ale tym razem w modelu/symulatorze asynchronicznym!
Zbuduj egzekucję asynchroniczna pokazującą działanie algorytmu...
Aby to nie był dokładnie taki sam algorytm jak w tutorialu, wprowadźmy pewne zmiany:
1) niech liderem będzie wierz z min ID,
2) niech będzie używany mechanizm zapamiętywania min zobaczonego ID na każdym wierzchołku,
3) nie używaj komendy czytajKomTypu.

**Zadanie 22 (impl.) (dla chętnych) "leader election O(n logn) - impl. asynchroniczna !"**

Zaimplementuj asynch. algorytm wyboru lidera, używający O(n logn) komunikatów, w symulatorze asynchronicznym...
(Poprzednio, w temacie A, robiliśmy to w symulatorze synchronicznym!)
Oprócz algorytmu trzeba będzie także wygenerować sensowną egzekucję!

**Zadanie 28 (impl.) "drzewo BFS"**

Zaimplementuj synchroniczny algorytm budujący drzewo BFS w zadanym wierzchołku "r".
Drzewo BFS to takie drzewo ukorzenione, w którym dla każdego wierzchołka v
ścieżka skierowana po drzewie od v do r jest najkrótsza...
Oszacuj liczbę komunikatów i czas działania algorytmu.

**Zadanie 30 (impl.) "synchronizator alfa"**

Zaimplementuj synchronizator alfa i zbadaj jaki jest numer rundy na różnych wierzchołkach,
w czasie działania algorytmu:
```
   set liczRundy 0
   while 1 {
      incr liczRundy
      // wstawka realizująca "koniec rundy"
   }
```
Wskazówka: dla ułatwienia użyj komendy "dostarcz" zamiast "wyslij", dzięki czemu
trzeba genereować jedynie zdarzenia obliczeniowe (a nie obliczeniowe i dostarczenia),
czyli nie jest konieczne używanie dostarczKom.

Uwaga 1: używanie komendy "czytajKomTypu SAFE * pol" jest niebezpieczne, gdyż
usuwa ona komunikaty z kolejek komX... dlatego lepiej opracowac własną proceurę sprawdzania
czy wierzchołek jest bezpieczny operującą bezpośrednio na zmiennych komX
(zainstalowac ją przy pomocy fiber_iterate { proc ... }).

Uwaga 2: przypominam, że w synchronizatorze alfa komunikaty alg. synchronicznego są
dostarczane z potwierdzeniem (niezaleznie od komunikatów SAFE),
zatem używanie dostarcz zamiast wyslij jest tym bardziej uzasadnione...

Uwaga 3: w modelu asynch. wszystkie wierzchołki MUSZĄ działać w nieskończoność !!!
gdyż jeśli jakiś fiber kończy pracę to wykonuje "fiber yield" zamiast "fiber switchto main";
jest to "pozostałość" po symulatorze synch, która nie została jeszcze naprawiona (15.11.2016)

Uwaga 4: najłatwiej zrobić eksperyment do tego zadania w cyklu...
(ale procedure "koniec rundy" lepiej napisać ogólnie!)

**Zadanie 31 (impl.) "synchronizator beta"**

Zaimplementuj synchronizator beta...
Założenie upraszczające: drzewo spinające graf jest dane z góry!
Eksperyment może być taki sam jak w zadaniu 30, czyli obserwujemy liczniki rund.

**Zadanie 34 (impl.) "Consensus"**

Zaprojektuj eksperyment pokazujący nietrywialne działanie algorytmu Consensus...
Nasz symulator nie jest przystosowany do algorytmow synch. "psujących się w połowie rundy", dlatego
najlepiej użyc proc. blad {nrRundy iteracja}, ktora generuje blad fibera przy pomocy error "crash",
w odpowiednio dobranej chwili (patrz tutaj)
Uwaga: przez "nietrywialne działanie" rozumiemy takie, w którym coś się zmienia
także w ostatnich iteracjach pętli for...
