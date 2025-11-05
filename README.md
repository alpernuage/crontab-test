# 🕒 Guide complet — Crontab & Logrotate

## 📘 Sommaire
- [Crontab – Gestion des tâches planifiées](#-crontab--gestion-des-tâches-planifiées)
    - [Commandes de Gestion](#commandes-de-gestion)
    - [Syntaxe d'une Tâche Cron](#syntaxe-dune-tâche-cron) 
    - [Bonnes Pratiques et Chemins](#bonnes-pratiques-et-chemins)
    - [Redirection des Sorties et Horodatage](#redirection-des-sorties-et-horodatage)
    - [Gestion des Verrous (lock)](#gestion-des-verrous-lock)
    - [Commande Utile : Suppression des Fichiers Anciens](#commande-utile--suppression-des-fichiers-anciens)
- [Logrotate – Gestion Automatisée des Logs](#logrotate--gestion-automatisée-des-logs)
    - [Configuration et Test](#configuration-et-test)
    - [Options de Configuration Clés](#options-de-configuration-clés)
    - [Le Fichier de Statut](#le-fichier-de-statut)
    - [Gestion des Fichiers Archivés](#gestion-des-fichiers-archivés)
    - [Sécurité et Permissions](#sécurité-et-permissions)
    - [Exemple de Configuration Crontab avec Log](#exemple-de-configuration-crontab-avec-log)

---

## 🧭 Crontab – Gestion des tâches planifiées

### Commandes de Gestion

| Commande | Description |
| :--- | :--- |
| `crontab -e` | Permet de **modifier** (éditer) les tâches cron de l'utilisateur courant. |
| `crontab -r` | Permet de **supprimer toutes** les tâches cron de l'utilisateur courant. **(ATTENTION : Irréversible)** |
| `sudo grep CRON /var/log/syslog` | Permet de **visualiser les logs** du système relatifs à l'exécution de cron. |

### Syntaxe d'une Tâche Cron

Chaque ligne dans le fichier crontab suit la syntaxe : `* * * * * commande`.

| Position | Champ | Plage de Valeurs | Description |
| :---: | :--- | :--- | :--- |
| **1** | Minute | 0-59 | |
| **2** | Heure | 0-23 | |
| **3** | Jour du mois | 1-31 | |
| **4** | Mois | 1-12 | |
| **5** | Jour de la semaine | 0-7 (`0` et `7` = Dimanche) | |

> **Note :** La fréquence minimale supportée par Cron est de **1 minute**.

| Expression       | Description                                                                 |
|------------------|------------------------------------------------------------------------------|
| `*/15 * * * *`   | Toutes les **15 minutes**                                                   |
| `15 * * * *`     | À la **15ᵉ minute** de chaque heure                                         |
| `0 */2 * * *`    | Toutes les **2 heures**                                                     |
| `0 9-17 * * 1-5` | Toutes les heures de **9h à 17h**, du **lundi au vendredi** — pratique pour tâches “heures de bureau” |
| `0 12 * * 1,3,5` | À **midi** les **lundis, mercredis et vendredis**                           |
| `@reboot`        | Une seule fois **au démarrage du serveur**                                  |

Le `,` sépare plusieurs valeurs  
→ `0 6,18 * * *` = à 6h00 et 18h00 chaque jour

Le `-` indique une plage  
→ `0 9-17 * * *` = chaque heure entre 9h et 17h inclus

Le `/` indique un intervalle  
→ `*/10` = “tous les 10 (minutes/heures/jours…)” selon la colonne

Les alias spéciaux :

| Alias    | Équivaut à | Description                 |
|----------|------------|-----------------------------|
| @yearly  | 0 0 1 1 *  | Chaque 1er janvier à minuit |
| @monthly | 0 0 1 * *  | Chaque 1er du mois          |
| @weekly  | 0 0 * * 0  | Chaque semaine (dimanche)   |
| @daily   | 0 0 * * *  | Chaque jour à minuit        |
| @hourly  | 0 * * * *  | Chaque heure pile           |


## Logrogate – Gestion


### Bonnes Pratiques et Chemins

* **Chemins Absolus :** Utilisez **toujours des chemins absolus** (depuis la racine `/`) pour la commande et les scripts afin de garantir une exécution correcte.
* **Éviter le `~` :** Le raccourci `~` est parfois peu fiable dans Cron. Préférez la forme `/home/username/`.
* **Rendre le script Exécutable :** Un script doit avoir le droit d'exécution (`x`) pour être lancé par Cron.
    ```bash
    chmod +x mon_script.sh
    ```

### Redirection des Sorties et Horodatage

* **Redirection Complète :** Rediriger la sortie standard (`STDOUT`) et les erreurs (`STDERR`) vers un fichier :
    ```bash
    * * * * * /chemin/vers/script.sh >> /chemin/vers/log.log 2>&1
    ```
    * `2>&1` : Redirige la sortie d'erreur (descripteur `2`) vers la même destination que la sortie standard (descripteur `1`).
* **Horodatage :** Ajoutez un timestamp dans votre script pour un meilleur traçage des événements :
    ```bash
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Message de log" >> ~/PhpstormProjects/Personal/cron-test/cron-test.log
    ```

### Gestion des Verrous (lock)

Pour les tâches longues, utilisez un mécanisme de verrouillage pour empêcher qu'une nouvelle instance ne se lance avant la fin de la précédente.

* **Méthode Robuste avec `flock` (Verrouillage de Fichier)**

    ```bash
    #!/bin/bash
    
    # Ouvre le fichier de verrouillage sur le descripteur 200
    exec 200>/tmp/mon_script.lock 
    
    # Tente d'obtenir un verrou non bloquant (-n), sinon quitte
    flock -n 200 || { echo "Script déjà en cours"; exit 1; }
    
    # --- Votre code de script ici ---
    ```

### Commande Utile : Suppression des Fichiers Anciens

Cette commande, souvent intégrée à une tâche cron, permet de nettoyer automatiquement les fichiers anciens.

* **Exemple :** Supprimer tous les fichiers créés depuis plus de 3 minutes dans un dossier :
    ```bash
    find ~/PhpstormProjects/Personal/cron-test/created_files/ -type f -mmin +3 -delete
    ```
    * `-type f` : Cherche uniquement les fichiers.
    * `-mmin +3` : Trouve les fichiers modifiés (modified) il y a plus de 3 minutes.
    * `-delete` : Supprime les fichiers trouvés.

---

## Logrotate – Gestion Automatisée des Logs

**Logrotate** est l'outil standard pour la rotation, la compression, l'archivage et la suppression des logs pour maintenir la taille du système de fichiers sous contrôle.

### Configuration et Test

* Les fichiers de configuration se trouvent dans le répertoire : `/etc/logrotate.d/`.
* Chaque fichier dans ce répertoire correspond à une configuration spécifique (ex: `/etc/logrotate.d/cron-test`).
* **Test :** Vérifiez la configuration sans l'exécuter réellement :
    ```bash
    sudo logrotate -d /etc/logrotate.d/cron-test
    ```

### Options de Configuration Clés

> **Déclenchement :** Logrotate est généralement déclenché **automatiquement** par une tâche cron système (souvent quotidienne, la nuit). La rotation a lieu lors de ce passage si la condition (`daily`, `size`,`daily`, `weekly`, `monthly`, `yearly`, `size`, `sleep`, etc.) est remplie.

| Option | Description | Rôle |
| :--- | :--- | :--- |
| `daily` / `size 1M` | Période ou condition | Rotation basée sur le temps (quotidienne) ou la taille (dès que le fichier dépasse 1 Mo). |
| `rotate 7` | Nombre d'archives | Garder les **7 archives** les plus récentes. |
| `compress` | Compression | Compresse les archives en `.gz` (gzip par défaut). |
| `delaycompress` | Compression retardée | L'archive la plus récente (`.1`) **n'est pas compressée** immédiatement (seulement au cycle suivant). |
| `missingok` | Fichier manquant | Ne génère **pas d'erreur** si le fichier de log est absent. |
| `notifempty` | Fichier vide | Ne tourne pas le fichier s'il est vide. |
| `create 640 user group` | Recréation | Recrée le fichier principal après rotation avec les droits et le propriétaire spécifiés. |
| `sharedscripts` | Scripts partagés | Le bloc `postrotate`/`prerotate` ne s'exécute qu'une fois par bloc de configuration. |
| `copytruncate` | **Copier puis Troncature** | Solution pour les applications qui gardent un descripteur de fichier ouvert. Copie le log, puis vide l'original. **L'application continue d'écrire dans le même fichier sans interruption.** |
| `dateext` | **Extension par Date** | Utilise la date dans le nom de l'archive (ex: `log.log-20251105.gz`) au lieu de la numérotation simple (`.log.1.gz`). Facilite la rétention. |
| `dateformat` | **Format de Date Personnalisé** | Définit le format des archives avec `dateext`. Essentiel pour les rotations multi-journalières. *Ex:* `dateformat -%Y%m%d-%H%M%S` |
| `su user group`          | Utilisateur de la Rotation | Changer l'utilisateur/groupe pour l'opération de rotation |
| `postrotate`/`endscript` | **Scripts après Rotation** | Bloc de commandes exécutées *après* que la rotation est terminée. Utilisé principalement pour envoyer un signal à un service (ex: `systemctl reload apache2`) pour qu'il ouvre le nouveau fichier log vide créé par `create`. |

### Le Fichier de Statut

`/var/lib/logrotate/status`

Ce fichier est le **cœur du fonctionnement de `logrotate`**.

* **But :** Il stocke la **date de la dernière rotation** pour *chaque* fichier de log géré.
* **Utilité :** Lorsque `logrotate` s'exécute, il lit ce fichier pour savoir si le critère de temps (`daily`, `weekly`, etc.) est rempli pour un fichier spécifique. Sans cette information, il tournerait tous les logs à chaque exécution.
* **Affichage (Exemple) :**
    ```bash
    cat /var/lib/logrotate/status
    # Affiche une liste de chemins avec leur dernière date de rotation :
    # logrotate state -- version 2
    # "/var/log/syslog" 2025-11-05
    # "/home/alp/cron-test/cron-test.log" 2025-11-04
    ```
  
### Gestion des Fichiers Archivés

* Les fichiers sont compressés en `gzip` (extension `.gz`) et sont dans le **même répertoire** que le log original.
* Le fichier `.log.1.gz` est toujours le **plus récent** des fichiers archivés.

| Action | Commande | Note |
| :--- | :--- | :--- |
| **Visualiser (on-the-fly)** | `zcat cron-test.log.1.gz \| less` | Décompresse et affiche sans créer de fichier temporaire. |
| **Décompresser (permanent)** | `gunzip -k cron-test.log.1.gz` | Crée le fichier non compressé (`cron-test.log.1`) et conserve la version `.gz` (`-k`). |

### Sécurité et Permissions

* Logrotate peut refuser de gérer un fichier si le dossier parent permet à d'autres utilisateurs que `root` d'écrire, par mesure de sécurité.
* **Solution :** Assurez-vous que les permissions du répertoire parent sont strictes, par exemple :
    ```bash
    chmod 755 /chemin/du/dossier
    ```

### Exemple de Configuration Crontab avec Log


Ceci est un exemple de configuration optimisée pour la gestion des logs et le verrouillage :

```cron
# MEILLEURE PRATIQUE : Définir explicitement le PATH pour toutes les commandes ci-dessous
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

* * * * * /home/alp/PhpstormProjects/Personal/cron-test/create_file.sh >> /home/alp/PhpstormProjects/Personal/cron-test/logs/cron-test.log 2>&1
* * * * * /home/alp/PhpstormProjects/Personal/cron-test/delete_file.sh >> /home/alp/PhpstormProjects/Personal/cron-test/logs/cron-test.log 2>&1
* * * * * /home/alp/PhpstormProjects/Personal/cron-test/long_task.sh >> /home/alp/PhpstormProjects/Personal/cron-test/long_task.log 2>&1
