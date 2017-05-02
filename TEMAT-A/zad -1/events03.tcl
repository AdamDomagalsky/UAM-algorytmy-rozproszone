wm geom .konsola 667x765+637+65; wm geom .output 309x348+265+64; wm withdraw .; kons_font 15
kons_font 16
load ./q3.dll

fiber create 3 start

proc Inicjalizacja nr {
  fiber$nr alias _puts _puts
  fiber$nr alias maineval eval
  fiber$nr eval "set nr $nr; set run 1"
  fiber$nr eval {
    proc start {} {
      global nr
      _puts "$nr: aaaaaaaaa"
      fiber yield
      _puts "$nr: bbbbbbbbb"
    }
  }
}
Inicjalizacja 0
Inicjalizacja 1
Inicjalizacja 2

fiber yield

fiber error

fiber restart

fiber delete

exit
