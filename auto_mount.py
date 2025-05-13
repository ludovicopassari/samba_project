#!/usr/bin/env python3

import os
import grp
import pwd
import subprocess

def get_user_groups():
    """
    Ottiene tutti i gruppi a cui appartiene l'utente corrente,
    escludendo il gruppo con lo stesso nome dell'utente e 'smbusers'
    """
    # Ottiene il nome dell'utente corrente
    username = pwd.getpwuid(os.getuid()).pw_name
    
    # Usa il comando groups per ottenere tutti i gruppi dell'utente
    result = subprocess.run(['groups'], stdout=subprocess.PIPE, text=True)
    groups = result.stdout.strip().split(':')
    if len(groups) > 1:
        # Output formato: "username : group1 group2 group3"
        groups = groups[1].strip().split()
    else:
        # Alternativa usando l'output diretto di 'groups'
        groups = result.stdout.strip().split()
    
    # Filtra i gruppi, escludendo il gruppo con lo stesso nome dell'utente e 'smbusers'
    filtered_groups = [group for group in groups if group != username and group != 'smbusers' and group != 'sudo']
    
    # Ritorna la lista dei gruppi filtrati
    return filtered_groups

def create_group_directories(base_dir=None):
    """
    Crea una directory per ogni gruppo a cui appartiene l'utente
    """
    # Se non è specificata una directory base, usa la home dell'utente
    if base_dir is None:
        base_dir = os.path.expanduser("~/Scrivania/samba_sharepoint")
    
    # Crea la directory base se non esiste
    if not os.path.exists(base_dir):
        os.makedirs(base_dir)
        print(f"Creata directory base: {base_dir}")
    
    # Ottieni i gruppi dell'utente
    groups = get_user_groups()
    private_dir = os.path.join(base_dir, "private")

    if not os.path.exists(private_dir):
        os.makedirs(private_dir)
        
    # Crea una directory per ogni gruppo
    for group in groups:
        group_dir = os.path.join(base_dir, group)
        if not os.path.exists(group_dir):
            os.makedirs(group_dir)
            print(f"Creata directory per il gruppo {group}: {group_dir}")
        else:
            print(f"La directory per il gruppo {group} esiste già: {group_dir}")

if __name__ == "__main__":
    import sys
    
    # Controlla se è stata specificata una directory base come argomento
    if len(sys.argv) > 1:
        base_dir = sys.argv[1]
        create_group_directories(base_dir)
    else:
        create_group_directories()