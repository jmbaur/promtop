{ pkgs ? import <nixpkgs> { }, system ? builtins.currentSystem }:
let
  zig-overlay = builtins.fetchTarball "https://github.com/arqv/zig-overlay/archive/main.tar.gz";
  zig = (import zig-overlay { inherit pkgs system; }).master.latest;
in
pkgs.stdenv.mkDerivation {
  pname = "pomtop";
  version = "0.1.0";
  src = builtins.path { path = ./.; };
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.ncurses6 zig ];
  preBuild = ''
    export HOME=$TMPDIR
  '';
  installPhase = ''
    zig build --prefix $out install
  '';
}
