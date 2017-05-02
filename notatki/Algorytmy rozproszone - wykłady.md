# Message Passing Systems

>W materiałach wymiennie stosuję pojęcia **procesor** oraz **wierzchołek**. Wynika to z reprezentacji modelu typu Message Passing System jako grafu.

System ten jest przedstawiany jako graf komunikacyjny, gdzie wierzchołki (kropki, punkty) reprezentują procesory, a (nieskierowane) krawędzie reprezentują dwukanałowe (wysyłanie i odbieranie) połączenie pomiędzy procesorami.

Każdy procesor jest niezależny. Posiada swoją lokalną pamięć, oraz uruchomiony lokalny program (proces). Każdy program posiada wewnętrzne operacje: wysyłanie wiadomości (do sąsiędnich programów), oraz czekanie na wiadomość (od sąsiednich programów). Zdarzenia dzielimy na:
* _obliczeniowe_ - są to lokalne obliczenia **i** wysłanie komunikatów
* _dostarczenia komunikatu_

>Pytanie do prowadzącego: w naszym kodzie do zadania nr 1 najpierw wysyłamy odpowiedni komunikat, dopiero później wykonujemy fiber yield. Czy to oznacza, że nieświadomie zmodyfikowaliśmy pojęcie rundy? Czy ten kod jest poprawny? Czy wykonanie najpierw fiber yield jest "bardziej prawidłowe" według definicji?

Algorytm w modelu Message Passing to zbiór lokalnych programów różnych procesorów. Wykonanie algorytmu to naprzemienne wykonanie lokalnych programów.

Graf komunikacyjny może przyjmować różne postacie, np. pierścienia (cyklu, ang. _ring_), _clique_ (nie mam pewności - jest to graf, gdzie każdy wierzchołek jest tego samego stopnia), itd.

**Stopień synchronizacji**:
* _synchroniczny_ - obliczenia są dzielone na **rundy**. W pierwszej rundzie każdy procesor wysyła wiadomości i czeka na otrzymanie wiadomości od swojego sąsiada. Po otrzymaniu wiadomości każdy procesor wykonuje wewnętrzne operacje i decyduje jaki komunikat wysłać sąsiadom w następnej rundzie. **W każdej rundzie, każdy wierzchołek ma jedno zdarzenie obliczeniowe**.
* _asynchroniczny_ - procesory wykonują obliczenia niezależnie (działają "samowolnie", bez czekania na początek i koniec rundy), co może trwać niekiedy bardzo długo (opóźnienie może być nieprzewidywalne i bardzo długie, lecz komunikat w końcu dotrze do docelowego procesora).

**Stopień symetrii**:
* _anonimowe_ systemy to takie, w których każdy procesor jest identyczny do pozostałych (nie posiada indywidualnych parametrów, takich jak np. ID). Lokalny program jest identyczny dla każdego procesora.
* _nieanonimowe_ systemy to takie, w których wierzchołki posiadają indywidualne parametry (np. ID), zatem mogą posiadać różne lokalny programy.

**Jednorodność**:
* w _jednorodnych_ (ang. _non-uniform_) systemach, każdy procesor zna liczbę wierzchołków w grafie, zatem może uruchamiać różne programy z uwzględnieniem rozmiaru systemu.
* w _niejednorodnych_ (ang. _uniform_) systemach, procesory nie znają liczby wierzchołków grafu. W konsekwencji uruchamiają dokładnie ten sam program bez względu na rozmiar systemu.

> Czy istnieje system, który jest synchroniczny, nieanonimowy i niejednorodny? Według mnie **nie istnieje**. Dlaczego? Bo jeśli jest to system nieanonimowy, to znane są ID wierzchołków. A skoro znam ID wierzchołków to wiem również ile jest tych wierzchołków.
> To pytanie można zadać również w inny sposób - czy wierzchołek zna ID wszystkich wierzchołków grafu, czy tylko ID swoich sąsiadów? A jeśli zna ID tylko swoich sąsiadów, to czy możliwe jest stworzenie algorytmu, który zliczy liczbę wszystkich wierzchołków (nie tylko w cyklu!)?

## Leader Election in Rings

Cykle są bardzo wygodną strukturą dla systemów typu Message Passing. Mają również swoje zastosowania w realnym świecie.

### Problem

Każdy lokalny program posiada zmienną typu Boolean, która mówi nam, czy procesor jest lub nie jest liderem. Po zakończeniu działa algorytmu n-1 procesorów powinno w tej zmiennej posiadać wartość _false_, natomiast tylko jeden procesor powinnien posiadać wartość _true_.

Musimy też znać warunek bycia liderem np. możemy wybierać lidera według najwyższego lub najniższego ID w grafie. Oczywiście zakładając, że system jest nieanonimowy!

**Zakładamy, że graf (cykl) jest zorientowany!** (np. prawa krawędź służy do wysyłania komunikatów, a lewa krawędź służy do odbierania komunikatów)

> **Czy możemy znaleźć lidera w grafie anonimowym?** Jaki może być przykładowy warunek bycia liderem? Największa losowo generowana liczba?

Odpowiedź do powyższego pytania: teoretycznie w trakcie startu systemu wszystkie procesory mają taki sam stan, zatem w pierwszym wysłaniu komunikatów (inicjującym system) każdy procesor wysyła dokładnie takie same komunikaty. Każdy procesor posiada identyczny program do pozostałych procesorów, zatem wykonuje takie same obliczenia, czyli w odpowiedzi na nadesłane komunikaty w każdej rundzie wszystkie procesory wysyłają takie same komunikaty. Jeśli jakiś procesor zdecyduje się zakończyć działanie algorytmu, na taką samą decyzję zdecydują się pozostałe procesory. Wniosek jest taki, że nie da się wybrać lidera w systemie anonimowym.

> Może to głupie pytanie, ale czy wygenerowanie liczby losowo na każdym procesorze i traktowanie tego jako 'ID' zmienia system z anonimowego na nieanomowy?
