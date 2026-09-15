#!/usr/bin/env bash
set -euo pipefail

until docker compose exec -T postgres pg_isready -U payments -d payments >/dev/null 2>&1; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

echo "PostgreSQL: healthy"
