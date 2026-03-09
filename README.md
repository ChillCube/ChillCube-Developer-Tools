# ChillCube-Developer-Tools
This repository provides tools that will be needed to work with ChillCube's projects and libraries. 
People who would like to contribute or use our libraries may also need to install these, even if they are not ChillCube Developers.
Depending on your needs, it may be recommended to fork this library, as this library is first and foremost made for ChillCube's own development pipeline.

## Installation 
### Linux/MacOS
Simply copy paste this into terminal to install the tools:
```Bash
git clone https://github.com/ChillCube/ChillCube-Developer-Tools.git && cd ChillCube-Developer-Tools && chmod +x install.sh && bash ./install.sh && cd .. && rm -rf ChillCube-Developer-Tools && exec $SHELL
```

### NixOS
#### Temporary
Copy paste the into terminal to temporarily install the tools:
```Bash
export NIXPKGS_ALLOW_UNFREE=1 && nix --extra-experimental-features 'nix-command flakes' shell github:ChillCube/ChillCube-Developer-Tools --refresh --impure --no-write-lock-file
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
### Git

```Bash
super-git-push
```
Super git push handles a lot of the git commands you normally have to type manually. It will prompt you to decide on a branch as well as give a name to the commit. 
> [!IMPORTANT]
> If you're working on a godot addon, use ```push-all-addons``` instead.
### Godot
> [!IMPORTANT]
> All of the godot CLI tools are run from the root of your godot project!

#### Cloning a godot addon made by ChillCube
```Bash
clone-gd-addon https://github.com/ChillCube/[ADDON NAME].git
```
This clones addons created by ChillCube and ensures the necessary dependencies are cloned as well.
> [!IMPORTANT]
> Make sure to enable the addon in the project settings!

#### Removing a godot addon made by ChillCube
```Bash
remove-gd-addon [ADDON NAME]
```
This removes addons and its dependencies from your godot project. 

#### Create a new godot addon for ChillCube
```Bash
create-gd-addon
```
> [!WARNING]
> Make sure to not use spaces in the name of the addon you are creating, as this will mess with the file system!

Use this to create a new addon within your project. It will push it into ChillCube's repositories automatically and initiate everything, including the LICENSE and a default README.
> [!IMPORTANT]
> Make sure to enable the addon in the project settings!

#### Push changes you've made to any of the addons
```Bash
push-all-addons
```
Push-all-addons automates several parts of documentation, dependencies and git management. 
- finds and adds dependencies to the addons repository
- downloads any missing dependencies
- creates documentation based on ## comments in your script (they have to be on the same line as the function, signal or variable it is describing)
- pushes to github

