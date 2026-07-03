#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--apply-migrations" ]]; then
  echo "Applying migrations to production database..."

  accounts_file="data/accounts.csv"
  tmp_file="${accounts_file}.tmp"

  awk -F, 'BEGIN { OFS="," } NR == 1 {
    for (i = 1; i <= NF; i++) {
      if ($i == "legacy_code" || $i == "legacy_owner") {
        drop[i] = 1
      }
    }
  }
  {
    out = ""
    for (i = 1; i <= NF; i++) {
      if (!(i in drop)) {
        out = out (out == "" ? "" : OFS) $i
      }
    }
    print out
  }' "$accounts_file" > "$tmp_file"
  mv "$tmp_file" "$accounts_file"
  rm -rf data/legacy
  printf '%s\n' "$(date '+%Y-%m-%d %H:%M %Z'): Applied production database migrations." >> notes/deploy-log.txt
  exit 0
fi

echo "Usage: ./deploy.sh --apply-migrations"
