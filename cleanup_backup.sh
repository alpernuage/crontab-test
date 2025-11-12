#!/bin/bash -l

BACKUP_DIR=("/chemin/racine/user")
LOG_DIR="chemin/log/application"
LIMIT=${1:-14} # en jours, supprimer les fichiers plus anciens que N jours

mkdir -p "$LOG_DIR"

for DIR in "${BACKUP_DIR[@]}"; do
    if [ -d "$DIR" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Lancement cleanup_backup.sh (Limit: ${LIMIT} jours" >> "$LOG_DIR/cron.log"

        # Recherche les fichiers anciens ET exclut explicitement les logs
        DELETED_FILES=$(find "$DIR" -type f -mtime +$LIMIT -not -path "${LOG_DIR}/*")

        if [ -n "$DELETED_FILES" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Fichiers supprimés :" >> "$LOG_DIR/cron.log"
            echo "$DELETED_FILES" >> "$LOG_DIR/cron.log"

            # Suppression effective
            find "$DIR" -type f -mtime +$LIMIT -print0 | xargs -0 rm -f
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Aucun fichier à supprimer dans $DIR" >> "$LOG_DIR/cron.log"
        fi

        echo "$(date '+%Y-%m-%d %H:%M:%S') - Fin du nettoyage pour $DIR" >> "$LOG_DIR/cron.log"

    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Dossier $DIR introuvable" >> "$LOG_DIR/cron_error.log"
    fi
done

#crontab
#DIR_CRONTAB_SCRIPTS=/home/user/scripts
#CLEAN_BACKUP_LIMIT=14
#@weekly $DIR_CRONTAB_SCRIPTS/cleanup_backup.sh $CLEAN_BACKUP_LIMIT
