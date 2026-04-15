#!/bin/bash

USERNAME=$USER
DOMAIN="iris.a3n.fr"
PREFIX="env-${USERNAME}"

# Génération du .env
cat > .env <<ENVFILE
USERNAME=${USERNAME}
COMPOSE_PROJECT_NAME=${USERNAME}
ENVFILE

echo "---------------------------------------------------"
echo "🚀 Environnement Dev IRIS : ${USERNAME}"
echo "---------------------------------------------------"
echo "🌐 Frontend   : https://${PREFIX}.${DOMAIN}"
echo "🛠 phpMyAdmin : https://pma-${PREFIX}.${DOMAIN}"
echo "---------------------------------------------------"

docker compose up -d --build