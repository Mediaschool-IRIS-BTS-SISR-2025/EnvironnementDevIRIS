#!/bin/bash
# stop.sh — Arrêt propre pour Linux
# Usage : bash stop.sh

docker compose down
echo "Conteneurs Down."
