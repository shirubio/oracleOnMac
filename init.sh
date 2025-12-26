#!/bin/sh
set -eu

VOLUME="oracle-data"

# Stop containers first (prefer docker compose, but keep your stop.sh if you want)
if [ -x "./stop.sh" ]; then
  ./stop.sh || true
fi

# Optional (recommended): ensure compose stack is down if this is a compose-based setup
# docker compose down || true

printf "Are you sure you want to delete the volume '%s'? This action cannot be undone. (y/N): " "$VOLUME"
read confirm

case "$confirm" in
  y|Y)
    # Check if volume exists
    if docker volume inspect "$VOLUME" >/dev/null 2>&1; then
      docker volume rm "$VOLUME"
      echo "Volume '$VOLUME' has been deleted."
    else
      echo "Volume '$VOLUME' does not exist. Nothing to delete."
    fi

    docker volume create --name="$VOLUME" >/dev/null
    echo "Volume '$VOLUME' has been created."
    ;;
  *)
    echo "Operation cancelled. The volume was not deleted."
    ;;
esac