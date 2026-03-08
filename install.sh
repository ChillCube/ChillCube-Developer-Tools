#!/usr/bin/env bash

# --- Chillcube Tools Linux Installer ---
INSTALL_DIR="$HOME/.chillcube-tools"
BIN_DIR="$INSTALL_DIR/bin"

echo "---- Installing ChillCube Developer Tools! ----"

CENTRAL_DIR="$HOME/.godot_tools"

if [ ! -d "$CENTRAL_DIR" ]; then
    echo "📦 Creating central tools environment at $CENTRAL_DIR..."
    python3 -m venv "$CENTRAL_DIR"
fi

echo "📥 Installing Godocs globally..."
"$CENTRAL_DIR/bin/pip" install --upgrade pip
"$CENTRAL_DIR/bin/pip" install godocs godocs-jinja

SHELL_CONFIG="$HOME/.bashrc"
if [[ "$SHELL" == *"zsh"* ]]; then SHELL_CONFIG="$HOME/.zshrc"; fi

if ! grep -q "$CENTRAL_DIR/bin" "$SHELL_CONFIG"; then
    echo "🔗 Adding Godocs to your PATH in $SHELL_CONFIG..."
    echo "export PATH=\"\$PATH:$CENTRAL_DIR/bin\"" >> "$SHELL_CONFIG"
    echo "✅ Success!"
else
    echo "✅ Godocs is already in your PATH."
fi

mkdir -p "$BIN_DIR"

if [ -d "bin" ]; then
    cp -r bin/* "$BIN_DIR/"
    chmod +x "$BIN_DIR/"*
    echo "✅ Tools copied to $BIN_DIR"
else
    echo "❌ Error: 'bin' folder not found. Run this from the repo root."
    exit 1
fi
if [[ "$SHELL" == */zsh ]]; then
    CONF_FILE="$HOME/.zshrc"
else
    CONF_FILE="$HOME/.bashrc"
fi

PATH_LINE="export PATH=\"\$HOME/.chillcube-tools/bin:\$PATH\""

if ! grep -qs ".chillcube-tools/bin" "$CONF_FILE"; then
    echo -e "\n# Chillcube CLI Tools\n$PATH_LINE" >> "$CONF_FILE"
    echo "✅ Path added to $CONF_FILE"
else
    echo "✅ Path already exists in $CONF_FILE"
fi

echo "--------------------------------------------------"
echo "🎉 Setup complete! Your shell has been refreshed."
echo "🧊 Try running: chill-deps"
