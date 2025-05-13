#!/bin/bash

# Controllo se è stato fornito un argomento
if [ $# -ne 3 ]; then
    echo "Utilizzo: $0 <nome_cartella> <username_samba> <server_samba>"
    exit 1
fi

# Assegna gli argomenti a variabili
FOLDER_NAME=$1
SAMBA_USER=$2
SAMBA_SERVER=$3
SAMBA_PASSWORD="SecurePass4" # Password di default, può essere cambiata in fase di esecuzione
# Directory di base per il mount point
BASE_DIR="/mnt/samba/sharare_point"

# Crea la directory di base se non esiste
if [ ! -d "$BASE_DIR" ]; then
    sudo mkdir -p "$BASE_DIR"
    echo "Directory $BASE_DIR creata."
fi

# Crea la directory con il nome fornito come argomento
if [ ! -d "$BASE_DIR/$FOLDER_NAME" ]; then
    sudo mkdir -p "$BASE_DIR/$FOLDER_NAME"
    echo "Directory $BASE_DIR/$FOLDER_NAME creata."
fi

# Crea la directory private
if [ ! -d "$BASE_DIR/private" ]; then
    sudo mkdir -p "$BASE_DIR/private"
    echo "Directory $BASE_DIR/private creata."
fi

# Richiedi la password Samba in modo sicuro
echo -n "Inserisci la password Samba per l'utente $SAMBA_USER: "
read -s SAMBA_PASSWORD
echo ""

# Monta la condivisione Samba
echo "Montaggio della condivisione Samba..."
if mount | grep -q "$BASE_DIR"; then
    echo "Una condivisione è già montata in $BASE_DIR. Smonto prima di procedere."
    sudo umount "$BASE_DIR"
fi

# Esegui il mount con le credenziali fornite
sudo mount -t cifs "//$SAMBA_SERVER/$FOLDER_NAME" "$BASE_DIR/$FOLDER_NAME" -o username="$SAMBA_USER",password="$SAMBA_PASSWORD",password="$SAMBA_PASSWORD",vers=3.0
sudo mount -t cifs "//$SAMBA_SERVER/private" "$BASE_DIR/private" -o username="$SAMBA_USER",password="$SAMBA_PASSWORD",password="$SAMBA_PASSWORD",vers=3.0

# Verifica se il mount è riuscito
if [ $? -eq 0 ]; then
    echo "Condivisione Samba montata con successo in $BASE_DIR"
    echo "Le cartelle create sono:"
    echo "- $BASE_DIR/$FOLDER_NAME"
    echo "- $BASE_DIR/private"
else
    echo "Errore durante il montaggio della condivisione Samba."
    echo "Verifica le credenziali e l'indirizzo del server."
fi