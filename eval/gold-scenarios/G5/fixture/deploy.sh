#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--apply-migrations" ]]; then
  echo "Applying fictional database migrations"
  exit 0
fi

echo "Usage: ./deploy.sh --apply-migrations"
