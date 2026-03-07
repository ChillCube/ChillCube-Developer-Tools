# ChillCube-Developer-Tools
This repository provides tools that will be needed to work with ChillCube's projects and libraries. 
People who would like to contribute or use our libraries may also need to install these, even if they are not ChillCube Developers

## Installation 
### Linux/MacOS
Simply copy paste this into terminal to install the tools:
```Bash
git clone https://github.com/ChillCube/ChillCube-Developer-Tools.git && cd chillcube-cli && chmod +x install.sh && ./install.sh && cd .. && rm -rf chillcube-cli && exec $SHELL
```
### NixOS
#### Temporary
Copy paste the into terminal to temporarily install the tools:
```Bash
nix --extra-experimental-features 'nix-command flakes' shell github:ChillCube/ChillCube-Developer-Tools --no-write-lock-file
```
#### Declarative
You can add this repository to NixOS using flakes:
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
