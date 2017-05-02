#
# konsola do wygodnego wydawania polecen
#

# co jeszcze warto zrobic?
# + ???

# uwagi:
# + pod tclkit konieczne "package re Tk" !

# klawisze:
#   Ctrl+S - save
#   Ctrl+O - open
#   Ctrl+Z - undo

# ---
set rozmiar 16

# ---
package re Tk

# zmiana rozmiaru fontu (jest z tym problem!)
#
proc kons_font _rozmiar {
  global rozmiar
  set rozmiar $_rozmiar
  .konsola.tNum configure -font "system $rozmiar"
  .konsola.t configure -font "system $rozmiar"
  .output.t configure -font "system $rozmiar"
}
proc font+ {} {
  global rozmiar; incr rozmiar; kons_font $rozmiar
}

# okienko toplevel konsola
#
destroy .konsola .output
  # dzieki temu mozna wielokrotnie source-owac z jednego wish-a
toplevel .konsola

# numeracja linii glownego okna text
#
text .konsola.tNum -width 3 -height 20 -font "system $rozmiar"
pack .konsola.tNum -side left -fill y

proc obsluga_t {p1 p2} {
  set nr [.konsola.t index @0,0]
  set nr2 [string range $nr 0 [expr [string first "." $nr]-1]]

  pokazNum $nr2

  .konsola.s set $p1 $p2
    # obsluga scrollbar-a
}
proc pokazNum {start} {
  .konsola.tNum delete 1.0 end
  for {set i 1} {$i<=50} {incr i} {
    .konsola.tNum insert end "$start\n"; incr start
  }
    # skad wiadomo ile linii tekstu jest widocznych w widgecie text ???
}
bindtags .konsola.tNum {nic}
  # to wylacza obsluge zdarzen w .konsola.tNum
bind nic <Control-Tab> [bind Text <Control-Tab>]

# glowne okno
#
text .konsola.t -undo 1 -width 60 -height 30 -font "system $rozmiar"
pack .konsola.t -side left -expand yes -fill both
focus .konsola.t

scrollbar .konsola.s
pack .konsola.s -side left -fill y
#.konsola.t config -yscroll ".konsola.s set"
.konsola.s config -command ".konsola.t yview"

.konsola.t config -yscrollcommand obsluga_t

# def tag-a "wynik" sluzacego do pokazywania wyniku komend
#
.konsola.t tag configure wynik -background yellow
.konsola.t tag configure wynik2 -background green

# def reakcje na klawisz Control+Return
#
bind .konsola.t <Control-Return> {
  # wykonujemy albo podswietlony tekst albo linie na ktorej jest kursor
  set t_sel ""
  catch { set t_sel [.konsola.t get sel.first sel.last] }
  if {$t_sel==""} {
    set t_biezacaLinia [.konsola.t get {insert linestart} {insert lineend}]
  } else {
    set t_biezacaLinia $t_sel
    .konsola.t mark set insert sel.last
  }

  # wykonujemy komende ...
  set t_wynik "  #%% [eval $t_biezacaLinia]"

  # kolejne odpowiedzi zaznaczamy innymi kolorami
  set t_popKolor [.konsola.t tag names {insert +1 lines linestart}]
  if {$t_popKolor=="wynik"} then {
    set t_wynikKolor wynik2
  } else {
    set t_wynikKolor wynik
  }

  set t_ind {insert +1 lines linestart}
  if {[.konsola.t compare $t_ind == end]} then {
      # sa klopoty gdy kursor (mark "insert") jest w ostatniej linii
      # oraz za ostatnim znakiem ...
    set t_insert [.konsola.t index insert]
    .konsola.t mark set insert {insert linestart}
    .konsola.t insert end "\n"
    .konsola.t mark set insert $t_insert
  }

  .konsola.t insert $t_ind "$t_wynik\n" $t_wynikKolor
    # wstawiamy odpowiedz komendy

  eval unset [info vars t_*]
    # powinno sie usunac zmienne t_*

  break
    # nie bedzie dalszej obslugi tego zdarzenia ...
}

# przykladowy tekst
#for {set i 1} {$i<10} {incr i} {
#  .konsola.t insert end "$i qqqqqqqqqqqqqqqqq\n"; .konsola.t insert end "glob *\n"
#}

# obsluga cut/copy/paste (potrzebne tylko pod unix-em ???)
#
event add <<Cut>> <Shift-Key-Delete>
event add <<Copy>> <Control-Key-Insert>
event add <<Paste>> <Shift-Key-Insert>
  # to jest niezbedne na unixie - dlaczego ???
#event add <<Cut>> <Control-x>
#event add <<Copy>> <Control-c>
#event add <<Paste>> <Control-v>
  # dlaczego klawisze Ctrl+xcv nie chca dzialac ???

#bind .konsola.t <Control-v> [bind Text <Control-y>]
  # Ctrl+y nie ma zadnej obslugi - czegos tu nie rozumiem ...

#bind .konsola.t <Control-y> {
#  .konsola.t delete "insert linestart" "insert linestart +1 lines"
#  .konsola.t see insert
#}

# okienko output ktorego uzywa _puts
#
toplevel .output
text .output.t -width 40 -height 20 -font "system $rozmiar"
pack .output.t -side left -expand yes -fill both
scrollbar .output.s
pack .output.s -side left -fill y
.output.t config -yscroll ".output.s set"
.output.s config -command ".output.t yview"

proc _puts p {
  .output.t insert end "$p\n"; .output.t see insert
}

# wczytujemy tekst z pliku
#
set par [lindex $argv 0]
if {$par!=""} then {
  set f [open $par r]
  .konsola.t insert end [read $f]
  close $f
} else {
  .konsola.t insert 1.0 "# uruchamianie komendy - Ctrl+Enter\n"
  .konsola.t insert 2.0 "# (uruchamia sie zaznaczona komenda lub ta na ktorej jest kursor)\n"
  .konsola.t insert 3.0 "# procedura \"_puts\" uzywa okienka output\n"
}

# zapis
#
bind .konsola.t <Control-Key-s> {
  set plik [tk_getSaveFile -initialfile [lindex $argv 0]]
  if {$plik!=""} {
    set f [open $plik w]
    puts -nonewline $f [.konsola.t get 1.0 end-1char]
    close $f
    set argv [list $plik]
  }
  focus .konsola.t
  break; # nie chcemy dalszej obslugi tego zdarzenia!
}

# wstawianie pliku
# + jesli konsola jest pusta to nazwa pliku zostaje zapamietana
#
bind .konsola.t <Control-Key-o> {
  set plik [tk_getOpenFile]
  if {$plik!=""} {
    if {[.konsola.t get 1.0 end-1char]==""} {set argv [list $plik]}
    set f [open $plik r]
    .konsola.t insert insert [read $f]
    close $f
  }
  focus .konsola.t
  break
}

# zmiana fontu
if {[info tclversion]>"8.4"} {kons_font 12}

