# Guida alla connessione al Server Samba aziendale

Questa guida illustra come connettersi alle condivisioni Samba dal proprio computer di lavoro, sia da Windows che da Linux.

## Connessione da Windows

### Connessione tramite Esplora File

1. Apri Esplora File (Windows Explorer)
2. Nella barra degli indirizzi, digita `\\nome-server` (sostituisci "nome-server" con l'indirizzo IP o il nome del server Samba)
3. Inserisci le credenziali quando richieste (nome utente e password)
4. Naviga tra le cartelle condivise a cui hai accesso

### Mappare un'unità di rete

1. Apri Esplora File
2. Fai clic destro su "Questo PC" e seleziona "Mappa unità di rete"
3. Nel campo "Cartella", inserisci `\\nome-server\nome-condivisione` (es. `\\server-azienda\amministrazione`)
4. Spunta "Connetti utilizzando credenziali diverse" se necessario
5. Fai clic su "Fine" e inserisci le tue credenziali quando richiesto
6. L'unità mappata apparirà in Esplora File con la lettera di unità assegnata

### Connessione da prompt dei comandi

```cmd
net use Z: \\nome-server\nome-condivisione /USER:dominio\username
```

Sostituisci:
- `Z:` con la lettera di unità desiderata
- `nome-server` con l'indirizzo IP o il nome del server
- `nome-condivisione` con il nome della condivisione (public, amministrazione, etc.)
- `username` con il tuo nome utente

## Connessione da Linux

### Connessione temporanea

Per accedere temporaneamente:

```bash
# Creare un punto di mount
sudo mkdir -p /mnt/samba/condivisione

# Montare la condivisione
sudo mount -t cifs //nome-server/nome-condivisione /mnt/samba/condivisione -o username=utente
```

Ti verrà richiesta la password.

### Connessione permanente tramite fstab

1. Crea un file con le credenziali (opzione sicura):

```bash
sudo nano /etc/samba/credentials
```

2. Inserisci nome utente e password:

```
username=tuousername
password=tuapassword
```

3. Proteggi il file:

```bash
sudo chmod 600 /etc/samba/credentials
```

4. Modifica il file fstab:

```bash
sudo nano /etc/fstab
```

5. Aggiungi la seguente riga:

```
//nome-server/nome-condivisione /mnt/samba/condivisione cifs credentials=/etc/samba/credentials,uid=1000,gid=1000 0 0
```

6. Monta tutte le condivisioni:

```bash
sudo mount -a
```

### Connessione con Nautilus (Ubuntu Desktop)

1. Apri il file manager Nautilus
2. Premi Ctrl+L per mostrare la barra degli indirizzi
3. Digita `smb://nome-server/`
4. Inserisci le credenziali quando richieste

## Problemi comuni e soluzioni

### Non riesco a connettermi al server

- Verifica che il server sia acceso e operativo
- Controlla che il firewall permetta il traffico Samba (porte 139 e 445)
- Verifica di utilizzare nome utente e password corretti
- Assicurati di essere connesso alla rete aziendale

### Non vedo alcune cartelle condivise

- Le cartelle potrebbero essere impostate come non visibili (browseable = no)
- Potresti non avere i permessi necessari per accedere a determinate cartelle
- Contatta l'amministratore IT per verificare i tuoi permessi

### Problemi di autorizzazione

- Verifica di appartenere al gruppo corretto per la cartella a cui stai tentando di accedere
- Controlla che la tua password Samba sia sincronizzata (contatta l'amministratore IT)

## Regole di utilizzo delle cartelle condivise

1. **Cartelle pubbliche** (`public` e `documents`):
   - Accessibili a tutti gli utenti dell'azienda
   - Utilizzate per documenti di interesse generale
   - Non salvare informazioni sensibili in queste cartelle

2. **Cartelle di reparto** (`amministrazione`, `risorse_umane`, `it`):
   - Accessibili solo ai membri del reparto specifico
   - Utilizzate per documenti rilevanti solo per il reparto

3. **Cartelle private** (`private/username`):
   - Accessibili solo all'utente proprietario
   - Utilizzate per documenti personali di lavoro
   - Non vengono visualizzate da altri utenti

Per assistenza, contattare il reparto IT.