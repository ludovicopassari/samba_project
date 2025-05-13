#!/bin/bash
# Script di configurazione Samba per una PMI di circa 20 dipendenti
# con reparti: Amministrazione, Risorse Umane e IT

# Parte 1: Installazione del sistema e di Samba
echo "Installazione di Samba e pacchetti necessari..."
apt update
apt install -y samba smbclient cifs-utils

# Fermare il servizio per la configurazione
systemctl stop smbd nmbd

# Backup della configurazione originale
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Parte 2: Creazione della struttura delle directory
echo "Creazione della struttura delle directory..."

# Directory principale per le condivisioni Samba
mkdir -p /srv/samba/shares

# Directory pubbliche (accessibili a tutti)
mkdir -p /srv/samba/shares/public
mkdir -p /srv/samba/shares/documents

# Directory per reparti specifici
mkdir -p /srv/samba/shares/amministrazione
mkdir -p /srv/samba/shares/risorse_umane
mkdir -p /srv/samba/shares/it

# Directory private per utenti
mkdir -p /srv/samba/shares/private

# Parte 3: Configurazione dei permessi di base
echo "Configurazione dei permessi di base..."

# Permessi per directory pubbliche
chmod 775 /srv/samba/shares/public
chmod 775 /srv/samba/shares/documents

# Permessi per directory dei reparti
chmod 770 /srv/samba/shares/amministrazione
chmod 770 /srv/samba/shares/risorse_umane
chmod 770 /srv/samba/shares/it

# Permessi per directory private
chmod 700 /srv/samba/shares/private

# Parte 4: Creazione dei gruppi per i reparti
echo "Creazione dei gruppi per i reparti..."
groupadd smbusers       # Gruppo generico per tutti gli utenti Samba
groupadd amministrazione
groupadd risorse_umane
groupadd it

# Assegnazione dei gruppi alle directory
chgrp smbusers /srv/samba/shares/public
chgrp smbusers /srv/samba/shares/documents
chgrp amministrazione /srv/samba/shares/amministrazione
chgrp risorse_umane /srv/samba/shares/risorse_umane
chgrp it /srv/samba/shares/it

# Parte 5: Configurazione di Samba (smb.conf)
echo "Configurazione di smb.conf..."
cat > /etc/samba/smb.conf << 'EOL'
[global]
   workgroup = AZIENDA
   server string = Server Samba Aziendale
   server role = standalone server
   log file = /var/log/samba/log.%m
   max log size = 50
   logging = file
   security = user
   encrypt passwords = true
   passdb backend = tdbsam
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   usershare allow guests = no
   dns proxy = no
   
   # Impostazioni di performance
   socket options = TCP_NODELAY IPTOS_LOWDELAY
   read raw = yes
   write raw = yes
   oplocks = yes
   max xmit = 65535
   dead time = 15
   getwd cache = yes

# Condivisioni pubbliche
[public]
   comment = Cartella Pubblica
   path = /srv/samba/shares/public
   browseable = yes
   read only = no
   writeable = yes
   guest ok = no
   valid users = @smbusers
   create mask = 0775
   directory mask = 0775
   force group = smbusers

[documents]
   comment = Documenti Aziendali
   path = /srv/samba/shares/documents
   browseable = yes
   read only = no
   writeable = yes
   guest ok = no
   valid users = @smbusers
   create mask = 0775
   directory mask = 0775
   force group = smbusers

# Condivisioni per reparti
[amministrazione]
   comment = Reparto Amministrazione
   path = /srv/samba/shares/amministrazione
   browseable = yes
   read only = no
   writeable = yes
   guest ok = no
   valid users = @amministrazione
   create mask = 0770
   directory mask = 0770
   force group = amministrazione

[risorse_umane]
   comment = Reparto Risorse Umane
   path = /srv/samba/shares/risorse_umane
   browseable = yes
   read only = no
   writeable = yes
   guest ok = no
   valid users = @risorse_umane
   create mask = 0770
   directory mask = 0770
   force group = risorse_umane

