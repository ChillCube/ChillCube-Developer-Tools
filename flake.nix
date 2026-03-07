{
  description = "Chillcube Developer CLI Tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = pkgs.stdenv.mkDerivation {
            pname = "chillcube-tools";
            version = "1.0.0";
            src = ./.;
            installPhase = ''
              mkdir -p $out/bin
              cp bin/* $out/bin/
              chmod +x $out/bin/*
            '';

            meta = with pkgs.lib; {
              description = "CLI tools for Chillcube Godot projects";
              license = licenses.bsl11; 
              maintainers = [ ];
            };
          };
        });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = pkgs.mkShell {
            buildInputs = [ self.packages.${system}.default ];
          };
        });
    };
}
