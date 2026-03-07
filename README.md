# ChillCube-Developer-Tools
This repository provides tools that will be needed to work with ChillCube's projects and libraries. 

## Installation 
### Linux/MacOS
```Bash
git clone https://github.com/ChillCube/ChillCube-Developer-Tools.git && cd chillcube-cli && chmod +x install.sh && ./install.sh && cd .. && rm -rf chillcube-cli && exec $SHELL
```
### NixOS
```Nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  chillcube.url = "github:ChillCube/ChillCube-Developer-Tools";
};

outputs = { self, nixpkgs, chillcube, ... }: {
  nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
    modules = [
      ./configuration.nix
      { environment.systemPackages = [ chillcube.packages.${pkgs.system}.default ]; }
    ];
  };
};
```
