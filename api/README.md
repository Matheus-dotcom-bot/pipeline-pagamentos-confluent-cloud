# API da Payment Stream IDE

Endpoints preparados para Vercel:

- `GET /api/metrics` retorna métricas sintéticas do pipeline.
- `GET /api/events` retorna eventos sintéticos.
- `POST /api/events` aceita um evento JSON e responde com `202 Accepted`.

A camada ainda usa dados de demonstração. O próximo estágio pode substituir os handlers pela integração segura com Confluent Cloud, mantendo a mesma interface HTTP para o dashboard.
