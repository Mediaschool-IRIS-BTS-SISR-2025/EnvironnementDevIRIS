# EnvironnementDevIRIS

Environnement de developpement Docker compose avec:
- Frontend Nginx (fichiers statiques + proxy FastCGI)
- Backend PHP-FPM
- Base de donnees MariaDB
- phpMyAdmin
- Routage HTTPS via Traefik (labels Docker)

## Structure du projet

```
.
├─ docker-compose.yml
├─ start.sh
├─ stop.sh
├─ backend/
│  ├─ dockerfile
│  └─ src/
│     ├─ index.php
│     └─ host-info.php
└─ frontend/
	├─ dockerfile
	├─ nginx.conf
	└─ src/
```

## Prerequis serveur

- Un serveur Linux avec Docker et Docker Compose plugin installes
- Un reverse proxy Traefik deja operationnel sur le serveur
- Le reseau Docker externe `admin_proxy` existant (utilise par Traefik)

Verification rapide:

```bash
docker --version
docker compose version
docker network ls | grep admin_proxy
```

Si le reseau n'existe pas:

```bash
docker network create admin_proxy
```

## Deploiement sur serveur via scp (dans le home)

Depuis ta machine locale, tu fais une commande scp pour "cloner" le projet dans le serveur

## Lancement

Le script `start.sh`:
- cree automatiquement un fichier `.env`
- injecte ton nom Linux dans `USERNAME`
- definit `COMPOSE_PROJECT_NAME` avec ce meme nom
- lance le stack en detached mode avec rebuild

Commande:

```bash
bash start.sh
```

## URLs generees

Les URLs dependent de l'utilisateur Linux du serveur (`$USER`).

- Frontend: `https://env-<user>.iris.a3n.fr`
- phpMyAdmin: `https://pma-env-<user>.iris.a3n.fr`

Exemple pour `tiago`:
- `https://env-tiago.iris.a3n.fr`
- `https://pma-env-tiago.iris.a3n.fr`

## Arret

```bash
bash stop.sh
```

## Logs et debug

Voir l'etat des conteneurs:

```bash
docker compose ps
```

Suivre les logs:

```bash
docker compose logs -f
```

## Troubleshooting : 403 Forbidden sur le frontend (ou 404 sur les .php)

Les services `frontend` et `backend` utilisent des bind-mounts vers `./frontend/src`
et `./backend/src`. Si ton home Linux est en mode `700` (cas par defaut sur
beaucoup de distros), Nginx et PHP-FPM tournant dans les conteneurs ne peuvent
pas traverser `/home/<user>` pour atteindre les fichiers, ce qui donne :

- `403 Forbidden` sur `/` (Nginx ne peut pas lire `index.html`)
- `404 Not Found` sur `/host-info.php` ou `/index.php` (PHP-FPM ne voit pas les fichiers)

Diagnostic :

```bash
docker compose logs frontend --tail=30
namei -l ~/EnvironnementDevIRIS/frontend/src/index.html
```

Si tu vois `Permission denied` dans les logs ou un dossier sans `r-x` pour
`others` dans la chaine `namei`, applique le fix :

```bash
chmod o+x /home/$USER
chmod -R o+rX ~/EnvironnementDevIRIS
docker compose restart frontend backend
```

Le `X` majuscule met `+x` uniquement sur les dossiers (traversee), pas sur les
fichiers. `chmod o+x` sur le home le rend traversable mais pas listable
(pas de `r`), donc les autres utilisateurs ne peuvent toujours pas voir
le contenu de ton home.

## Base de donnees

Variables configurees dans `docker-compose.yml`:
- `MYSQL_DATABASE=mediaschooldb`
- `MYSQL_USER=mediaschooluser`
- `MYSQL_PASSWORD=mediaschoolpass`
- `MYSQL_ROOT_PASSWORD=rootpass`

## Notes

- Le fichier `.env` est regenere par `start.sh` a chaque lancement.
- Les fichiers `dockerfile` sont en minuscule (`backend/dockerfile`, `frontend/dockerfile`) et references tels quels dans `docker-compose.yml`.
