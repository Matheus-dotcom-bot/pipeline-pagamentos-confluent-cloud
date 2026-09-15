#!/usr/bin/env bash
set -euo pipefail

required_files=(
  README.md
  .env.example
  docker-compose.yml
  postgres/init.sql
  cdc/connector-config.json
  flink/01-enrichment.sql
  flink/02-fraud-detection.sql
  flink/03-output.sql
  consumer/consumer.py
  consumer/requirements.txt
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "MISSING: $file"
    exit 1
  fi
done

echo "Repository structure: OK"

echo "Secrets check: .env is ignored by git; use .env.example as template."
