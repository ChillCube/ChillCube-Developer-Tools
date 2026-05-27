# ChillCube Developer Tools

Two independent tools in one repo. Install one, both, or neither — they work standalone.

| Tool | What it is | When to use it |
|------|-----------|----------------|
| **Godot Plugin** | Editor panel inside Godot | Managing addons, planning, bugs, vault, terminal — all from the editor |
| **CLI Tools** | Shell scripts in your terminal | Automation, CI, or if you prefer the terminal |

---

# Godot Plugin

A **🧊 CC Tools** panel added to the top of the Godot editor. No terminal required.

**Tabs:** Addons · Graph · Workspace · Bundles · Dependencies · Planning · Bugs · To-Do · Vault · Terminal · Browse · Docs · Assets · Team · Account · and more.

## Prerequisites

- [Git](https://git-scm.com/downloads) — required for the install command and addon management
- A [GitHub account](https://github.com/join) — required for team/shared features
- An **SSH key** linked to your GitHub account — the plugin communicates with private repos over SSH

**Setting up an SSH key (one-time):**

> [!NOTE]
> On Windows, run all of these commands inside **Git Bash** (not PowerShell or CMD).

**1. Check if you already have a key**

```bash
ls ~/.ssh/id_ed25519.pub
```
If the file exists, skip to step 3. If you get "No such file or directory", continue to step 2.

**2. Generate a key**

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```
Press **Enter** three times to accept the default file location and skip the passphrase.

**3. Add the key to the SSH agent**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

> [!NOTE]
> On macOS, use `ssh-add --apple-use-keychain ~/.ssh/id_ed25519` instead to save it in your Keychain — otherwise you'll need to re-add it every reboot.

**4. Add the public key to GitHub**

```bash
cat ~/.ssh/id_ed25519.pub
```
Copy the output, then go to **[GitHub → Settings → SSH and GPG keys → New SSH key](https://github.com/settings/ssh/new)**, paste it in, and click **Add SSH key**.

**5. Verify it works**

```bash
ssh -T git@github.com
```
You should see: `Hi <username>! You've successfully authenticated.`

**Configuring git with your identity (one-time):**

The plugin makes git commits on your behalf (registration, vault saves, etc.), so git needs to know who you are:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```
Use the same email as your GitHub account so commits are linked to your profile.

## Installation

Open a terminal **in the root of your Godot project** (the folder containing `project.godot`), then run:

**Linux / macOS / Windows (Git Bash)**
```bash
[ -f project.godot ] || { echo "❌ No project.godot found — run this from the root of your Godot project."; false; } && rm -rf .cc-tmp && git clone --depth=1 https://github.com/ChillCube/ChillCube-Developer-Tools.git .cc-tmp && mkdir -p addons && cp -r .cc-tmp/addons/ChillCube_Tools addons/ && rm -rf .cc-tmp
```

**Windows (PowerShell)**
```powershell
if (-not (Test-Path "project.godot")) { Write-Error "❌ No project.godot found — run this from the root of your Godot project." } else { Remove-Item -Recurse -Force .cc-tmp -ErrorAction SilentlyContinue; git clone --depth=1 https://github.com/ChillCube/ChillCube-Developer-Tools.git .cc-tmp; New-Item -ItemType Directory -Force addons | Out-Null; Copy-Item -Recurse .cc-tmp\addons\ChillCube_Tools addons\; Remove-Item -Recurse -Force .cc-tmp }
```

> [!NOTE]
> No terminal? Download the repo as a ZIP via **Code → Download ZIP**, extract it, and copy the `addons/ChillCube_Tools` folder into your project's `addons/` folder manually.

## Enabling the plugin

After installing:

1. Open your project in Godot
2. Go to **Project → Project Settings → Plugins**
3. Find **ChillCube Tools** and tick the **Enable** checkbox
4. A **🧊 CC Tools** panel will appear at the top of the editor

> [!NOTE]
> If the panel doesn't appear after enabling, try closing and reopening the project.

## Account setup

When you open the plugin for the first time a login screen will appear. There are two paths depending on whether your team already has an auth repo set up.

### Path A — First person on the team (leader setup)

This creates the private `ChillCube/cc-auth` GitHub repo that stores all team accounts.

**Requirements:**
- A GitHub account that is a member (or owner) of the **ChillCube** GitHub organisation
- SSH key set up (see Prerequisites above)
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and logged in — needed here to create the private repo and manage collaborators
  ```bash
  # Install gh, then:
  gh auth login
  ```

**Steps:**
1. Click **⚙ First-time setup (create auth repo)** on the Login tab
2. Wait for it to finish — it creates `ChillCube/cc-auth` and sets up the first account
3. Log in with the default credentials: **`IceCubeMaker`** / **`12345`**
4. Go to **Account → Change Password** and set a real password immediately

### Path B — Joining an existing team

`gh` CLI is **not required** for regular members. You only need Git and an SSH key.

**Requirements:**
- A GitHub account with an SSH key set up (see Prerequisites above)
- Ask your **team leader** to add your GitHub username as a collaborator on `ChillCube/cc-auth` and `ChillCube/vault` — they do this from the **Team** tab in the plugin

**Steps:**
1. Switch to the **Register** tab on the login screen
2. Fill in a username, your GitHub username, and a password
3. Click **Register** and wait for the confirmation message
4. Ask your team leader to approve your account — they'll see it under **Team → Pending Accounts**
5. Once approved, log in on the **Login** tab

> [!IMPORTANT]
> Your account starts as **pending** and won't work until the team leader approves it. You'll see `⏳ Account pending approval` when you try to log in before that happens.

## Updating the plugin

Use the **⬆ Update Plugin** button in the Installed Addons tab — it pulls the latest version from GitHub in one click.

---

# CLI Tools

Shell scripts for managing Godot addons from the terminal: `clone-gd-addon`, `remove-gd-addon`, `create-gd-addon`, `push-all-addons`, `super-git-push`.

> [!IMPORTANT]
> All Godot CLI tools must be run from the **root of your Godot project**.

## Prerequisites

- [Git](https://git-scm.com/downloads)
- A [GitHub account](https://github.com/join) with an SSH key set up (see plugin Prerequisites above)
- [GitHub CLI (`gh`)](https://cli.github.com/) — only required for `create-gd-addon` (creates the GitHub repo). `push-all-addons` and the rest use plain git.
  - After installing: `gh auth login`

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
