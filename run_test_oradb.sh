#!/bin/sh
set -euo pipefail

# --- Configuration (override via environment variables if desired) ---
: "${ORA_HOST:=localhost}"
: "${ORA_PORT:=1521}"
: "${ORA_SERVICE:=MYORADB1}"
: "${ORA_USER:=MY_USER}"
: "${ORA_PWD:=My_Password123!}"
: "${ROWS_TO_CREATE:=1000}"
: "${PRINT_ROWS:=false}"

# Path to Oracle JDBC driver jar (place it under ./lib)
OJDBC_JAR="${OJDBC_JAR:-./lib/ojdbc17.jar}"

if [[ ! -f "$OJDBC_JAR" ]]; then
  echo "ERROR: Oracle JDBC driver jar not found at: $OJDBC_JAR"
  echo "Place ojdbc17.jar (or similar) under ./lib and rerun."
  exit 1
fi

SRC="TestOraDB.java"
OUT_DIR="./out"

mkdir -p "$OUT_DIR"

echo "Compiling $SRC ..."
javac -cp "$OJDBC_JAR" -d "$OUT_DIR" "$SRC"

echo "Running ..."
ORA_HOST="$ORA_HOST" \
ORA_PORT="$ORA_PORT" \
ORA_SERVICE="$ORA_SERVICE" \
ORA_USER="$ORA_USER" \
ORA_PWD="$ORA_PWD" \
ROWS_TO_CREATE="$ROWS_TO_CREATE" \
PRINT_ROWS="$PRINT_ROWS" \
java -cp "$OUT_DIR:$OJDBC_JAR" TestOraDB