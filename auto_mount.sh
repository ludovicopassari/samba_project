#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Utilizzo: $0 <nome_cartella> <username_samba> <server_samba>"
    exit 1
fi

FOLDER_NAME=$1
SAMBA_USER=$2
SAMBA_SERVER=$3
SAMBA_PASSWORD="SecurePass4"

BASE_DIR="$HOME/Scrivania/share_point"  # ✅ Fix tilde

if [ ! -d "$BASE_DIR" ]; then
    sudo mkdir -p "$BASE_DIR"
    echo "Directory $BASE_DIR creata."
fi

if [ ! -d "$BASE_DIR/$FOLDER_NAME" ]; then
    sudo mkdir -p "$BASE_DIR/$FOLDER_NAME"
    echo "Directory $BASE_DIR/$FOLDER_NAME creata."
fi

if [ ! -d "$BASE_DIR/private" ]; then
    sudo mkdir -p "$BASE_DIR/private"
    echo "Directory $BASE_DIR/private creata."
fi

echo "Montaggio della condivisione Samba..."

if mount | grep -q "$BASE_DIR/$FOLDER_NAME"; then
    echo "Smonto $BASE_DIR/$FOLDER_NAME"
    sudo umount "$BASE_DIR/$FOLDER_NAME"
fi

if mount | grep -q "$BASE_DIR/private"; then
    echo "Smonto $BASE_DIR/private"
    sudo umount "$BASE_DIR/private"
fi

CURR_UID=$(id -u)
CURR_GID=$(id -g)

sudo mount -t cifs "//$SAMBA_SERVER/$FOLDER_NAME" "$BASE_DIR/$FOLDER_NAME" \
  -o username="$SAMBA_USER",password="$SAMBA_PASSWORD",uid=$CURR_UID,gid=$CURR_GID,vers=3.0

sudo mount -t cifs "//$SAMBA_SERVER/private" "$BASE_DIR/private" \
  -o username="$SAMBA_USER",password="$SAMBA_PASSWORD",uid=$CURR_UID,gid=$CURR_GID,vers=3.0

if [ $? -eq 0 ]; then
    echo "Condivisione Samba montata con successo."
    echo "Cartelle montate:"
    echo "- $BASE_DIR/$FOLDER_NAME"
    echo "- $BASE_DIR/private"
else
    echo "Errore durante il montaggio della condivisione Samba."
fi