[it]
   comment = Reparto IT
   path = /srv/samba/shares/it
   browseable = yes
   read only = no
   writeable = yes
   guest ok = no
   valid users = @it
   create mask = 0770
   directory mask = 0770
   force group = it

# Cartelle private
[private]
   comment = Cartelle Private
   path = /srv/samba/shares/private/%U
   browseable = yes
   read only = no
   writeable = yes
   guest ok = no
   valid users = %U
   create mask = 0700
   directory mask = 0700
EOL

# Parte 6: Creazione e configurazione degli utenti
echo "Script per creazione e configurazione degli utenti..."
cat > /usr/local/bin/add_samba_user.sh << 'EOL'
#!/bin/bash
# Script per aggiungere un utente Samba
# Uso: ./add_samba_user.sh username password gruppo

if [ $# -ne 3 ]; then
    echo "Uso: $0 username password gruppo"
    exit 1
fi

USERNAME=$1
PASSWORD=$2
GROUP=$3

# Crea l'utente Linux
useradd -m -s /bin/bash $USERNAME

# Imposta la password
echo "$USERNAME:$PASSWORD" | chpasswd

# Aggiunge al gruppo Samba e al gruppo di reparto specifico
usermod -aG smbusers $USERNAME
usermod -aG $GROUP $USERNAME

# Crea la directory privata dell'utente
mkdir -p /srv/samba/shares/private/$USERNAME
chown $USERNAME:$USERNAME /srv/samba/shares/private/$USERNAME
chmod 700 /srv/samba/shares/private/$USERNAME

# Aggiunge l'utente Samba e imposta la password
echo -e "$PASSWORD\n$PASSWORD" | smbpasswd -a $USERNAME

echo "Utente $USERNAME creato e aggiunto al gruppo $GROUP"
EOL

chmod +x /usr/local/bin/add_samba_user.sh

# Parte 7: Script esempio per aggiungere utenti
echo "Creazione script di esempio per aggiungere utenti..."
cat > /usr/local/bin/add_example_users.sh << 'EOL'
#!/bin/bash
# Script di esempio per aggiungere alcuni utenti

# Utenti Amministrazione
/usr/local/bin/add_samba_user.sh admin1 SecurePass1 amministrazione
/usr/local/bin/add_samba_user.sh admin2 SecurePass2 amministrazione
/usr/local/bin/add_samba_user.sh finance1 SecurePass3 amministrazione

# Utenti Risorse Umane
/usr/local/bin/add_samba_user.sh hr1 SecurePass4 risorse_umane
/usr/local/bin/add_samba_user.sh hr2 SecurePass5 risorse_umane
/usr/local/bin/add_samba_user.sh recruit1 SecurePass6 risorse_umane

# Utenti IT
/usr/local/bin/add_samba_user.sh it1 SecurePass7 it
/usr/local/bin/add_samba_user.sh it2 SecurePass8 it
/usr/local/bin/add_samba_user.sh dev1 SecurePass9 it

# Direttore generale (membro di tutti i gruppi)
/usr/local/bin/add_samba_user.sh direttore SecurePass10 amministrazione
usermod -aG risorse_umane direttore
usermod -aG it direttore
EOL

chmod +x /usr/local/bin/add_example_users.sh

# Parte 8: Avvio e abilitazione del servizio
echo "Avvio e abilitazione del servizio Samba..."
systemctl start smbd nmbd
systemctl enable smbd nmbd

# Verifica della configurazione
echo "Verifica della configurazione Samba..."
testparm -s

# Informazioni finali
echo "======================================================"
echo "Configurazione Samba completata!"
echo ""
echo "Per aggiungere un nuovo utente, usa:"
echo "  /usr/local/bin/add_samba_user.sh username password gruppo"
echo ""
echo "Per aggiungere gli utenti di esempio, esegui:"
echo "  /usr/local/bin/add_example_users.sh"
echo ""
echo "Per verificare le condivisioni disponibili da un client:"
echo "  smbclient -L //localhost -U username"
echo ""
echo "Per montare una condivisione da client Linux:"
echo "  mount -t cifs //server/condivisione /punto/di/mount -o username=utente"
echo ""
echo "======================================================"