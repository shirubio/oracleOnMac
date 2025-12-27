#!/bin/sh
set -euo pipefail

VOLUME="oracle-data"

# Files / directories explicitly allowed to be deleted
FILES_TO_DELETE="
testOraDB
oracle-on-mac
"

DIRS_TO_DELETE="
out
"

# Stop containers first
if [ -x "./stop.sh" ]; then
  ./stop.sh || true
fi

printf "Are you sure you want to delete Docker volume '%s'\n" "$VOLUME"
printf "This action cannot be undone. (y/N): "
read confirm

case "$confirm" in
  y|Y)
    echo "Starting cleanup..."

    # ---- Delete files ----
    for f in $FILES_TO_DELETE; do
      if [ -f "$f" ]; then
        rm -f -- "$f"
        echo "Deleted file: $f"
      else
        echo "File not found, skipping: $f"
      fi
    done

    # ---- Delete directories ----
    for d in $DIRS_TO_DELETE; do
      if [ -d "$d" ]; then
        rm -rf -- "$d"
        echo "Deleted directory: $d"
      else
        echo "Directory not found, skipping: $d"
      fi
    done

    # ---- Docker volume handling ----
    if docker volume inspect "$VOLUME" >/dev/null 2>&1; then
      docker volume rm "$VOLUME"
      echo "Volume '$VOLUME' has been deleted."
    else
      echo "Volume '$VOLUME' does not exist. Nothing to delete."
    fi

    docker volume create --name="$VOLUME" >/dev/null
    echo "Volume '$VOLUME' has been created."

    echo "Cleanup completed successfully."
    ;;
  *)
    echo "Operation cancelled. Nothing was deleted."
    ;;
esac