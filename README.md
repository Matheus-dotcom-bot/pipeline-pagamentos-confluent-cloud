# Pipeline de Pagamentos em Tempo Real — Confluent Cloud

Pipeline de engenharia de dados para processamento de pagamentos em tempo real, usando PostgreSQL como fonte transacional, CDC, Apache Kafka/Confluent Cloud e Flink SQL para enriquecimento e identificação de transações suspeitas.

## Objetivo

Construir uma arquitetura fim a fim que transporte alterações de pagamentos desde o banco de origem até uma camada de processamento de streaming, produzindo eventos prontos para consumo.

O projeto foi estruturado em cinco camadas:

1. **Fundação** — ambiente, configuração e contratos.
2. **Fonte e CDC** — PostgreSQL e captura de alterações.
3. **Streaming** — tópicos e integração com Confluent Cloud.
4. **Processamento** — Flink SQL para enriquecimento e regras de suspeita.
5. **Consumo e operação** — consumidor, validações, métricas e evidências.

## Arquitetura

```text
PostgreSQL
    │
    │ alterações transacionais
    ▼
CDC / Debezium
    │
    ▼
Confluent Cloud / Kafka
    │
    ├──────── payments.raw
    │
    ▼
Apache Flink SQL
    │
    ├── enriquecimento
    ├── classificação de risco
    └── detecção de suspeitas
    │
    ├──────── payments.processed
    └──────── payments.suspicious
              │
              ▼
          Consumer
```

## Estrutura

```text
postgres/       esquema e dados sintéticos
cdc/            configuração do conector CDC
flink/          consultas SQL de streaming
consumer/       consumidor Python
terraform/      infraestrutura como código para Confluent Cloud
scripts/        validações operacionais
evidence/       evidências reais de execução
```

## Modelo de evento

Cada pagamento utiliza, como contrato mínimo, campos como:

- `payment_id`
- `customer_id`
- `amount`
- `currency`
- `status`
- `payment_method`
- `created_at`
- `updated_at`

O pipeline também pode produzir atributos derivados, como faixa de risco e motivo da suspeita.

## Regra inicial de suspeita

A implementação de referência considera uma transação suspeita quando uma regra de negócio configurada é satisfeita, por exemplo:

- valor acima do limite definido;
- repetição de pagamentos em uma janela curta;
- combinação de valor e frequência incompatível com o perfil esperado.

As regras podem ser substituídas pelas regras definitivas do desafio sem alterar a arquitetura.

## Execução local

O PostgreSQL pode ser iniciado com:

```bash
docker compose up -d postgres
```

Para instalar o consumidor:

```bash
pip install -r consumer/requirements.txt
```

Configure as variáveis de ambiente a partir de `.env.example` antes de conectar o projeto ao Confluent Cloud.

## Terraform + Confluent Cloud

A pasta `terraform/` contém a infraestrutura como código para os três tópicos do pipeline:

- `payments.raw`
- `payments.processed`
- `payments.suspicious`

Também existe suporte opcional à criação de um Flink Compute Pool. **A opção vem desativada por padrão** para impedir provisionamento involuntário de capacidade.

Fluxo:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# preencher os valores localmente
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Nunca faça commit de `terraform.tfvars`, credenciais ou `terraform.tfstate`.

## Confluent Cloud

O projeto foi preparado para utilizar:

- Kafka no Confluent Cloud;
- Schema Registry, quando habilitado;
- Flink SQL para processamento;
- conexão segura por SASL/SSL;
- tópicos separados para entrada, processamento e suspeitas.

As credenciais devem ser fornecidas por variáveis de ambiente ou secrets do ambiente de execução. Nenhuma chave real deve ser versionada.

## Evidências

A pasta `evidence/` deve receber somente evidências reais de execução, como logs, capturas ou resultados exportados. Arquivos de evidência não devem ser usados para simular uma execução que não ocorreu.

## Status

**Infraestrutura base implementada.** O próximo estágio é conectar uma instância real do Confluent Cloud, validar os tópicos, configurar o CDC e executar os statements Flink com evidências reais.

## Licença

Projeto educacional e experimental. Consulte o autor antes de reutilizar componentes específicos em produção.
