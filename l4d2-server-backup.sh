#!/bin/bash

# SFTP Connection details

SERVER="SERVER'S SFTP ADDRESS HERE"
PORT="SERVER'S SFTP PORT HERE"
USERNAME="YOUR USERNAME TO ACCESS THE SERVER VIA SFTP HERE"

# Define the directories and files to fetch
DIRECTORIES=(
  "/left4dead2/cfg/"
  "/left4dead2/ems/"
  "/left4dead2/logs/"
  "/left4dead2/addons/sourcemod/configs/"
  "/left4dead2/addons/sourcemod/data/"
  "/left4dead2/addons/sourcemod/extensions/"
  "/left4dead2/addons/sourcemod/gamedata/"
  "/left4dead2/addons/sourcemod/logs/"
  "/left4dead2/addons/sourcemod/plugins/"
  "/left4dead2/addons/sourcemod/translations/"
  "/left4dead2/addons/metamod/"
)
FILES=(
  "/left4dead2/host.txt"
  "/left4dead2/motd.txt"
  "/left4dead2/addonlist.txt"
)

# Local directory to store fetched files
LOCAL_DIR="./l4d2-server-backup"

# Copy Directories
for dir in "${DIRECTORIES[@]}"; do
  target_dir="$LOCAL_DIR${dir%/}"  # Remove trailing slash if present
  mkdir -p "$target_dir"
  expect << EOF
    set timeout -1
    spawn sftp -P $PORT $USERNAME@$SERVER
    expect "USERNAME@SERVER's password:"
    send "YOUR PASSWORD HERE\r"
    expect "sftp>"
    send "lcd \"$target_dir\"\r"
    expect "sftp>"
    send "cd \"$dir\"\r"
    expect "sftp>"
    send "get -r *\r"
    expect "sftp>"
    send "bye\r"
    expect eof
EOF
done

# Copy Files
for file in "${FILES[@]}"; do
  target_file="$LOCAL_DIR$file"
  expect << EOF
    set timeout -1
    spawn sftp -P $PORT $USERNAME@$SERVER
    expect "USERNAME@SERVER's password:"
    send "YOUR PASSWORD HERE\r"
    expect "sftp>"
    send "bye\r"
    expect eof
EOF
done

# Commit and push files to the git repo with default commit message
cd ~/l4d2-server-backup
git add .
git commit -m "Fetched files from server"
git push origin main

rm -rf ~/l4d2-server-backup/left4dead2
