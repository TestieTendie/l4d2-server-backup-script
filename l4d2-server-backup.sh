!/bin/bash
# Ideally, your provider should allow you to authenticate to SFTP using an SSH key, that way the process can be entirely automated,
# otherwise you need to input your SFTP password each time a new SFTP session is started (14 times in this script).

# SFTP Connection details

SERVER="PUT YOUR SERVER'S SFTP ADDRESS HERE"
PORT="2022"
USERNAME="PUT YOUR SFTP USER HERE"

# Define the directories and files to fetch
# Ideally, a sourcemode plugin would make the backups to a single folder and we'd fetch that but I haven't wrote said plugin yet.
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
  target_dir="$LOCAL_DIR${dir%/}"
  mkdir -p "$target_dir"
  sftp -P "$PORT" "$USERNAME@$SERVER" << EOF
    lcd "$target_dir"
    cd "$dir"
    get -r *
    bye
EOF
done

# Copy Files
for file in "${FILES[@]}"; do
  sftp -P $PORT $USERNAME@$SERVER << EOF
    get $file $LOCAL_DIR$file
EOF
done

# Commit and push files to git repo
cd ~/l4d2-server-backup
git add .
git commit -m "Fetched files from server"
git push origin main
