# Podstawowe własności funkcjonalne Tcl

Ustawianie zmiennej:
```tcl
wejście: set z 123
wyjście: 123
```

**Tcl** nie wykonuje wyrażeń arytmetycznych bezpośrednio.
```tcl
wejście: expr 3 + 12
wyjście: 15
```

Użycie zmiennej w wyrażeniu arytmetycznym:
```tcl
wejście: expr $z + 7
wyjście: 130
```

Symbole ujęte w cudzysłów tworzą jedno słowo.
Jeżeli część symboli łańcucha wewnątrz cudzysłowu zostanie objęta nawiasami kladratowymi, to wyrażenie zawarte w tych nawiasach zostanie wykonane przed dalszą operacją na łańcuchu.
```tcl
wejście: set slowo "To jest przykładowe słowo"
wyjście: "To jest przykładowe słowo"

wejście: set dcal 25
wyjście: 25
wejście: set dcm "Długość wynosi [expr $dcal*2,54] cm"
wyjście: Długość wynosi 63.5 cm
```
Znaki specjalne, takie jak nawias kwadratowy, znak dolara itd. wewnątrz cudzysłowu są interpretowane zgodnie ze swym szczególnym znaczeniem.  
Sam znak cudzysłowu może być elementem wewnątrz grupy, gdy zostanie poprzedzony **znakiem cytowania**, czyli ukośnikiem zwrotnym '\'.
  
W **grupowaniu klamrami** znaki specjalne Tcl tracą swoje znaczenie i są traktowane literalnie.
```tcl
wejście: set dcm {Długość wynosi [expr $dcal*2.54] cm}
wyjście: Długość wynosi [expr $dcal*2.54] cm
```
Efekt grupowania klamrami jest zniesiony, gdy klamry występują w łańcuchu objętym cudzysłowem.
  
**Wyrażenie warunkowe _if then else_** wygląda następująco:
```
if {warunek} {
skrypt1
} else {
skrypt2
}
```
Na przykład:
```tcl
wejście: if {10>5} {set z 125} else {set z 120}
wyjście: 125
```
**Skruktura procedury**:
```
proc F-na-C {F} {
set wy [expr $F-32]
return [expr $wy*5/9]
}
```
Powyższy skrypt posiada:
* nazwę procedury _F-na-C_
* listę argumentów (jeden element _F_)
* ciało procedury (ujęte w klamry)

Na przykład:
```tcl
wejście: proc F-na-C {F} {set wy [expr $F-32]; return [expr $wy*5/9]}
wejście: F-na-C 50
wyjście: 10
```
**Komentarz** w ciele skryptu jest poprzedzany znakiem **#**. Wiersz taki może występować jedynie w miejscu, gdzie analizator Tcl spodziewa się początku polecenia.
```tcl
wejście: #set x 25
wyjście: 
wejście: set x 25 #ustawiam zmienną x
wyjście: wrong # args: should be "set varName ?newValue?"
```
Operowanie **podprocesami** polega na uruchomieniu innych aplikacji; po ich uruchomieniu aplikacja wyjściowa może się komunikować z bieżącymi aplikacjami.  
Wykonanie polecenia:
```tcl
wejście: exec p3 main
```
uruchamia podproces o nazwie p3 z argumentem _main_; symbol _p3_ jest _nazwą programu_ wykonawczego. Polecenie _exec_ oczekuje do zakończenia procesu p3, po czym zwraca określoną wartość.

**Polecenia wbudowane**
```
NAZWA       WYJAŚNIENIE
after       ustawia polecenie Tcl do późniejszego wykonania
append      dołącz argumenty do wartości zmiennej; bez dodawania spacji
array       bada stan stablicy
binary      konwersja łańcucha na postać binarną
break       wyjście z pętli wykonawczej
catch       chwytanie błędów
cd          zmiena katalogu roboczego
clock       podaje czas i datę
close       zamyka otwarty strumień danych wejścia/wyjścia
concat      konkatenacja argumentów ze specją pomiędzy nimi
console     ustawia konsolę do dialogowego wprowadzania poleceń
continue    wykonanie następnej iteracji w pętli
error       wnosi błąd
eof         bada warunek końca pliku
eval        konkatenacja argumentów i ich ewaluacja jako polecenia
exec        rozwidla i wykonuje program w Unixie
exit        kończy proces
expr        ewaluacja wyrażenia arytmetycznego
fblocked    bada kanał wejścia/wyjścia sprawdzając gotowość danych
fconfigure  ustawia i bada własności kanału wejścia/wyjścia
fcopy       kopiowanie pomiędzy kanałami wejścia/wyjścia
file        badanie systemu plikowego
flush       spłukuje wyjście z wewnętrznego buforu strumienia wejścia/wyjścia
for         tworzy pętlę na podobieństwo wyrażenia for w języku C
foreach     tworzy pętlę na liście (listach) wartości
format      formatuje łańcuch, podobnie jak sprintf w C
gets        czyta wiersz wejściowy ze strumienia wejścia/wyjścia
glob        rozszerza wzór w celu dopasowania do nazw plików
global      deklaruje zmienne globalne
history     zwraca historię wiersza poleceń
if          bada warunek, uwalnia klauzulę else lub elseif
incr        zwiększa wartość zmiennej o wartość całkowitą
info        bada stan interpretatora Tcl
interp      tworzy dodatkowy interpretator Tcl
join        konkatenacja elementów listy z określonym separatorem pomiędzy nimi
lappend     dodaje elementy na koniec listy
lindex      dostarcza element z lsity
linsert     wprowadza element do listy
list        tworzy listę z argumentów
llength     zwraca liczbę elementów w liście
load        ładuje wspólne biblioteki z definicją poleceń Tcl
lrange      zwraca zakres elementów listy
lreplace    zamienia elementy w liście
lsearch     wyszukuje element z listy pasujących do wzoru
lsort       sortuje listę
namespace   tworzy przestrzeń nazw
open        otwiera plik lub subproces dla operacji wejścia/wyjścia
package     dostarcza lub żąda pakietów kodowych
pid         zwraca identyfikator procesu
proc        definicja procedury Tcl
puts        wyprowadza łańcuch znaków do strumienia wejścia/wyjścia
pwd         zwraca bieżący katalog roboczy
read        czyta bloki znaków ze strumienia wejścia/wyjścia
regexp      dopasowuje wyrażenie regularne
regsub      podmienia symbol bazując na wyrażeniu regularnym
rename      zmienia nazwę polecenia Tcl
scan        analizuje łańcuch zgodnie ze specyfikacją formatu
seek        ustala punkt startu w strumieniu wejścia/wyjścia
set         przypisuje wartość do zmiennej
socket      otwiera kanał sieciowy TCP/IP
source      wprowadza do konsoli plik procedury i dokonuje jej ewaluacji
split       tnie łańcuch na elementy listy
string      operacje na łańcuchach
subst       podmienia polecenia włożone i odniesienia zmiennych
switch      bada warunki
tell        zwraca bieżący punkt startowy w strumieniu wejścia/wyjścia
time        mierzy czas wykonania polecenia
trace       sprawdza przypisania zmiennej
unknown     obsługuje polecenia nieznane
unset       usuwa zmienne
uplevel     wykonuje polecenie dla innej widoczności
upvar       odniesienie do zmiennej w innej widoczności
variable    deklaruje zmienne przestrzeni nazw
vwait       powoduje czekanie na zmianę wartości zmiennej
while       działanie pętli aż do fałszywej wartości wyrażenia boolowskiego
```