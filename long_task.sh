#!/bin/bash

# Définition du chemin absolu du fichier de verrouillage
LOCKFILE="/tmp/long_task.lock"
LOGFILE="/home/alp/PhpstormProjects/Personal/cron-test/long_task.log"

# 1. Tenter d'obtenir le verrou sur le descripteur 200
# -n: mode non bloquant. Si le verrou est déjà pris, l'exécution échoue immédiatement.
exec 200>"$LOCKFILE"
if ! flock -n 200; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Script déjà en cours. Verrouillage échoué." >> "$LOGFILE"
    exit 1
fi

# Le verrou est obtenu, le code du script s'exécute ici
echo "$(date '+%Y-%m-%d %H:%M:%S') - Début de l'exécution." >> "$LOGFILE"

# SIMULATION D'UNE TÂCHE LONGUE (70 secondes de délai)
sleep 70

# Créer un fichier de sortie pour prouver l'exécution
touch "/home/alp/PhpstormProjects/Personal/cron-test/created_files/long_file_$(date '+%Y-%m-%d_%H%M%S')"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Fin de l'exécution." >> "$LOGFILE"

# Le verrou est automatiquement relâché lorsque le script se termine.

exit 0

# Configuration Crontab pour le Test de Conflit
# * * * * * /home/alp/PhpstormProjects/Personal/cron-test/long_task.sh >> /home/alp/PhpstormProjects/Personal/cron-test/long_task.log 2>&1

# Vérification des Logs : Consultez le fichier de log créé par le script :
# tail -f /home/alp/PhpstormProjects/Personal/cron-test/long_task.log
