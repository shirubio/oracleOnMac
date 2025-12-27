#!/bin/sh
set -euo pipefail

docker compose -f ./docker-compose.yaml down --remove-orphans
