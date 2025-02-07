#!/bin/bash

STEAMCMD_DIR="$HOME/steamcmd"
RUST_SERVER_DIR="$HOME/rust_server"
OXIDE_URL="https://umod.org/games/rust/download/develop"

echo "== Installing SteamCMD =="
mkdir -p $STEAMCMD_DIR
cd $STEAMCMD_DIR
if [ ! -f steamcmd.sh ]; then
    wget "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
    tar -xvzf steamcmd_linux.tar.gz
    rm steamcmd_linux.tar.gz
fi

echo "== Checking for Rust server updates =="
$STEAMCMD_DIR/steamcmd.sh +login anonymous +force_install_dir $RUST_SERVER_DIR +app_update 258550 validate +quit

echo "== Installing/Updating Oxide (uMod) =="
cd $RUST_SERVER_DIR
wget -O oxide.zip "$OXIDE_URL"
unzip -o oxide.zip
rm oxide.zip

echo "== Creating start script =="
cat > start.sh <<EOL
#!/bin/bash
./RustDedicated -batchmode -nographics \
+server.port 28015 \
+server.hostname "My Rust Server" \
+server.identity "my_server" \
+server.maxplayers 50 \
+server.worldsize 4000 \
+server.seed 12345 \
+server.saveinterval 300 \
+server.secure 1 \
+server.description "Welcome to my Rust server!" \
+server.tickrate 30
EOL

chmod +x start.sh

echo "== Starting the server =="
./start.sh
