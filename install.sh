#!/usr/bin/env bash

# --- Chillcube Tools Linux Installer ---
INSTALL_DIR="$HOME/.chillcube-tools"
BIN_DIR="$INSTALL_DIR/bin"

echo "🧊 Installing Chillcube Developer Tools..."

npm install gdscriptify -g

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
