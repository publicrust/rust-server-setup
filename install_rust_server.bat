@echo off
title Rust Server Installer & Updater
set STEAMCMD_DIR=C:\steamcmd
set RUST_SERVER_DIR=C:\rust_server
set OXIDE_URL=https://umod.org/games/rust/download/develop

echo == Installing SteamCMD ==
if not exist "%STEAMCMD_DIR%" mkdir %STEAMCMD_DIR%
cd %STEAMCMD_DIR%
if not exist steamcmd.exe (
    curl -o steamcmd.zip "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
    tar -xf steamcmd.zip
    del steamcmd.zip
)

echo == Checking for Rust server updates ==
%STEAMCMD_DIR%\steamcmd.exe +login anonymous +force_install_dir %RUST_SERVER_DIR% +app_update 258550 validate +quit

echo == Installing/Updating Oxide (uMod) ==
cd %RUST_SERVER_DIR%
curl -o oxide.zip "%OXIDE_URL%"
tar -xf oxide.zip
del oxide.zip

echo == Creating start script ==
(
echo @echo off
echo RustDedicated.exe -batchmode -nographics ^
echo +server.port 28015 ^
echo +server.hostname "My Rust Server" ^
echo +server.identity "my_server" ^
echo +server.maxplayers 50 ^
echo +server.worldsize 4000 ^
echo +server.seed 12345 ^
echo +server.saveinterval 300 ^
echo +server.secure 1 ^
echo +server.description "Welcome to my Rust server!" ^
echo +server.tickrate 30
) > start.bat

echo == Starting the server ==
start start.bat
