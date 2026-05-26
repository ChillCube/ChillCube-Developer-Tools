# ChillCube Developer Tools

Two independent tools in one repo. Install one, both, or neither — they work standalone.

| Tool | What it is | When to use it |
|------|-----------|----------------|
| **Godot Plugin** | Editor panel inside Godot | Managing addons, planning, bugs, vault, terminal — all from the editor |
| **CLI Tools** | Shell scripts in your terminal | Automation, CI, or if you prefer the terminal |

---

# Godot Plugin

A **🧊 CC Tools** panel added to the top of the Godot editor. No terminal required.

**Tabs:** Addons · Graph · Workspace · Bundles · Dependencies · Planning · Bugs · To-Do · Game Ideas · Vault · Terminal · Browse · Docs · Assets · Team · Account · and more.

## Installation

Run from the **root of your Godot project**, then enable **ChillCube Tools** in **Project → Project Settings → Plugins**.

**Linux / macOS**
```bash
tmp=$(mktemp -d) && git clone --depth=1 https://github.com/ChillCube/ChillCube-Developer-Tools.git "$tmp" && mkdir -p addons && cp -r "$tmp/addons/ChillCube_Tools" addons/ && rm -rf "$tmp"
```

**Windows (PowerShell)**
```powershell
$tmp = New-TemporaryFile | % { Remove-Item $_; New-Item -ItemType Directory -Path "$_.d" }; git clone --depth=1 https://github.com/ChillCube/ChillCube-Developer-Tools.git $tmp; New-Item -ItemType Directory -Force addons | Out-Null; Copy-Item -Recurse "$tmp\addons\ChillCube_Tools" addons\; Remove-Item -Recurse -Force $tmp
```

**Windows (Git Bash)**
```bash
tmp=$(mktemp -d) && git clone --depth=1 https://github.com/ChillCube/ChillCube-Developer-Tools.git "$tmp" && mkdir -p addons && cp -r "$tmp/addons/ChillCube_Tools" addons/ && rm -rf "$tmp"
```

> [!NOTE]
> No terminal? Download the repo as a ZIP via **Code → Download ZIP**, extract it, and copy the `addons/ChillCube_Tools` folder into your project's `addons/` folder manually.

## Updating the plugin

Use the **⬆ Update Plugin** button in the Installed Addons tab — it pulls the latest version from GitHub in one click.

---

# CLI Tools

Shell scripts for managing Godot addons from the terminal: `clone-gd-addon`, `remove-gd-addon`, `create-gd-addon`, `push-all-addons`, `super-git-push`.

> [!IMPORTANT]
> All Godot CLI tools must be run from the **root of your Godot project**.

## Installation

### Windows

**Requires:** [Git for Windows](https://git-scm.com/download/win) (includes Git Bash)

Open **Git Bash** and run:
```bash
git clone https://github.com/ChillCube/ChillCube-Developer-Tools.git && cd ChillCube-Developer-Tools && bash ./install.sh && cd .. && rm -rf ChillCube-Developer-Tools && exec $SHELL
```

> [!NOTE]
> The tools run inside Git Bash. Open it from the Start Menu or right-click any folder → **Git Bash Here**.
> Alternatively, install [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) and follow the Ubuntu instructions inside it.

### macOS

**Requires:** [Homebrew](https://brew.sh/)

```bash
git clone https://github.com/ChillCube/ChillCube-Developer-Tools.git && cd ChillCube-Developer-Tools && chmod +x install.sh && bash ./install.sh && cd .. && rm -rf ChillCube-Developer-Tools && exec $SHELL
```

> [!NOTE]
> On Apple Silicon (M1/M2/M3), Homebrew installs to `/opt/homebrew`. Make sure it's in your PATH before running the above.

### Linux — Ubuntu / Debian

```bash
sudo apt update && sudo apt install -y git python3 python3-venv curl
git clone https://github.com/ChillCube/ChillCube-Developer-Tools.git && cd ChillCube-Developer-Tools && chmod +x install.sh && bash ./install.sh && cd .. && rm -rf ChillCube-Developer-Tools && exec $SHELL
```

### Linux — Fedora / RHEL / CentOS

```bash
sudo dnf install -y git python3 curl
git clone https://github.com/ChillCube/ChillCube-Developer-Tools.git && cd ChillCube-Developer-Tools && chmod +x install.sh && bash ./install.sh && cd .. && rm -rf ChillCube-Developer-Tools && exec $SHELL
```

### Linux — Arch / Manjaro

```bash
sudo pacman -S --needed git python curl
git clone https://github.com/ChillCube/ChillCube-Developer-Tools.git && cd ChillCube-Developer-Tools && chmod +x install.sh && bash ./install.sh && cd .. && rm -rf ChillCube-Developer-Tools && exec $SHELL
```

### Linux — openSUSE

```bash
sudo zypper install -y git python3 curl
git clone https://github.com/ChillCube/ChillCube-Developer-Tools.git && cd ChillCube-Developer-Tools && chmod +x install.sh && bash ./install.sh && cd .. && rm -rf ChillCube-Developer-Tools && exec $SHELL
```

### NixOS

#### Temporary
```bash
export NIXPKGS_ALLOW_UNFREE=1 && nix --extra-experimental-features 'nix-command flakes' shell github:ChillCube/ChillCube-Developer-Tools --refresh --impure --no-write-lock-file
```

#### Declarative
```nix
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

```bash
super-git-push
```
Handles branch selection and commit naming interactively.

> [!IMPORTANT]
> If you're working on a Godot addon, use `push-all-addons` instead.

### Godot — clone an addon

```bash
clone-gd-addon https://github.com/ChillCube/[ADDON NAME].git
```
Clones the addon and installs its dependencies. Also auto-enables it in `project.godot`.

> [!IMPORTANT]
> You may need to reload the project for the plugin to become active.

### Godot — remove an addon

```bash
remove-gd-addon [ADDON NAME]
```
Removes the addon and its orphaned dependencies.

### Godot — create a new addon

```bash
create-gd-addon
```
Creates a new addon, pushes it to ChillCube's GitHub, and generates a LICENSE and README.

> [!NOTE]
> Spaces in addon names are converted to underscores automatically (e.g. "My Addon" → `My_Addon`).

> [!IMPORTANT]
> Enable the addon in Project Settings after creation.

### Godot — push addon changes

```bash
push-all-addons
```
Automates documentation, dependency management, and git for all addons in the project:
- Finds and records dependencies in `DEPENDENCIES.txt`
- Downloads any missing dependencies
- Generates docs from `##` inline comments
- Pushes to GitHub

> [!WARNING]
> Check `DEPENDENCIES.txt` after running — automatic dependency detection can miss some. Add them manually if needed.
