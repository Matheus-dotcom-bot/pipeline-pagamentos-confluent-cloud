#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo ".env created from .env.example. Review credentials before using Confluent Cloud."
fi

docker compose up -d postgres
./scripts/healthcheck.sh

printf '\nLocal PostgreSQL is ready.\n'
printf 'Next: configure Confluent Cloud credentials and deploy the CDC/Flink layers.\n'
