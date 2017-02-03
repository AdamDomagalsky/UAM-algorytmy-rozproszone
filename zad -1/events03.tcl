wm geom .konsola 667x765+637+65; wm geom .output 309x348+265+64; wm withdraw .; kons_font 15
kons_font 16
load ./q3.so

fiber create 3 start
  # + tworzy 3 fibery: fiber0 fiber1 fiber2,
  #  ktore rownoczesnie sa interp-ami (logicznymi)
  # + fibery wykonuja podany w 3 arg. kod tcl-owy,
  #  w tym wypadku jest to wywolanie proc start

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
  # + przalaczenie procesora na fiber0 ...

fiber error
  # + wyswietla stan fiberow
fiber restart
  # + restartuje te wstanie "ended"
fiber delete
  # + usuwa fibery (wszystkie musza byc "ended")



exit
