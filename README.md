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
export NIXPKGS_ALLOW_UNFREE=1
nix --extra-experimental-features 'nix-command flakes' shell github:ChillCube/ChillCube-Developer-Tools --impure --no-write-lock-file
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

## Usage
### CLI-Tools
#### Git
```Bash
super-git-push
```
Super git push handles a lot of the git commands you normally have to type manually. It will prompt you to decide on a branch as well as give a name to the commit. 
#### Godot
```Bash
clone-gd-addon https://github.com/ChillCube/[ADDON NAME].git
```
This clones addons created by ChillCube and ensures the necessary dependencies are cloned as well.
```Bash
clone-gd-addon https://github.com/ChillCube/[ADDON NAME].git
```
This clones addons created by ChillCube and ensures the necessary dependencies are cloned as well.
