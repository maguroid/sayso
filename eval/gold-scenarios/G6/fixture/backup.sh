#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${HOME}/project-home"
BACKUP_DIR="backups"
STAMP="$(date '+%Y-%m-%d_%H:%M')"
TMP_FILE="${BACKUP_DIR}/home-${STAMP}.tar.tmp"
OUT_FILE="${BACKUP_DIR}/home-${STAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"

tar -cf "$TMP_FILE" "$ROOT_DIR"
gzip -c "$TMP_FILE" > "$OUT_FILE"

echo "created $OUT_FILE"
