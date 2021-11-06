{ pkgs ? import <nixpkgs> { }, system ? builtins.currentSystem }:
let
  zig-overlay = builtins.fetchTarball "https://github.com/arqv/zig-overlay/archive/main.tar.gz";
  zig = (import zig-overlay { inherit pkgs system; }).master.latest;
in
pkgs.mkShell {
  buildInputs = [ pkgs.ncurses6 zig ];
}
