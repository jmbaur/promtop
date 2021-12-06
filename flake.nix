{
  description = "promtop";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.zig.url = "github:arqv/zig-overlay";

  outputs = { self, nixpkgs, flake-utils, zig }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (self: super: {
              zig = zig.packages.${system}.master.latest;
            })
          ];
        };
        buildInputs = [ pkgs.zig ];
      in
      with pkgs; rec {
        devShell = mkShell { inherit buildInputs; };
        packages.promtop = stdenv.mkDerivation {
          pname = "promtop";
          version = "0.1.0";
          inherit buildInputs;
          src = builtins.path { path = ./.; };
          preBuild = ''
            export HOME=$TMPDIR
          '';
          installPhase = ''
            zig build --prefix $out install
          '';
        };
        defaultPackage = packages.promtop;
      });
}
