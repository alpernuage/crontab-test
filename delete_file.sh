#!/bin/bash

BASE_DIR=~/PhpstormProjects/Personal/cron-test/created_files

# La commande ci-dessous affiche les fichiers trouvés (via -print)
# ET exécute rm sur ces fichiers (via -exec), garantissant une sortie sur STDOUT.
# La sortie (la liste des fichiers supprimés) sera envoyée à Cron via STDOUT
find "$BASE_DIR" -type f -mmin +3 -print -exec rm -f {} \;
