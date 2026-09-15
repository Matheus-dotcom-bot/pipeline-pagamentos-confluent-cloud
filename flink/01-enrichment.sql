-- Flink SQL reference implementation.
-- Adjust connector/table options to the target Confluent Cloud environment.

CREATE TABLE payments_raw (
  payment_id STRING,
  customer_id STRING,
  amount DECIMAL(14, 2),
  currency STRING,
  status STRING,
  payment_method STRING,
  created_at TIMESTAMP_LTZ(3),
  updated_at TIMESTAMP_LTZ(3),
  WATERMARK FOR created_at AS created_at - INTERVAL '5' SECOND
) WITH (
  'connector' = 'kafka',
  'topic' = 'payments.raw',
  'properties.bootstrap.servers' = '${KAFKA_BOOTSTRAP_SERVERS}',
  'properties.security.protocol' = 'SASL_SSL',
  'properties.sasl.mechanism' = 'PLAIN',
  'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="${KAFKA_API_KEY}" password="${KAFKA_API_SECRET}";',
  'format' = 'json'
);

CREATE TABLE payments_enriched (
  payment_id STRING,
  customer_id STRING,
  amount DECIMAL(14, 2),
  currency STRING,
  status STRING,
  payment_method STRING,
  created_at TIMESTAMP_LTZ(3),
  risk_band STRING
) WITH (
  'connector' = 'kafka',
  'topic' = 'payments.processed',
  'properties.bootstrap.servers' = '${KAFKA_BOOTSTRAP_SERVERS}',
  'properties.security.protocol' = 'SASL_SSL',
  'properties.sasl.mechanism' = 'PLAIN',
  'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="${KAFKA_API_KEY}" password="${KAFKA_API_SECRET}";',
  'format' = 'json'
);

INSERT INTO payments_enriched
SELECT
  payment_id,
  customer_id,
  amount,
  currency,
  status,
  payment_method,
  created_at,
  CASE
    WHEN amount >= 5000 THEN 'high'
    WHEN amount >= 1000 THEN 'medium'
    ELSE 'low'
  END AS risk_band
FROM payments_raw;
