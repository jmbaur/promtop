{ pkgs ? import <nixpkgs> { }, system ? builtins.currentSystem }:
let
  zig-overlay = builtins.fetchTarball "https://github.com/arqv/zig-overlay/archive/main.tar.gz";
  zig = (import zig-overlay { inherit pkgs system; }).master.latest;
in
pkgs.stdenv.mkDerivation {
  pname = "promtop";
  version = "0.1.0";
  src = builtins.path { path = ./.; };
  nativeBuildInputs = with pkgs; [ autoPatchelfHook ncurses6 ];
  buildInputs = [ zig ];
  preBuild = ''
    export HOME=$TMPDIR
  '';
  installPhase = ''
    zig build --prefix $out install
  '';
}
