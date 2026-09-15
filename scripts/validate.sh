#!/usr/bin/env bash
set -euo pipefail

required_files=(
  README.md
  .env.example
  .gitignore
  docker-compose.yml
  postgres/init.sql
  cdc/connector-config.json
  flink/01-enrichment.sql
  flink/02-fraud-detection.sql
  flink/03-output.sql
  consumer/consumer.py
  consumer/requirements.txt
  terraform/main.tf
  terraform/variables.tf
  terraform/outputs.tf
  terraform/terraform.tfvars.example
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "MISSING: $file"
    exit 1
  fi
done

python -m json.tool cdc/connector-config.json >/dev/null
python -m py_compile consumer/consumer.py tests/test_consumer.py

# The CDC configuration must not contain a real password or API secret.
if grep -Eiq 'password[[:space:]]*[:=][[:space:]]*["'"'][^$<][^"'"']+["'"']' cdc/connector-config.json; then
  echo "SECURITY CHECK FAILED: possible hard-coded password in CDC configuration"
  exit 1
fi

# SQL files are checked for the core pipeline contract.
grep -q "payments.raw" flink/01-enrichment.sql
grep -q "payments.processed" flink/01-enrichment.sql
grep -q "payments.suspicious" flink/02-fraud-detection.sql

echo "Repository structure: OK"
echo "JSON validation: OK"
echo "Python syntax: OK"
echo "SQL contract checks: OK"
echo "Secrets check: OK"
