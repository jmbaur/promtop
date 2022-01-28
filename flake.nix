{
  description = "promtop";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:arqv/zig-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, zig }@inputs: {
    overlay = final: prev: {
      promtop = nixpkgs.legacyPackages.${prev.system}.stdenvNoCC.mkDerivation {
        pname = "promtop";
        version = "0.1.0";
        buildInputs = [ zig.packages.${prev.system}.master.latest ];
        src = builtins.path { path = ./.; };
        preBuild = ''
          export HOME=$TMPDIR
        '';
        installPhase = ''
          zig build --prefix $out install
        '';
      };
    };
  }
  // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        overlays = [ self.overlay ];
        inherit system;
      };
    in
    with pkgs; rec {
      devShell = mkShell {
        buildInputs = [ zig.packages.${system}.master.latest ];
      };
      packages.promtop = pkgs.promtop;
      defaultPackage = pkgs.promtop;
      apps.promtop = flake-utils.lib.mkApp {
        drv = pkgs.promtop;
        name = "promtop";
      };
      defaultApp = apps.promtop;
    });
}
