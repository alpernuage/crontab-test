#!/bin/bash

BASE_DIR=~/PhpstormProjects/Personal/cron-test

# Création des répertoires de destination si manquants
mkdir -p "$BASE_DIR/created_files"
mkdir -p "$BASE_DIR/logs"

# Tâche 1: Créer le fichier horodaté
touch "$BASE_DIR/created_files/file_$(date +%Y%m%d%H%M)"

# Tâche 2: Écrire le log
echo "$(date '+%Y-%m-%d %H:%M:%S') - Message de log" >> "$BASE_DIR/logs/cron-test.log"
