# Terraform — Confluent Cloud

Esta camada transforma a infraestrutura do pipeline em código.

## O que é gerenciado

- três tópicos Kafka:
  - `payments.raw`
  - `payments.processed`
  - `payments.suspicious`
- opcionalmente, um Flink Compute Pool.

O compute pool fica **desativado por padrão** (`create_flink_compute_pool = false`) para evitar provisionamento involuntário de capacidade potencialmente cobrada.

## Pré-requisitos

- Terraform >= 1.6
- conta Confluent Cloud
- API key/secret da organização
- Kafka API key/secret para o cluster escolhido
- IDs do ambiente e do cluster Kafka

A autenticação por variáveis de ambiente é suportada pelo provider oficial da Confluent. Consulte a documentação oficial antes de executar `apply`.

## Execução

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# preencher terraform.tfvars localmente; não faça commit desse arquivo
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Flink

Para provisionar o compute pool, altere:

```hcl
create_flink_compute_pool = true
```

Antes do `apply`, confirme cloud, região, limite de CFUs e custos no ambiente Confluent Cloud.

## Segurança

Nunca coloque API keys, secrets ou `terraform.tfstate` no GitHub. O `.gitignore` do projeto já exclui esses artefatos.
