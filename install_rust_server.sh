#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

STEAMCMD_DIR="$HOME/steamcmd"
RUST_SERVER_DIR="$HOME/rust_server"
OXIDE_URL="https://umod.org/games/rust/download/develop"

echo "== Creating directories =="
mkdir -p "$STEAMCMD_DIR"
mkdir -p "$RUST_SERVER_DIR" # Ensure server dir exists before install

echo "== Installing SteamCMD =="
cd "$STEAMCMD_DIR"
if [ ! -f steamcmd.sh ]; then
    echo "Downloading SteamCMD..."
    wget -q "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
    tar -xvzf steamcmd_linux.tar.gz
    rm steamcmd_linux.tar.gz
    echo "SteamCMD downloaded."
else
    echo "SteamCMD already exists."
fi

echo "== Installing/Updating Rust server (app 258550) =="
# Run steamcmd to install/update the server, without validate
"$STEAMCMD_DIR/steamcmd.sh" +login anonymous +force_install_dir "$RUST_SERVER_DIR" +app_update 258550 +quit
echo "SteamCMD finished."

# Verify RustDedicated exists after install
if [ ! -f "$RUST_SERVER_DIR/RustDedicated" ]; then
    echo "::error::RustDedicated executable not found after SteamCMD run!"
    echo "Listing contents of $RUST_SERVER_DIR:"
    ls -la "$RUST_SERVER_DIR" || echo "Could not list contents of $RUST_SERVER_DIR"
    exit 1
fi
echo "RustDedicated found in $RUST_SERVER_DIR."

echo "== Installing/Updating Oxide (uMod) =="
cd "$RUST_SERVER_DIR" # Change to server dir *after* it's populated
echo "Downloading Oxide..."
wget -q -O oxide.zip "$OXIDE_URL"
echo "Unzipping Oxide..."
unzip -o oxide.zip
rm oxide.zip
echo "Oxide installed."

echo "== Creating start script =="
cat > start.sh <<EOL
#!/bin/bash
set -e
cd "\$(dirname "\$0")" # Ensure script runs from its directory
./RustDedicated -batchmode -nographics \\
+server.port 28015 \\
+server.hostname "My Rust Server" \\
+server.identity "my_server" \\
+server.maxplayers 50 \\
+server.worldsize 1000 \\
+server.seed 12345 \\
+server.saveinterval 300 \\
+server.secure 1 \\
+server.description "Welcome to my Rust server!" \\
+server.tickrate 30
EOL

chmod +x start.sh
echo "start.sh created."

echo "== Server installation and setup complete =="
